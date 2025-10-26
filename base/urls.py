from django.urls import path
from . import views

urlpatterns = [
    path('', views.home, name='home'),
    path('register/', views.register, name='register'),
    path('login/', views.user_login, name='login'),
    path('logout/', views.user_logout, name='logout'),
    path('add/', views.add_movie, name='add_movie'),
    path('edit/<int:id>/', views.edit_movie, name='edit_movie'),
    path('delete/<int:id>/', views.delete_movie, name='delete_movie'),
    path('find/', views.find_movie, name='find_movie'),
]