from django.db import models
from django.contrib.auth import get_user_model
from django.utils import timezone
from phonenumber_field.modelfields import PhoneNumberField

User = get_user_model()


class Category(models.Model):
    """
    Category model for items
    """
    name = models.CharField(max_length=100, unique=True)
    icon = models.CharField(max_length=50, blank=True, help_text="Icon name or class")
    description = models.TextField(blank=True)

    class Meta:
        verbose_name = 'Category'
        verbose_name_plural = 'Categories'
        ordering = ['name']

    def __str__(self):
        return self.name


class LostItem(models.Model):
    """
    Model for lost items reported by users
    """
    STATUS_CHOICES = [
        ('pending', 'Pending'),
        ('found', 'Found'),
        ('closed', 'Closed'),
    ]

    # Basic Information
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='lost_items')
    title = models.CharField(max_length=200)
    description = models.TextField()
    category = models.ForeignKey(Category, on_delete=models.SET_NULL, null=True, blank=True, related_name='lost_items')

    # Location details
    location_name = models.CharField(max_length=255)
    latitude = models.DecimalField(max_digits=9, decimal_places=6, null=True, blank=True)
    longitude = models.DecimalField(max_digits=9, decimal_places=6, null=True, blank=True)

    # Item details
    brand = models.CharField(max_length=100, blank=True)
    color = models.CharField(max_length=50, blank=True)
    serial_number = models.CharField(max_length=100, blank=True)

    # Contact information
    contact_phone = PhoneNumberField(blank=True)
    contact_email = models.EmailField(blank=True)

    # Status and dates
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='pending')
    lost_date = models.DateTimeField()
    date_posted = models.DateTimeField(auto_now_add=True)
    date_updated = models.DateTimeField(auto_now=True)

    # Images
    image1 = models.ImageField(upload_to='lost_items/', blank=True, null=True)
    image2 = models.ImageField(upload_to='lost_items/', blank=True, null=True)
    image3 = models.ImageField(upload_to='lost_items/', blank=True, null=True)

    class Meta:
        verbose_name = 'Lost Item'
        verbose_name_plural = 'Lost Items'
        ordering = ['-date_posted']
        indexes = [
            models.Index(fields=['status']),
            models.Index(fields=['lost_date']),
            models.Index(fields=['user', 'status']),
        ]

    def __str__(self):
        return f"{self.title} - {self.get_status_display()}"


class FoundItem(models.Model):
    """
    Model for found items reported by users
    """
    STATUS_CHOICES = [
        ('pending', 'Pending'),
        ('returned', 'Returned to Owner'),
        ('donated', 'Donated'),
        ('disposed', 'Disposed'),
    ]

    # Basic Information
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='found_items')
    title = models.CharField(max_length=200)
    description = models.TextField()
    category = models.ForeignKey(Category, on_delete=models.SET_NULL, null=True, blank=True, related_name='found_items')

    # Location details
    location_name = models.CharField(max_length=255)
    latitude = models.DecimalField(max_digits=9, decimal_places=6, null=True, blank=True)
    longitude = models.DecimalField(max_digits=9, decimal_places=6, null=True, blank=True)

    # Where item is kept
    current_location = models.CharField(max_length=255)

    # Item details
    brand = models.CharField(max_length=100, blank=True)
    color = models.CharField(max_length=50, blank=True)
    serial_number = models.CharField(max_length=100, blank=True)

    # Contact information
    contact_phone = PhoneNumberField(blank=True)
    contact_email = models.EmailField(blank=True)

    # Status and dates
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='pending')
    found_date = models.DateTimeField()
    date_posted = models.DateTimeField(auto_now_add=True)
    date_updated = models.DateTimeField(auto_now=True)

    # Images
    image1 = models.ImageField(upload_to='found_items/', blank=True, null=True)
    image2 = models.ImageField(upload_to='found_items/', blank=True, null=True)
    image3 = models.ImageField(upload_to='found_items/', blank=True, null=True)

    class Meta:
        verbose_name = 'Found Item'
        verbose_name_plural = 'Found Items'
        ordering = ['-date_posted']
        indexes = [
            models.Index(fields=['status']),
            models.Index(fields=['found_date']),
            models.Index(fields=['user', 'status']),
        ]

    def __str__(self):
        return f"{self.title} - {self.get_status_display()}"



class ClaimRequest(models.Model):
    """
    Model for users claiming found items
    """
    STATUS_CHOICES = [
        ('pending', 'Pending Review'),
        ('accepted', 'Claim Accepted'),
        ('rejected', 'Claim Rejected'),
        ('withdrawn', 'Claim Withdrawn'),
    ]

    item = models.ForeignKey('FoundItem', on_delete=models.CASCADE, related_name='claims')
    claimant = models.ForeignKey(User, on_delete=models.CASCADE, related_name='claims_made')

    # Claim details
    description = models.TextField(help_text="Describe why this item belongs to you")
    additional_info = models.TextField(blank=True, help_text="Any additional proof or information")

    # Proof of ownership
    proof_image = models.ImageField(upload_to='claim_proofs/', blank=True, null=True)

    # Status tracking
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='pending')

    # Timestamps
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    # Decision tracking
    reviewed_by = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, blank=True,
                                    related_name='claims_reviewed')
    reviewed_at = models.DateTimeField(null=True, blank=True)
    rejection_reason = models.TextField(blank=True, help_text="Reason for rejection (if rejected)")

    class Meta:
        ordering = ['-created_at']
        unique_together = ['item', 'claimant']  # Prevent duplicate claims

    def __str__(self):
        return f"Claim by {self.claimant} for {self.item.title} - {self.status}"

    def accept_claim(self, reviewer):
        """Accept the claim"""
        self.status = 'accepted'
        self.reviewed_by = reviewer
        self.reviewed_at = timezone.now()
        self.save()

        # Update item status
        self.item.status = 'claimed'
        self.item.save()

    def reject_claim(self, reviewer, reason=""):
        """Reject the claim"""
        self.status = 'rejected'
        self.rejection_reason = reason
        self.reviewed_by = reviewer
        self.reviewed_at = timezone.now()
        self.save()


class Notification(models.Model):
    """
    Notification model for user alerts
    """
    NOTIFICATION_TYPES = [
        ('claim', 'New Claim'),
        ('claim_accepted', 'Claim Accepted'),
        ('claim_rejected', 'Claim Rejected'),
        ('claim_withdrawn', 'Claim Withdrawn'),
        ('item_found', 'Item Found'),
        ('item_matched', 'Item Matched'),
    ]

    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='notifications')
    title = models.CharField(max_length=255)
    message = models.TextField()
    notification_type = models.CharField(max_length=20, choices=NOTIFICATION_TYPES)

    # Related claim (if any)
    claim = models.ForeignKey('ClaimRequest', on_delete=models.SET_NULL, null=True, blank=True)
    related_id = models.IntegerField(null=True, blank=True, help_text="ID of related object")

    # Status
    is_read = models.BooleanField(default=False)
    is_seen = models.BooleanField(default=False)

    # Timestamps
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['-created_at']

    def __str__(self):
        return f"{self.user} - {self.title}"

    def mark_as_read(self):
        self.is_read = True
        self.save()