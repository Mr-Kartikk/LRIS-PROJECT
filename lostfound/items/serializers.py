from rest_framework import serializers
from django.contrib.auth import get_user_model
from .models import Category, LostItem, FoundItem, ClaimRequest,Notification

User = get_user_model()


class UserSummarySerializer(serializers.ModelSerializer):
    """
    Simplified user serializer for nested responses
    """

    class Meta:
        model = User
        fields = ['id', 'phone_number', 'full_name']


class CategorySerializer(serializers.ModelSerializer):
    """
    Serializer for Category model
    """

    class Meta:
        model = Category
        fields = ['id', 'name', 'icon', 'description']


class LostItemSerializer(serializers.ModelSerializer):
    """
    Serializer for LostItem model
    """
    user = UserSummarySerializer(read_only=True)
    category_name = serializers.CharField(source='category.name', read_only=True)

    class Meta:
        model = LostItem
        fields = [
            'id', 'user', 'title', 'description', 'category', 'category_name',
            'location_name', 'latitude', 'longitude',
            'brand', 'color', 'serial_number',
            'contact_phone', 'contact_email',
            'status', 'lost_date', 'date_posted', 'date_updated',
            'image1', 'image2', 'image3'
        ]
        read_only_fields = ['user', 'date_posted', 'date_updated']

    def create(self, validated_data):
        validated_data['user'] = self.context['request'].user
        return super().create(validated_data)


class FoundItemSerializer(serializers.ModelSerializer):
    """
    Serializer for FoundItem model
    """
    user = UserSummarySerializer(read_only=True)
    category_name = serializers.CharField(source='category.name', read_only=True)

    class Meta:
        model = FoundItem
        fields = [
            'id', 'user', 'title', 'description', 'category', 'category_name',
            'location_name', 'latitude', 'longitude',
            'current_location', 'brand', 'color', 'serial_number',
            'contact_phone', 'contact_email',
            'status', 'found_date', 'date_posted', 'date_updated',
            'image1', 'image2', 'image3'
        ]
        read_only_fields = ['user', 'date_posted', 'date_updated']

    def create(self, validated_data):
        validated_data['user'] = self.context['request'].user
        return super().create(validated_data)


class ClaimRequestSerializer(serializers.ModelSerializer):
    claimant_details = serializers.SerializerMethodField()
    item_details = serializers.SerializerMethodField()
    time_ago = serializers.SerializerMethodField()

    class Meta:
        model = ClaimRequest
        fields = [
            'id', 'item', 'item_details', 'claimant', 'claimant_details',
            'description', 'additional_info', 'proof_image',
            'status', 'rejection_reason', 'created_at', 'updated_at',
            'reviewed_at', 'time_ago'
        ]
        read_only_fields = ['claimant', 'status', 'reviewed_at', 'reviewed_by']

    def get_claimant_details(self, obj):
        return {
            'id': obj.claimant.id,
            'full_name': obj.claimant.full_name,
            'phone_number': str(obj.claimant.phone_number),
            'email': obj.claimant.email,
        }

    def get_item_details(self, obj):
        return {
            'id': obj.item.id,
            'title': obj.item.title,
            'description': obj.item.description,
            'location_name': obj.item.location_name,
            'found_date': obj.item.found_date,
            'image': obj.item.image1.url if obj.item.image1 else None,
        }

    def get_time_ago(self, obj):
        from django.utils import timezone
        now = timezone.now()
        diff = now - obj.created_at

        if diff.days > 0:
            return f"{diff.days} day{'s' if diff.days > 1 else ''} ago"
        elif diff.seconds > 3600:
            hours = diff.seconds // 3600
            return f"{hours} hour{'s' if hours > 1 else ''} ago"
        elif diff.seconds > 60:
            minutes = diff.seconds // 60
            return f"{minutes} minute{'s' if minutes > 1 else ''} ago"
        else:
            return "Just now"


class NotificationSerializer(serializers.ModelSerializer):
    time_ago = serializers.SerializerMethodField()
    claim_details = serializers.SerializerMethodField()

    class Meta:
        model = Notification
        fields = [
            'id', 'title', 'message', 'notification_type',
            'is_read', 'is_seen', 'created_at', 'time_ago',
            'claim', 'claim_details', 'related_id'
        ]

    def get_time_ago(self, obj):
        from django.utils import timezone
        now = timezone.now()
        diff = now - obj.created_at

        if diff.days > 0:
            return f"{diff.days} day{'s' if diff.days > 1 else ''} ago"
        elif diff.seconds > 3600:
            hours = diff.seconds // 3600
            return f"{hours} hour{'s' if hours > 1 else ''} ago"
        elif diff.seconds > 60:
            minutes = diff.seconds // 60
            return f"{minutes} minute{'s' if minutes > 1 else ''} ago"
        else:
            return "Just now"

    def get_claim_details(self, obj):
        if obj.claim:
            return {
                'id': obj.claim.id,
                'status': obj.claim.status,
                'item_title': obj.claim.item.title,
                'claimant_name': obj.claim.claimant.full_name,
            }
        return None