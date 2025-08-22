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

def api_register_test(request):
    """Test register endpoint"""
    return JsonResponse({'status': 'ok', 'message': 'Register endpoint test'})

# API Router
router = DefaultRouter()

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/health/', api_health, name='api-health'),
    path('api/auth-test/', api_test_auth, name='api-auth-test'),
    path('api/auth/register-test/', api_register_test, name='api-register-test'),
    path('api/', include(router.urls)),
    path('api/', include('recordings.urls')),
    path('api/', include('transcriptions.urls')),
    path('api-auth/', include('rest_framework.urls')),
]

# Serve media files in development
if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
    urlpatterns += static(settings.STATIC_URL, document_root=settings.STATIC_ROOT)
