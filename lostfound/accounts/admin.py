from django.contrib import admin
from django.contrib.auth.admin import UserAdmin as BaseUserAdmin
from django.utils.translation import gettext_lazy as _
from .models import User


@admin.register(User)
class UserAdmin(BaseUserAdmin):
    list_display = ('id', 'phone_number', 'full_name', 'email', 'is_verified', 'is_staff', 'date_joined')
    list_filter = ('is_verified', 'is_staff', 'is_superuser', 'is_active')
    search_fields = ('phone_number', 'full_name', 'email')
    ordering = ('-date_joined',)

    fieldsets = (
        (None, {'fields': ('phone_number', 'password')}),
        (_('Personal info'), {'fields': ('full_name', 'email')}),
        (_('Permissions'),
         {'fields': ('is_active', 'is_staff', 'is_superuser', 'is_verified', 'groups', 'user_permissions')}),
        (_('Important dates'), {'fields': ('last_login', 'date_joined')}),
    )

    add_fieldsets = (
        (None, {
            'classes': ('wide',),
            'fields': ('phone_number', 'full_name', 'email', 'password1', 'password2'),
        }),
    )