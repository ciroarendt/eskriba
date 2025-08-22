"""
URL configuration for Eskriba backend project - Clean Setup
"""
from django.contrib import admin
from django.urls import path, include
from django.conf import settings
from django.conf.urls.static import static
from rest_framework.routers import DefaultRouter
from django.http import JsonResponse

def api_health(request):
    """Simple health check endpoint"""
    return JsonResponse({'status': 'ok', 'message': 'Eskriba API is running'})

def api_test_auth(request):
    """Test auth endpoint"""
    return JsonResponse({'status': 'ok', 'message': 'Auth endpoint test'})

# API Router
router = DefaultRouter()

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/', include(router.urls)),
    path('api/', include('recordings.urls')),
    path('api/', include('transcriptions.urls')),
    path('api/health/', api_health, name='api-health'),
    path('api/auth-test/', api_test_auth, name='api-auth-test'),
    path('api-auth/', include('rest_framework.urls')),
]

# Add authentication URLs directly
from authentication import views as auth_views
urlpatterns += [
    path('api/auth/register/', auth_views.RegisterView.as_view(), name='api-register'),
    path('api/auth/login/', auth_views.LoginView.as_view(), name='api-login'),
    path('api/auth/logout/', auth_views.LogoutView.as_view(), name='api-logout'),
    path('api/auth/profile/', auth_views.ProfileView.as_view(), name='api-profile'),
]

# Serve media files in development
if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
    urlpatterns += static(settings.STATIC_URL, document_root=settings.STATIC_ROOT)
