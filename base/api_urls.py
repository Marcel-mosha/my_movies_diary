from django.urls import path, include
from rest_framework.routers import DefaultRouter
from rest_framework_simplejwt.views import TokenRefreshView
from . import api_views

router = DefaultRouter()
router.register(r'movies', api_views.MovieViewSet, basename='movie')

urlpatterns = [
    # API endpoints
    path('api/', include(router.urls)),
    path('api/register/', api_views.RegisterView.as_view(), name='api_register'),
    path('api/login/', api_views.LoginView.as_view(), name='api_login'),
    path('api/token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    path('api/user/', api_views.current_user, name='current_user'),
]
