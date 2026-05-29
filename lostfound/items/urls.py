from django.urls import path
from .views import (
    CategoryListView,
    LostItemListCreateView,
    LostItemDetailView,
    FoundItemListCreateView,
    FoundItemDetailView,
    MyItemsView,
    SearchItemsView,
    CreateClaimView,
    MyClaimsView,
    ItemClaimsView,
    NotificationListView,
    NotificationDetailView,
    MarkAllNotificationsReadView,
    UnreadNotificationCountView,
    CreateClaimView,
    MyClaimsView,
    ClaimsOnMyItemsView,
    ClaimDetailView,
    AcceptClaimView,
    RejectClaimView,
    WithdrawClaimView,
    NotificationListView,
    MarkNotificationReadView,
    UnreadNotificationCountView,
)

urlpatterns = [
    # Categories
    path('categories/', CategoryListView.as_view(), name='categories'),

    # Lost Items
    path('lost-items/', LostItemListCreateView.as_view(), name='lost-items'),
    path('lost-items/<int:pk>/', LostItemDetailView.as_view(), name='lost-item-detail'),

    # Found Items
    path('found-items/', FoundItemListCreateView.as_view(), name='found-items'),
    path('found-items/<int:pk>/', FoundItemDetailView.as_view(), name='found-item-detail'),

    # My Items
    path('my-items/', MyItemsView.as_view(), name='my-items'),

    # Search
    path('search/', SearchItemsView.as_view(), name='search-items'),

    # Claims
    path('create-claim/', CreateClaimView.as_view(), name='create-claim'),
    path('my-claims/', MyClaimsView.as_view(), name='my-claims'),
    path('item-claims/<int:item_id>/', ItemClaimsView.as_view(), name='item-claims'),
    path('notifications/', NotificationListView.as_view(), name='notifications'),
    path('notifications/<int:pk>/', NotificationDetailView.as_view(), name='notification-detail'),
    path('notifications/mark-all-read/', MarkAllNotificationsReadView.as_view(), name='mark-all-read'),
    path('notifications/unread-count/', UnreadNotificationCountView.as_view(), name='unread-count'),
    path('create-claim/', CreateClaimView.as_view(), name='create-claim'),
    path('my-claims/', MyClaimsView.as_view(), name='my-claims'),
    path('claims-on-my-items/', ClaimsOnMyItemsView.as_view(), name='claims-on-my-items'),
    path('claims/<int:pk>/', ClaimDetailView.as_view(), name='claim-detail'),
    path('claims/<int:claim_id>/accept/', AcceptClaimView.as_view(), name='accept-claim'),
    path('claims/<int:claim_id>/reject/', RejectClaimView.as_view(), name='reject-claim'),
    path('claims/<int:claim_id>/withdraw/', WithdrawClaimView.as_view(), name='withdraw-claim'),

    # Notification URLs
    path('notifications/', NotificationListView.as_view(), name='notifications'),
    path('notifications/<int:notification_id>/read/', MarkNotificationReadView.as_view(),
         name='mark-notification-read'),
    path('notifications/unread-count/', UnreadNotificationCountView.as_view(), name='unread-count'),
]