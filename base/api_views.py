import requests
from rest_framework import viewsets, status, generics
from rest_framework.decorators import action, api_view, permission_classes
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated, AllowAny
from django.conf import settings
from django.contrib.auth import authenticate
from rest_framework_simplejwt.tokens import RefreshToken
from .models import Movie
from .serializers import (
    MovieSerializer, 
    MovieCreateSerializer, 
    MovieUpdateSerializer,
    UserSerializer,
    UserRegistrationSerializer
)


class RegisterView(generics.CreateAPIView):
    """API endpoint for user registration"""
    serializer_class = UserRegistrationSerializer
    permission_classes = [AllowAny]
    
    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        user = serializer.save()
        
        # Generate JWT tokens
        refresh = RefreshToken.for_user(user)
        
        return Response({
            'user': UserSerializer(user).data,
            'refresh': str(refresh),
            'access': str(refresh.access_token),
            'message': 'Account created successfully!'
        }, status=status.HTTP_201_CREATED)


class LoginView(generics.GenericAPIView):
    """API endpoint for user login"""
    permission_classes = [AllowAny]
    
    def post(self, request):
        username = request.data.get('username')
        password = request.data.get('password')
        
        if not username or not password:
            return Response(
                {'error': 'Please provide both username and password'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        user = authenticate(username=username, password=password)
        
        if user is not None:
            refresh = RefreshToken.for_user(user)
            return Response({
                'user': UserSerializer(user).data,
                'refresh': str(refresh),
                'access': str(refresh.access_token),
                'message': f'Welcome back, {username}!'
            })
        else:
            return Response(
                {'error': 'Invalid username or password'},
                status=status.HTTP_401_UNAUTHORIZED
            )


class MovieViewSet(viewsets.ModelViewSet):
    """
    API endpoint for CRUD operations on movies.
    All operations are scoped to the authenticated user.
    """
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        """Return movies for the current user, ordered by rating"""
        return Movie.objects.filter(user=self.request.user).order_by('-rating')
    
    def get_serializer_class(self):
        """Return appropriate serializer based on action"""
        if self.action == 'create':
            return MovieCreateSerializer
        elif self.action in ['update', 'partial_update']:
            return MovieUpdateSerializer
        return MovieSerializer
    
    def list(self, request, *args, **kwargs):
        """List all movies for the current user with updated rankings"""
        queryset = self.get_queryset()
        
        # Update rankings
        for index, movie in enumerate(queryset, start=1):
            if movie.ranking != index:
                movie.ranking = index
                movie.save(update_fields=['ranking'])
        
        serializer = self.get_serializer(queryset, many=True)
        return Response(serializer.data)
    
    def create(self, request, *args, **kwargs):
        """Create a movie and return full movie data with ID"""
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        movie = serializer.save(user=request.user)
        
        # Return full movie data using MovieSerializer
        output_serializer = MovieSerializer(movie)
        return Response(output_serializer.data, status=status.HTTP_201_CREATED)
    
    def perform_update(self, serializer):
        """Ensure user can only update their own movies"""
        serializer.save()
    
    def perform_destroy(self, instance):
        """Ensure user can only delete their own movies"""
        instance.delete()
    
    @action(detail=False, methods=['get'])
    def search_tmdb(self, request):
        """Search for movies on TMDB API"""
        title = request.query_params.get('title', '')
        
        if not title:
            return Response(
                {'error': 'Please provide a movie title'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        params = {
            "api_key": settings.TMDB_API_KEY,
            "query": title
        }
        
        try:
            response = requests.get(settings.TMDB_MOVIE_ENDPOINT, params=params)
            response.raise_for_status()
            movies_data = response.json()["results"]
            return Response(movies_data)
        except requests.RequestException as e:
            return Response(
                {'error': f'Error fetching data from TMDB: {str(e)}'},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )
    
    @action(detail=False, methods=['get'])
    def fetch_tmdb_details(self, request):
        """Fetch movie details from TMDB API by movie ID"""
        movie_api_id = request.query_params.get('id', '')
        
        if not movie_api_id:
            return Response(
                {'error': 'Please provide a movie ID'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        movie_api_url = f"https://api.themoviedb.org/3/movie/{movie_api_id}"
        params = {
            "api_key": settings.TMDB_API_KEY,
            "language": "en-US"
        }
        
        try:
            response = requests.get(movie_api_url, params=params)
            response.raise_for_status()
            movie_data = response.json()
            
            # Extract year from release_date
            year = 0
            if movie_data.get("release_date"):
                try:
                    year = int(movie_data["release_date"].split("-")[0])
                except (ValueError, IndexError):
                    year = 0
            
            # Check if movie already exists for this user
            existing_movie = Movie.objects.filter(
                user=request.user,
                title=movie_data["title"]
            ).first()
            
            if existing_movie:
                return Response(
                    {'error': 'You have already added this movie'},
                    status=status.HTTP_400_BAD_REQUEST
                )
            
            # Return movie data for frontend to create
            return Response({
                'title': movie_data["title"],
                'year': year,
                'img_url': f"{settings.TMDB_IMG_URL}{movie_data['poster_path']}" if movie_data.get('poster_path') else '',
                'description': movie_data.get("overview", "")
            })
            
        except requests.RequestException as e:
            return Response(
                {'error': f'Error fetching movie details: {str(e)}'},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def current_user(request):
    """Get current authenticated user"""
    serializer = UserSerializer(request.user)
    return Response(serializer.data)
