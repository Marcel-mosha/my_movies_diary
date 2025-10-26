from django.contrib import admin
from .models import Movie

@admin.register(Movie)
class MovieAdmin(admin.ModelAdmin):
    list_display = ['title', 'year', 'rating', 'ranking']
    list_filter = ['year', 'rating']
    search_fields = ['title', 'description']
    ordering = ['-rating']
