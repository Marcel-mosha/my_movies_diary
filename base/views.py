import requests
from django.shortcuts import render, redirect, get_object_or_404
from django.contrib import messages
from django.contrib.auth import login, logout, authenticate
from django.contrib.auth.decorators import login_required
from django.contrib.auth.forms import UserCreationForm, AuthenticationForm
from django.conf import settings
from .models import Movie
from .forms import MovieForm, AddMovieForm

def register(request):
    if request.method == 'POST':
        form = UserCreationForm(request.POST)
        if form.is_valid():
            user = form.save()
            login(request, user)
            messages.success(request, f'Account created successfully! Welcome, {user.username}!')
            return redirect('home')
        else:
            messages.error(request, 'Please correct the errors below.')
    else:
        form = UserCreationForm()
    
    return render(request, 'registration/register.html', {'form': form})

def user_login(request):
    if request.method == 'POST':
        form = AuthenticationForm(request, data=request.POST)
        if form.is_valid():
            username = form.cleaned_data.get('username')
            password = form.cleaned_data.get('password')
            user = authenticate(username=username, password=password)
            if user is not None:
                login(request, user)
                messages.success(request, f'Welcome back, {username}!')
                return redirect('home')
        else:
            messages.error(request, 'Invalid username or password.')
    else:
        form = AuthenticationForm()
    
    return render(request, 'registration/login.html', {'form': form})

@login_required
def user_logout(request):
    logout(request)
    messages.success(request, 'You have been successfully logged out.')
    return redirect('home')

@login_required
def home(request):
    movies = Movie.objects.filter(user=request.user).order_by('-rating')
    
    # Update rankings for user's movies
    for index, movie in enumerate(movies, start=1):
        movie.ranking = index
        movie.save()
    
    return render(request, 'index.html', {'movies': movies})

@login_required
def add_movie(request):
    if request.method == 'POST':
        form = AddMovieForm(request.POST)
        if form.is_valid():
            title = form.cleaned_data['title']
            
            # Search TMDB API
            params = {
                "api_key": settings.TMDB_API_KEY,
                "query": title
            }
            
            try:
                response = requests.get(settings.TMDB_MOVIE_ENDPOINT, params=params)
                response.raise_for_status()
                movies_data = response.json()["results"]
                return render(request, 'select.html', {'choices': movies_data})
            except requests.RequestException as e:
                messages.error(request, f"Error fetching data from TMDB: {str(e)}")
    
    else:
        form = AddMovieForm()
    
    return render(request, 'add.html', {'form': form})

@login_required
def edit_movie(request, id):
    movie = get_object_or_404(Movie, id=id, user=request.user)
    
    if request.method == 'POST':
        form = MovieForm(request.POST, instance=movie)
        if form.is_valid():
            form.save()
            messages.success(request, f'Successfully updated {movie.title}')
            return redirect('home')
    else:
        form = MovieForm(instance=movie)
    
    return render(request, 'edit.html', {'movie': movie, 'form': form})

@login_required
def delete_movie(request, id):
    movie = get_object_or_404(Movie, id=id, user=request.user)
    if request.method == 'POST':
        movie_title = movie.title
        movie.delete()
        messages.success(request, f'Successfully deleted {movie_title}')
        return redirect('home')
    
    return render(request, 'confirm_delete.html', {'movie': movie})

@login_required
def find_movie(request):
    movie_api_id = request.GET.get("id")
    if movie_api_id:
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
            
            # Create new movie for current user
            new_movie = Movie(
                user=request.user,
                title=movie_data["title"],
                year=year,
                img_url=f"{settings.TMDB_IMG_URL}/{movie_data['poster_path']}" if movie_data.get('poster_path') else '',
                description=movie_data.get("overview", "")
            )
            new_movie.save()
            
            return redirect('edit_movie', id=new_movie.id)
            
        except requests.RequestException as e:
            messages.error(request, f"Error fetching movie details: {str(e)}")
            return redirect('add_movie')
    
    return redirect('add_movie')