from rest_framework import generics, permissions, status
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework.authtoken.models import Token
from django.contrib.auth import login, logout
from django.contrib.auth import get_user_model

from .serializers import (
    UserSerializer,
    RegisterSerializer,
    LoginSerializer,
    ChangePasswordSerializer,
    ProfileUpdateSerializer
)

User = get_user_model()


class RegisterView(generics.CreateAPIView):
    """Register a new user"""
    queryset = User.objects.all()
    permission_classes = [permissions.AllowAny]
    serializer_class = RegisterSerializer

    def create(self, request, *args, **kwargs):
        print(f"📝 Registration attempt for: {request.data.get('phone_number', '')}")

        serializer = self.get_serializer(data=request.data)

        if serializer.is_valid():
            user = serializer.save()
            token, _ = Token.objects.get_or_create(user=user)
            login(request, user)

            print(f"✅ Registration successful: {user.phone_number}")

            return Response({
                'success': True,
                'message': 'Registration successful',
                'user': UserSerializer(user).data,
                'token': token.key,
            }, status=status.HTTP_201_CREATED)
        else:
            # CRITICAL FIX: Convert ALL errors to a single STRING
            error_messages = []

            for field, errors in serializer.errors.items():
                if isinstance(errors, list):
                    for error in errors:
                        # Extract the string message from ErrorDetail
                        if hasattr(error, 'string'):
                            error_messages.append(f"{field}: {error.string}")
                        else:
                            error_messages.append(f"{field}: {str(error)}")
                else:
                    error_messages.append(f"{field}: {str(errors)}")

            # If no specific field errors, use a general message
            if not error_messages:
                error_messages.append("Registration failed. Please check your information.")

            error_string = '. '.join(error_messages)

            print(f"❌ Registration error: {error_string}")
            print(f"❌ Full error details: {serializer.errors}")

            # IMPORTANT: Return error as a STRING, not an object
            return Response({
                'success': False,
                'error': error_string  # ← THIS MUST BE A STRING, NOT AN OBJECT
            }, status=status.HTTP_400_BAD_REQUEST)


class LoginView(APIView):
    """Login user"""
    permission_classes = [permissions.AllowAny]

    def post(self, request):
        print(f"📝 Login attempt for: {request.data.get('phone_number', '')}")

        serializer = LoginSerializer(data=request.data)

        if serializer.is_valid():
            user = serializer.validated_data['user']
            token, _ = Token.objects.get_or_create(user=user)
            login(request, user)

            print(f"✅ Login successful: {user.phone_number}")

            return Response({
                'success': True,
                'message': 'Login successful',
                'user': UserSerializer(user).data,
                'token': token.key,
            })
        else:
            # Convert errors to string
            error_messages = []
            for field, errors in serializer.errors.items():
                if isinstance(errors, list):
                    for error in errors:
                        if hasattr(error, 'string'):
                            error_messages.append(f"{field}: {error.string}")
                        else:
                            error_messages.append(f"{field}: {str(error)}")
                else:
                    error_messages.append(f"{field}: {str(errors)}")

            error_string = '. '.join(error_messages)

            print(f"❌ Login error: {error_string}")

            return Response({
                'success': False,
                'error': error_string
            }, status=status.HTTP_400_BAD_REQUEST)


class LogoutView(APIView):
    """Logout user"""
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        try:
            request.user.auth_token.delete()
        except:
            pass

        logout(request)
        return Response({
            'success': True,
            'message': 'Logout successful'
        })


class ProfileView(generics.RetrieveAPIView):
    """Get user profile"""
    serializer_class = UserSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_object(self):
        return self.request.user


class UpdateProfileView(generics.UpdateAPIView):
    """Update user profile"""
    serializer_class = ProfileUpdateSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_object(self):
        return self.request.user

    def update(self, request, *args, **kwargs):
        instance = self.get_object()
        serializer = self.get_serializer(instance, data=request.data, partial=True)

        if serializer.is_valid():
            self.perform_update(serializer)
            return Response({
                'success': True,
                'message': 'Profile updated successfully',
                'user': UserSerializer(instance).data
            })
        else:
            error_messages = []
            for field, errors in serializer.errors.items():
                error_messages.append(f"{field}: {', '.join([str(e) for e in errors])}")

            error_string = '. '.join(error_messages)

            return Response({
                'success': False,
                'error': error_string
            }, status=status.HTTP_400_BAD_REQUEST)


class ChangePasswordView(APIView):
    """Change user password"""
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        serializer = ChangePasswordSerializer(data=request.data)

        if serializer.is_valid():
            user = request.user

            if not user.check_password(serializer.validated_data['old_password']):
                return Response({
                    'success': False,
                    'error': 'Current password is incorrect'
                }, status=status.HTTP_400_BAD_REQUEST)

            user.set_password(serializer.validated_data['new_password'])
            user.save()

            try:
                token = Token.objects.get(user=user)
                token.delete()
                new_token = Token.objects.create(user=user)
            except Token.DoesNotExist:
                new_token = Token.objects.create(user=user)

            login(request, user)

            return Response({
                'success': True,
                'message': 'Password changed successfully',
                'token': new_token.key
            })
        else:
            error_messages = []
            for field, errors in serializer.errors.items():
                error_messages.append(f"{field}: {', '.join([str(e) for e in errors])}")

            error_string = '. '.join(error_messages)

            return Response({
                'success': False,
                'error': error_string
            }, status=status.HTTP_400_BAD_REQUEST)