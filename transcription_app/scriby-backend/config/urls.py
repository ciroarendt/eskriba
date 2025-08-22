"""
URL configuration for Eskriba backend project - Clean Setup
"""
from django.contrib import admin
from django.urls import path, include
from django.conf import settings
from django.conf.urls.static import static
from rest_framework.routers import DefaultRouter
from django.http import JsonResponse
from django.contrib.auth import authenticate
from django.contrib.auth.models import User
from rest_framework.authtoken.models import Token
from django.views.decorators.csrf import csrf_exempt
from django.views.decorators.http import require_http_methods
import json

def api_health(request):
    """Simple health check endpoint"""
    return JsonResponse({'status': 'ok', 'message': 'Eskriba API is running'})

@csrf_exempt
def api_auth_register(request):
    """Register endpoint integrated with health pattern"""
    if request.method == 'POST':
        try:
            data = json.loads(request.body)
            username = data.get('username')
            email = data.get('email') 
            password = data.get('password')
            
            if not all([username, email, password]):
                return JsonResponse({'error': 'Missing required fields'}, status=400)
            
            if User.objects.filter(username=username).exists():
                return JsonResponse({'error': 'Username already exists'}, status=400)
            
            user = User.objects.create_user(username=username, email=email, password=password)
            token, created = Token.objects.get_or_create(user=user)
            
            return JsonResponse({
                'status': 'success',
                'message': 'User registered successfully',
                'token': token.key,
                'user_id': user.id
            }, status=201)
        except Exception as e:
            return JsonResponse({'error': str(e)}, status=500)
    else:
        return JsonResponse({'error': 'Method not allowed'}, status=405)

@csrf_exempt
def api_auth_login(request):
    """Login endpoint integrated with health pattern"""
    if request.method == 'POST':
        try:
            data = json.loads(request.body)
            username = data.get('username')
            password = data.get('password')
            
            if not all([username, password]):
                return JsonResponse({'error': 'Missing username or password'}, status=400)
            
            user = authenticate(username=username, password=password)
            if user:
                token, created = Token.objects.get_or_create(user=user)
                return JsonResponse({
                    'status': 'success',
                    'message': 'Login successful',
                    'token': token.key,
                    'user_id': user.id
                })
            else:
                return JsonResponse({'error': 'Invalid credentials'}, status=401)
        except Exception as e:
            return JsonResponse({'error': str(e)}, status=500)
    else:
        return JsonResponse({'error': 'Method not allowed'}, status=405)

@csrf_exempt
@require_http_methods(["POST"])
def api_register(request):
    """Simple register endpoint"""
    try:
        data = json.loads(request.body)
        username = data.get('username')
        email = data.get('email')
        password = data.get('password')
        
        if not all([username, email, password]):
            return JsonResponse({'error': 'Missing required fields'}, status=400)
        
        if User.objects.filter(username=username).exists():
            return JsonResponse({'error': 'Username already exists'}, status=400)
        
        user = User.objects.create_user(username=username, email=email, password=password)
        token, created = Token.objects.get_or_create(user=user)
        
        return JsonResponse({
            'status': 'success',
            'message': 'User registered successfully',
            'token': token.key,
            'user_id': user.id
        }, status=201)
    except Exception as e:
        return JsonResponse({'error': str(e)}, status=500)

@csrf_exempt
@require_http_methods(["POST"])
def api_login(request):
    """Simple login endpoint"""
    try:
        data = json.loads(request.body)
        username = data.get('username')
        password = data.get('password')
        
        if not all([username, password]):
            return JsonResponse({'error': 'Missing username or password'}, status=400)
        
        user = authenticate(username=username, password=password)
        if user:
            token, created = Token.objects.get_or_create(user=user)
            return JsonResponse({
                'status': 'success',
                'message': 'Login successful',
                'token': token.key,
                'user_id': user.id
            })
        else:
            return JsonResponse({'error': 'Invalid credentials'}, status=401)
    except Exception as e:
        return JsonResponse({'error': str(e)}, status=500)

# API Router
router = DefaultRouter()

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/health/', api_health, name='api-health'),
    path('register/', api_auth_register, name='register'),
    path('login/', api_auth_login, name='login'),
    path('api/', include(router.urls)),
    path('api/', include('recordings.urls')),
    path('api/', include('transcriptions.urls')),
    path('api-auth/', include('rest_framework.urls')),
]

# Serve media files in development
if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
    urlpatterns += static(settings.STATIC_URL, document_root=settings.STATIC_ROOT)
