from rest_framework import serializers
from django.contrib.auth.models import User
from .models import Movie


class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['id', 'username', 'email']
        read_only_fields = ['id']


class UserRegistrationSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, min_length=8)
    password2 = serializers.CharField(write_only=True, min_length=8)
    
    class Meta:
        model = User
        fields = ['username', 'email', 'password', 'password2']
    
    def validate(self, attrs):
        if attrs['password'] != attrs['password2']:
            raise serializers.ValidationError({"password": "Password fields didn't match."})
        return attrs
    
    def create(self, validated_data):
        validated_data.pop('password2')
        user = User.objects.create_user(
            username=validated_data['username'],
            email=validated_data.get('email', ''),
            password=validated_data['password']
        )
        return user


class MovieSerializer(serializers.ModelSerializer):
    user = UserSerializer(read_only=True)
    
    class Meta:
        model = Movie
        fields = ['id', 'user', 'title', 'year', 'description', 'rating', 
                  'ranking', 'review', 'img_url', 'created_at', 'updated_at']
        read_only_fields = ['id', 'user', 'ranking', 'created_at', 'updated_at']


class MovieCreateSerializer(serializers.ModelSerializer):
    """Serializer for creating movies from TMDB API data"""
    
    class Meta:
        model = Movie
        fields = ['id', 'title', 'year', 'description', 'img_url']
        read_only_fields = ['id']
    
    def create(self, validated_data):
        user = self.context['request'].user
        validated_data['user'] = user
        return Movie.objects.create(**validated_data)


class MovieUpdateSerializer(serializers.ModelSerializer):
    """Serializer for updating movie rating and review"""
    
    class Meta:
        model = Movie
        fields = ['rating', 'review']
