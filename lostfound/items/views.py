from rest_framework import generics, permissions, status, filters
from rest_framework.views import APIView
from rest_framework.response import Response
from django_filters.rest_framework import DjangoFilterBackend
from django.db.models import Q
from django.utils import timezone
from .services.matching_service import ItemMatchingService

from .models import Category, LostItem, FoundItem, ClaimRequest, Notification
from .serializers import (
    CategorySerializer,
    LostItemSerializer,
    FoundItemSerializer,
    ClaimRequestSerializer,
    NotificationSerializer
)


# Category Views
class CategoryListView(generics.ListAPIView):
    """
    List all categories
    """
    queryset = Category.objects.all()
    serializer_class = CategorySerializer
    permission_classes = [permissions.AllowAny]
    filter_backends = [filters.SearchFilter]
    search_fields = ['name']


# Lost Item Views - SINGLE DEFINITION with matching service
class LostItemListCreateView(generics.ListCreateAPIView):
    """
    List all lost items or create a new lost item
    """
    serializer_class = LostItemSerializer
    permission_classes = [permissions.IsAuthenticatedOrReadOnly]
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    search_fields = ['title', 'description', 'location_name', 'brand', 'color']
    filterset_fields = ['category', 'status']
    ordering_fields = ['lost_date', 'date_posted']

    def get_queryset(self):
        return LostItem.objects.filter(status='pending')

    def perform_create(self, serializer):
        lost_item = serializer.save(user=self.request.user)

        # Trigger matching service
        matching_service = ItemMatchingService()
        notifications = matching_service.check_for_matches_on_lost_report(lost_item)

        print(f"✅ Created {len(notifications)} match notifications for lost item")


class LostItemDetailView(generics.RetrieveUpdateDestroyAPIView):
    """
    Retrieve, update or delete a lost item
    """
    serializer_class = LostItemSerializer
    permission_classes = [permissions.IsAuthenticatedOrReadOnly]

    def get_queryset(self):
        return LostItem.objects.all()

    def perform_update(self, serializer):
        serializer.save()

    def perform_destroy(self, instance):
        instance.delete()


# Found Item Views - SINGLE DEFINITION with matching service
class FoundItemListCreateView(generics.ListCreateAPIView):
    """
    List all found items or create a newfound item
    """
    serializer_class = FoundItemSerializer
    permission_classes = [permissions.IsAuthenticatedOrReadOnly]
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    search_fields = ['title', 'description', 'location_name', 'brand', 'color']
    filterset_fields = ['category', 'status']
    ordering_fields = ['found_date', 'date_posted']

    def get_queryset(self):
        return FoundItem.objects.filter(status='pending')

    def perform_create(self, serializer):
        found_item = serializer.save(user=self.request.user)

        # Trigger matching service
        matching_service = ItemMatchingService()
        notifications = matching_service.create_match_notifications(found_item)

        print(f"✅ Created {len(notifications)} match notifications for found item")


class FoundItemDetailView(generics.RetrieveUpdateDestroyAPIView):
    """
    Retrieve, update or delete a found item
    """
    serializer_class = FoundItemSerializer
    permission_classes = [permissions.IsAuthenticatedOrReadOnly]

    def get_queryset(self):
        return FoundItem.objects.all()

    def perform_update(self, serializer):
        serializer.save()

    def perform_destroy(self, instance):
        instance.delete()


# My Items View
class MyItemsView(APIView):
    """
    Get all items posted by the current user
    """
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        lost_items = LostItem.objects.filter(user=request.user)
        found_items = FoundItem.objects.filter(user=request.user)

        lost_serializer = LostItemSerializer(lost_items, many=True)
        found_serializer = FoundItemSerializer(found_items, many=True)

        return Response({
            'lost_items': lost_serializer.data,
            'found_items': found_serializer.data
        })


# Search Views
class SearchItemsView(APIView):
    """
    Search for lost and found items
    """
    permission_classes = [permissions.AllowAny]

    def get(self, request):
        query = request.GET.get('q', '')
        category = request.GET.get('category', '')
        location = request.GET.get('location', '')
        item_type = request.GET.get('type', 'both')

        results = {}

        # Build search query
        search_query = Q()
        if query:
            search_query &= Q(
                Q(title__icontains=query) |
                Q(description__icontains=query) |
                Q(location_name__icontains=query) |
                Q(brand__icontains=query) |
                Q(color__icontains=query)
            )

        if location:
            search_query &= Q(location_name__icontains=location)

        if category:
            search_query &= Q(category_id=category)

        # Search lost items
        if item_type in ['lost', 'both']:
            lost_items = LostItem.objects.filter(
                search_query,
                status='pending'
            ).order_by('-date_posted')
            results['lost_items'] = LostItemSerializer(lost_items, many=True).data
            results['lost_items_count'] = lost_items.count()

        # Search found items
        if item_type in ['found', 'both']:
            found_items = FoundItem.objects.filter(
                search_query,
                status='pending'
            ).order_by('-date_posted')
            results['found_items'] = FoundItemSerializer(found_items, many=True).data
            results['found_items_count'] = found_items.count()

        return Response(results)


# ============= CLAIM VIEWS =============

class CreateClaimView(generics.CreateAPIView):
    """
    Create a claim for a found item (lost item owner claims found item)
    """
    serializer_class = ClaimRequestSerializer
    permission_classes = [permissions.IsAuthenticated]

    def perform_create(self, serializer):
        claim = serializer.save(claimant=self.request.user)

        # Create notification for the finder
        Notification.objects.create(
            user=claim.item.user,  # The finder
            title="New Claim Received",
            message=f"{claim.claimant.full_name} has claimed your found item '{claim.item.title}'. Please review their claim.",
            notification_type='claim',
            claim=claim
        )

        print(f"✅ Claim created by {claim.claimant} for item {claim.item.id}")


class MyClaimsView(generics.ListAPIView):
    """
    List all claims made by the current user (as claimant)
    """
    serializer_class = ClaimRequestSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return ClaimRequest.objects.filter(claimant=self.request.user)


class ClaimsOnMyItemsView(generics.ListAPIView):
    """
    List all claims on items posted by the current user (as finder)
    """
    serializer_class = ClaimRequestSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return ClaimRequest.objects.filter(item__user=self.request.user)


class ClaimDetailView(generics.RetrieveAPIView):
    """
    Get details of a specific claim
    """
    serializer_class = ClaimRequestSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        # Users can only view claims they're involved in
        return ClaimRequest.objects.filter(
            Q(claimant=self.request.user) | Q(item__user=self.request.user)
        )


class AcceptClaimView(APIView):
    """
    Accept a claim (only the finder can accept)
    """
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, claim_id):
        try:
            claim = ClaimRequest.objects.get(id=claim_id)

            # Verify the current user is the finder (item owner)
            if claim.item.user != request.user:
                return Response({
                    'success': False,
                    'error': 'Only the finder can accept claims'
                }, status=status.HTTP_403_FORBIDDEN)

            # Verify claim is still pending
            if claim.status != 'pending':
                return Response({
                    'success': False,
                    'error': f'This claim has already been {claim.status}'
                }, status=status.HTTP_400_BAD_REQUEST)

            # Accept the claim
            claim.accept_claim(request.user)

            # Create notification for claimant
            Notification.objects.create(
                user=claim.claimant,
                title="Claim Accepted! 🎉",
                message=f"Your claim for '{claim.item.title}' has been accepted. The finder will contact you soon.",
                notification_type='claim_accepted',
                claim=claim
            )

            return Response({
                'success': True,
                'message': 'Claim accepted successfully',
                'claim': ClaimRequestSerializer(claim).data
            })

        except ClaimRequest.DoesNotExist:
            return Response({
                'success': False,
                'error': 'Claim not found'
            }, status=status.HTTP_404_NOT_FOUND)


class RejectClaimView(APIView):
    """
    Reject a claim (only the finder can reject)
    """
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, claim_id):
        try:
            claim = ClaimRequest.objects.get(id=claim_id)

            # Verify the current user is the finder (item owner)
            if claim.item.user != request.user:
                return Response({
                    'success': False,
                    'error': 'Only the finder can reject claims'
                }, status=status.HTTP_403_FORBIDDEN)

            # Verify claim is still pending
            if claim.status != 'pending':
                return Response({
                    'success': False,
                    'error': f'This claim has already been {claim.status}'
                }, status=status.HTTP_400_BAD_REQUEST)

            reason = request.data.get('reason', '')

            # Reject the claim
            claim.reject_claim(request.user, reason)

            # Create notification for claimant
            Notification.objects.create(
                user=claim.claimant,
                title="Claim Rejected",
                message=f"Your claim for '{claim.item.title}' has been rejected. {reason if reason else 'The finder determined the item does not belong to you.'}",
                notification_type='claim_rejected',
                claim=claim
            )

            return Response({
                'success': True,
                'message': 'Claim rejected successfully',
                'claim': ClaimRequestSerializer(claim).data
            })

        except ClaimRequest.DoesNotExist:
            return Response({
                'success': False,
                'error': 'Claim not found'
            }, status=status.HTTP_404_NOT_FOUND)


class WithdrawClaimView(APIView):
    """
    Withdraw a claim (only the claimant can withdraw)
    """
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, claim_id):
        try:
            claim = ClaimRequest.objects.get(id=claim_id)

            # Verify the current user is the claimant
            if claim.claimant != request.user:
                return Response({
                    'success': False,
                    'error': 'Only the claimant can withdraw claims'
                }, status=status.HTTP_403_FORBIDDEN)

            # Can only withdraw pending claims
            if claim.status != 'pending':
                return Response({
                    'success': False,
                    'error': f'Cannot withdraw a claim that has been {claim.status}'
                }, status=status.HTTP_400_BAD_REQUEST)

            claim.status = 'withdrawn'
            claim.save()

            # Create notification for finder
            Notification.objects.create(
                user=claim.item.user,
                title="Claim Withdrawn",
                message=f"{claim.claimant.full_name} has withdrawn their claim for '{claim.item.title}'.",
                notification_type='claim_withdrawn',
                claim=claim
            )

            return Response({
                'success': True,
                'message': 'Claim withdrawn successfully'
            })

        except ClaimRequest.DoesNotExist:
            return Response({
                'success': False,
                'error': 'Claim not found'
            }, status=status.HTTP_404_NOT_FOUND)


class ItemClaimsView(generics.ListAPIView):
    """
    List all claims for a specific item (only accessible by item owner)
    """
    serializer_class = ClaimRequestSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        item_id = self.kwargs['item_id']
        return ClaimRequest.objects.filter(
            item_id=item_id,
            item__user=self.request.user
        )

    def get_serializer_context(self):
        context = super().get_serializer_context()
        context['request'] = self.request
        return context


# ============= NOTIFICATION VIEWS =============

class NotificationListView(generics.ListAPIView):
    """Get user notifications"""
    serializer_class = NotificationSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return Notification.objects.filter(user=self.request.user)

    def list(self, request, *args, **kwargs):
        queryset = self.get_queryset()

        # Mark notifications as seen when fetched
        queryset.filter(is_seen=False).update(is_seen=True)

        serializer = self.get_serializer(queryset, many=True)
        unread_count = queryset.filter(is_read=False).count()

        return Response({
            'notifications': serializer.data,
            'unread_count': unread_count
        })


class NotificationDetailView(generics.RetrieveUpdateAPIView):
    """Mark notification as read"""
    serializer_class = NotificationSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return Notification.objects.filter(user=self.request.user)

    def perform_update(self, serializer):
        serializer.save(is_read=True)


class MarkNotificationReadView(APIView):
    """Mark a specific notification as read"""
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, notification_id):
        try:
            notification = Notification.objects.get(
                id=notification_id,
                user=request.user
            )
            notification.is_read = True
            notification.save()
            return Response({'success': True})
        except Notification.DoesNotExist:
            return Response({
                'success': False,
                'error': 'Notification not found'
            }, status=status.HTTP_404_NOT_FOUND)


class MarkAllNotificationsReadView(APIView):
    """Mark all notifications as read"""
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        Notification.objects.filter(
            user=request.user,
            is_read=False
        ).update(is_read=True)

        return Response({
            'success': True,
            'message': 'All notifications marked as read'
        })


class UnreadNotificationCountView(APIView):
    """Get unread notification count"""
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        count = Notification.objects.filter(
            user=request.user,
            is_read=False
        ).count()

        return Response({'unread_count': count})