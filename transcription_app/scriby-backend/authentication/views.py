"""
Authentication views for Eskriba backend.
"""
from rest_framework import viewsets, status
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework.authtoken.models import Token
from django.contrib.auth import authenticate
from django.contrib.auth import get_user_model
User = get_user_model()
from .serializers import UserSerializer, RegisterSerializer


class UserViewSet(viewsets.ModelViewSet):
    """
    ViewSet for managing users.
    """
    queryset = User.objects.all()
    serializer_class = UserSerializer
    # authentication_classes = [TokenAuthentication]  # Temporarily disabled for testing
    # permission_classes = [IsAuthenticated]  # Temporarily disabled for testing


class RegisterView(APIView):
    """
    API view for user registration.
    """
    def post(self, request):
        """
        Register a new user.
        """
        serializer = RegisterSerializer(data=request.data)
        if serializer.is_valid():
            user = serializer.save()
            token, created = Token.objects.get_or_create(user=user)
            return Response({
                'status': 'success',
                'message': 'User registered successfully',
                'token': token.key,
                'user_id': user.id
            }, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class LoginView(APIView):
    """
    API view for user login.
    """
    def post(self, request):
        """
        Authenticate user and return token.
        """
        username = request.data.get('username')
        password = request.data.get('password')
        
        if username and password:
            user = authenticate(username=username, password=password)
            if user:
                token, created = Token.objects.get_or_create(user=user)
                return Response({
                    'status': 'success',
                    'message': 'Login successful',
                    'token': token.key,
                    'user_id': user.id
                }, status=status.HTTP_200_OK)
        
        return Response({
            'status': 'error',
            'message': 'Invalid credentials'
        }, status=status.HTTP_401_UNAUTHORIZED)


class LogoutView(APIView):
    """
    API view for user logout.
    """
    # authentication_classes = [TokenAuthentication]  # Temporarily disabled for testing
    # permission_classes = [IsAuthenticated]  # Temporarily disabled for testing

    def post(self, request):
        """
        Logout user by deleting token.
        """
        # TODO: Implement proper token deletion when authentication is enabled
        return Response({
            'status': 'success',
            'message': 'Logout successful'
        }, status=status.HTTP_200_OK)


class ProfileView(APIView):
    """
    API view for user profile management.
    """
    # authentication_classes = [TokenAuthentication]  # Temporarily disabled for testing
    # permission_classes = [IsAuthenticated]  # Temporarily disabled for testing

    def get(self, request):
        """
        Get user profile information.
        """
        # TODO: Return actual user profile when authentication is enabled
        return Response({
            'status': 'success',
            'message': 'Profile endpoint',
            'user': 'anonymous'
        }, status=status.HTTP_200_OK)
