import 'package:flutter/material.dart';
import 'package:lris/services/api_service.dart';
import 'package:lris/models/notification.dart';

class NotificationProvider with ChangeNotifier {
  List<NotificationModel> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  String? _error;

  final ApiService _apiService = ApiService();

  List<NotificationModel> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Fetch all notifications
  Future<void> fetchNotifications() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.getNotifications();

      if (response['success']) {
        final data = response['data'];
        if (data is Map && data.containsKey('notifications')) {
          _notifications = (data['notifications'] as List)
              .map((n) => NotificationModel.fromJson(n))
              .toList();
          _unreadCount = data['unread_count'] ?? 0;
        } else {
          _error = 'Invalid notification data format';
        }
      } else {
        _error = response['error'] ?? 'Failed to fetch notifications';
      }
    } catch (e) {
      _error = 'Error fetching notifications: $e';
      print('❌ Notification fetch error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Mark a single notification as read
  Future<void> markAsRead(int notificationId) async {
    try {
      final response = await _apiService.markNotificationAsRead(notificationId);

      if (response['success']) {
        // Update local state
        final index = _notifications.indexWhere((n) => n.id == notificationId);
        if (index != -1) {
          final notification = _notifications[index];
          _notifications[index] = NotificationModel(
            id: notification.id,
            title: notification.title,
            message: notification.message,
            notificationType: notification.notificationType,
            isRead: true,
            isSeen: notification.isSeen,
            createdAt: notification.createdAt,
            timeAgo: notification.timeAgo,
            claimId: notification.claimId,
            claimDetails: notification.claimDetails,
            relatedId: notification.relatedId,
          );

          // Update unread count
          _unreadCount = _notifications.where((n) => !n.isRead).length;
          notifyListeners();
        }
      }
    } catch (e) {
      print('❌ Error marking notification as read: $e');
    }
  }

  // Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      final response = await _apiService.markAllNotificationsAsRead();

      if (response['success']) {
        // Mark all as read locally
        for (int i = 0; i < _notifications.length; i++) {
          final notification = _notifications[i];
          _notifications[i] = NotificationModel(
            id: notification.id,
            title: notification.title,
            message: notification.message,
            notificationType: notification.notificationType,
            isRead: true,
            isSeen: notification.isSeen,
            createdAt: notification.createdAt,
            timeAgo: notification.timeAgo,
            claimId: notification.claimId,
            claimDetails: notification.claimDetails,
            relatedId: notification.relatedId,
          );
        }
        _unreadCount = 0;
        notifyListeners();
      }
    } catch (e) {
      print('❌ Error marking all as read: $e');
    }
  }

  // Refresh unread count
  Future<void> refreshUnreadCount() async {
    try {
      final response = await _apiService.getUnreadCount();

      if (response['success']) {
        final data = response['data'];
        if (data is Map) {
          _unreadCount = data['unread_count'] ?? 0;
          notifyListeners();
        }
      }
    } catch (e) {
      print('❌ Error refreshing unread count: $e');
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}