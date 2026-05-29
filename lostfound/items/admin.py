from django.contrib import admin
from .models import Category, LostItem, FoundItem, ClaimRequest, Notification


@admin.register(Category)
class CategoryAdmin(admin.ModelAdmin):
    list_display = ('id', 'name')
    search_fields = ('name',)


@admin.register(LostItem)
class LostItemAdmin(admin.ModelAdmin):
    list_display = ('id', 'title', 'user', 'category', 'status', 'lost_date', 'date_posted')
    list_filter = ('status', 'category', 'date_posted')
    search_fields = ('title', 'description', 'location_name', 'brand')
    readonly_fields = ('date_posted', 'date_updated')
    raw_id_fields = ('user',)

    fieldsets = (
        ('Basic Information', {
            'fields': ('user', 'title', 'description', 'category')
        }),
        ('Location & Date', {
            'fields': ('location_name', 'lost_date')
        }),
        ('Item Details', {
            'fields': ('brand', 'color', 'serial_number')
        }),
        ('Contact Information', {
            'fields': ('contact_phone', 'contact_email')
        }),
        ('Status', {
            'fields': ('status',)
        }),
        ('Media', {
            'fields': ('image1', 'image2', 'image3')
        }),
        ('Timestamps', {
            'fields': ('date_posted', 'date_updated')
        }),
    )


@admin.register(FoundItem)
class FoundItemAdmin(admin.ModelAdmin):
    list_display = ('id', 'title', 'user', 'category', 'status', 'found_date', 'date_posted')
    list_filter = ('status', 'category', 'date_posted')
    search_fields = ('title', 'description', 'location_name', 'brand')
    readonly_fields = ('date_posted', 'date_updated')
    raw_id_fields = ('user',)

    fieldsets = (
        ('Basic Information', {
            'fields': ('user', 'title', 'description', 'category')
        }),
        ('Location & Date', {
            'fields': ('location_name', 'current_location', 'found_date')
        }),
        ('Item Details', {
            'fields': ('brand', 'color', 'serial_number')
        }),
        ('Contact Information', {
            'fields': ('contact_phone', 'contact_email')
        }),
        ('Status', {
            'fields': ('status',)
        }),
        ('Media', {
            'fields': ('image1', 'image2', 'image3')
        }),
        ('Timestamps', {
            'fields': ('date_posted', 'date_updated')
        }),
    )


@admin.register(ClaimRequest)
class ClaimRequestAdmin(admin.ModelAdmin):
    list_display = ('id', 'item', 'claimant', 'status', 'created_at', 'updated_at')
    list_filter = ('status', 'created_at')
    search_fields = ('description', 'additional_info')
    readonly_fields = ('created_at', 'updated_at', 'reviewed_at')
    raw_id_fields = ('item', 'claimant', 'reviewed_by')

    fieldsets = (
        ('Claim Information', {
            'fields': ('item', 'claimant', 'description', 'additional_info')
        }),
        ('Proof', {
            'fields': ('proof_image',)
        }),
        ('Status', {
            'fields': ('status', 'rejection_reason', 'reviewed_by', 'reviewed_at')
        }),
        ('Timestamps', {
            'fields': ('created_at', 'updated_at')
        }),
    )

    actions = ['accept_claims', 'reject_claims']

    def accept_claims(self, request, queryset):
        updated = queryset.update(status='accepted')
        self.message_user(request, f'{updated} claims were accepted.')

    accept_claims.short_description = "Accept selected claims"

    def reject_claims(self, request, queryset):
        updated = queryset.update(status='rejected')
        self.message_user(request, f'{updated} claims were rejected.')

    reject_claims.short_description = "Reject selected claims"


@admin.register(Notification)
class NotificationAdmin(admin.ModelAdmin):
    list_display = ('id', 'user', 'title', 'notification_type', 'is_read', 'created_at')
    list_filter = ('notification_type', 'is_read', 'created_at')
    search_fields = ('title', 'message')
    readonly_fields = ('created_at',)
    raw_id_fields = ('user', 'claim')

    fieldsets = (
        ('Notification', {
            'fields': ('user', 'title', 'message', 'notification_type')
        }),
        ('Related Objects', {
            'fields': ('claim',)
        }),
        ('Status', {
            'fields': ('is_read', 'is_seen')
        }),
        ('Timestamps', {
            'fields': ('created_at',)
        }),
    )