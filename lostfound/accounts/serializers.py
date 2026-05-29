from rest_framework import serializers
from django.contrib.auth import authenticate
from django.contrib.auth.password_validation import validate_password
from django.core import exceptions
from rest_framework.authtoken.models import Token
from phonenumber_field.serializerfields import PhoneNumberField
from .models import User
import phonenumbers
from django.db import IntegrityError


class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['id', 'phone_number', 'email', 'full_name', 'is_verified', 'date_joined']
        read_only_fields = ['id', 'is_verified', 'date_joined']


class RegisterSerializer(serializers.ModelSerializer):
    password = serializers.CharField(
        write_only=True,
        required=True,
        style={'input_type': 'password'}
    )
    confirm_password = serializers.CharField(
        write_only=True,
        required=True,
        style={'input_type': 'password'}
    )
    phone_number = serializers.CharField(required=True)

    class Meta:
        model = User
        fields = ['phone_number', 'full_name', 'email', 'password', 'confirm_password']
        extra_kwargs = {
            'full_name': {'required': True},
            'email': {'required': False, 'allow_blank': True},
        }

    def validate_phone_number(self, value):
        """Validate phone number format"""
        value = value.strip()

        # Try parsing and normalizing the phone number to E.164
        try:
            parsed = phonenumbers.parse(value, None)
        except phonenumbers.NumberParseException:
            raise serializers.ValidationError('Invalid phone number format. Include country code, e.g. +919999999999')

        if not phonenumbers.is_valid_number(parsed):
            raise serializers.ValidationError('Invalid phone number')

        normalized = phonenumbers.format_number(parsed, phonenumbers.PhoneNumberFormat.E164)

        # Check if already exists (compare normalized)
        if User.objects.filter(phone_number=normalized).exists():
            raise serializers.ValidationError('This phone number is already registered.')

        return normalized

    def validate_full_name(self, value):
        """Validate full name"""
        value = value.strip()
        if len(value) < 3:
            raise serializers.ValidationError('Full name must be at least 3 characters')
        return value

    def validate_password(self, value):
        """Validate password strength"""
        if len(value) < 8:
            raise serializers.ValidationError('Password must be at least 8 characters')

        # Check for at least one uppercase, one lowercase, one number, one special character
        if not any(char.isupper() for char in value):
            raise serializers.ValidationError('Password must contain at least one uppercase letter')
        if not any(char.islower() for char in value):
            raise serializers.ValidationError('Password must contain at least one lowercase letter')
        if not any(char.isdigit() for char in value):
            raise serializers.ValidationError('Password must contain at least one number')
        if not any(char in '!@#$%^&*()_+-=[]{}|;:,.<>?' for char in value):
            raise serializers.ValidationError('Password must contain at least one special character')

        return value

    def validate(self, attrs):
        """Validate that passwords match"""
        if attrs.get('password') != attrs.get('confirm_password'):
            raise serializers.ValidationError({
                'confirm_password': 'Passwords do not match'
            })
        return attrs

    def create(self, validated_data):
        """Create user"""
        # Remove confirm_password from data
        validated_data.pop('confirm_password')

        # Ensure phone_number is normalized (validate_phone_number returns normalized)
        phone = validated_data.get('phone_number')
        if phone:
            validated_data['phone_number'] = phone

        try:
            user = User.objects.create_user(
                phone_number=validated_data['phone_number'],
                password=validated_data['password'],
                full_name=validated_data['full_name'],
                email=validated_data.get('email', '')
            )
        except IntegrityError:
            raise serializers.ValidationError({'phone_number': 'This phone number is already registered.'})
        except Exception as e:
            raise serializers.ValidationError({'non_field_errors': f'Unable to create user: {str(e)}'})

        # Create auth token
        Token.objects.create(user=user)

        return user


class LoginSerializer(serializers.Serializer):
    phone_number = serializers.CharField(required=True)
    password = serializers.CharField(
        required=True,
        write_only=True,
        style={'input_type': 'password'}
    )

    def validate(self, attrs):
        phone_number = attrs.get('phone_number')
        password = attrs.get('password')

        if not phone_number or not password:
            raise serializers.ValidationError('Must include "phone_number" and "password".')

        # Authenticate user
        try:
            user = User.objects.get(phone_number=phone_number)
        except User.DoesNotExist:
            raise serializers.ValidationError('Invalid phone number or password.')

        if not user.check_password(password):
            raise serializers.ValidationError('Invalid phone number or password.')

        if not user.is_active:
            raise serializers.ValidationError('This account is disabled.')

        attrs['user'] = user
        return attrs


class ChangePasswordSerializer(serializers.Serializer):
    old_password = serializers.CharField(required=True, write_only=True)
    new_password = serializers.CharField(required=True, write_only=True)
    confirm_password = serializers.CharField(required=True, write_only=True)

    def validate(self, attrs):
        if attrs['new_password'] != attrs['confirm_password']:
            raise serializers.ValidationError({
                'confirm_password': 'New passwords do not match'
            })
        return attrs


class ProfileUpdateSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['full_name', 'email']

    def validate_full_name(self, value):
        value = value.strip()
        if len(value) < 3:
            raise serializers.ValidationError('Full name must be at least 3 characters')
        return value

    def validate_email(self, value):
        if value and User.objects.filter(email=value).exclude(id=self.instance.id).exists():
            raise serializers.ValidationError('This email is already in use.')
        return value