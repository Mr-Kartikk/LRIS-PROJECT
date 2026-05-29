from django.db import models
from django.contrib.auth.models import AbstractBaseUser, BaseUserManager, PermissionsMixin
from django.utils import timezone
from phonenumber_field.modelfields import PhoneNumberField


class UserManager(BaseUserManager):
    def create_user(self, phone_number, password=None, **extra_fields):
        """
        Create and save a regular user with the given phone number and password.
        """
        if not phone_number:
            raise ValueError('The Phone Number field must be set')

        user = self.model(phone_number=phone_number, **extra_fields)
        user.set_password(password)
        user.save(using=self._db)
        return user

    def create_superuser(self, phone_number, password=None, **extra_fields):
        """
        Create and save a superuser with the given phone number and password.
        """
        extra_fields.setdefault('is_staff', True)
        extra_fields.setdefault('is_superuser', True)
        extra_fields.setdefault('is_verified', True)

        if extra_fields.get('is_staff') is not True:
            raise ValueError('Superuser must have is_staff=True.')
        if extra_fields.get('is_superuser') is not True:
            raise ValueError('Superuser must have is_superuser=True.')

        return self.create_user(phone_number, password, **extra_fields)


class User(AbstractBaseUser, PermissionsMixin):
    """
    Custom User model with phone number as the unique identifier.
    """
    phone_number = PhoneNumberField(unique=True, verbose_name='Phone Number')
    email = models.EmailField(blank=True, null=True, verbose_name='Email Address')
    full_name = models.CharField(max_length=255, verbose_name='Full Name')

    # Status fields
    is_active = models.BooleanField(default=True, verbose_name='Active')
    is_staff = models.BooleanField(default=False, verbose_name='Staff Status')
    is_verified = models.BooleanField(default=False, verbose_name='Verified')

    # Timestamps
    date_joined = models.DateTimeField(default=timezone.now, verbose_name='Date Joined')
    last_login = models.DateTimeField(null=True, blank=True, verbose_name='Last Login')

    objects = UserManager()

    USERNAME_FIELD = 'phone_number'
    REQUIRED_FIELDS = ['full_name']

    class Meta:
        verbose_name = 'User'
        verbose_name_plural = 'Users'
        ordering = ['-date_joined']

    def __str__(self):
        return str(self.phone_number)

    @property
    def full_name_property(self):
        """Returns the user's full name."""
        return self.full_name