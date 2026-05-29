import 'package:flutter/material.dart';
import 'package:lris/services/api_service.dart';
import 'package:lris/models/claim.dart';
import 'package:lris/models/notification.dart';

class ClaimProvider with ChangeNotifier {
  List<Claim> _myClaims = []; // Claims I made
  List<Claim> _claimsOnMyItems = []; // Claims on my found items
  List<NotificationModel> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  String? _error;

  final ApiService _apiService = ApiService();

  List<Claim> get myClaims => _myClaims;
  List<Claim> get claimsOnMyItems => _claimsOnMyItems;
  List<NotificationModel> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Fetch claims made by current user
  Future<void> fetchMyClaims() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.getMyClaims();

      if (response['success']) {
        final data = response['data'];
        if (data is List) {
          _myClaims = data.map((c) => Claim.fromJson(c)).toList();
        }
      } else {
        _error = response['error'];
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch claims on items I found
  Future<void> fetchClaimsOnMyItems() async {
    _isLoading = true;
    notifyListeners();

    try {
      print('🔍 Provider: Fetching claims on my items...');
      final response = await _apiService.getClaimsOnMyItems();

      print('📊 Provider Response: $response');

      if (response['success']) {
        final data = response['data'];
        print('📊 Provider data type: ${data.runtimeType}');

        if (data is List) {
          _claimsOnMyItems = data.map((c) => Claim.fromJson(c)).toList();
          print('✅ Provider: Loaded ${_claimsOnMyItems.length} claims');
        } else {
          print('❌ Provider: Data is not a List, it is ${data.runtimeType}');
          _claimsOnMyItems = [];
        }
      } else {
        _error = response['error'] ?? 'Failed to fetch claims';
        print('❌ Provider error: $_error');
      }
    } catch (e) {
      _error = e.toString();
      print('❌ Provider exception: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create a claim
  Future<bool> createClaim({
    required int itemId,
    required String description,
    String? additionalInfo,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = {
        'item': itemId,
        'description': description,
        'additional_info': additionalInfo ?? '',
      };

      final response = await _apiService.createClaim(data);

      _isLoading = false;

      if (response['success']) {
        await fetchMyClaims();
        return true;
      } else {
        _error = response['error'];
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Accept a claim (finder only)
  Future<bool> acceptClaim(int claimId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.acceptClaim(claimId);

      _isLoading = false;

      if (response['success']) {
        await fetchClaimsOnMyItems();
        await fetchNotifications();
        return true;
      } else {
        _error = response['error'];
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Reject a claim (finder only)
  Future<bool> rejectClaim(int claimId, {String reason = ''}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.rejectClaim(claimId, reason: reason);

      _isLoading = false;

      if (response['success']) {
        await fetchClaimsOnMyItems();
        await fetchNotifications();
        return true;
      } else {
        _error = response['error'];
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Withdraw a claim (claimant only)
  Future<bool> withdrawClaim(int claimId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.withdrawClaim(claimId);

      _isLoading = false;

      if (response['success']) {
        await fetchMyClaims();
        return true;
      } else {
        _error = response['error'];
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Notification methods
  Future<void> fetchNotifications() async {
    try {
      final response = await _apiService.getNotifications();

      if (response['success']) {
        final data = response['data'];
        _notifications = (data['notifications'] as List)
            .map((n) => NotificationModel.fromJson(n))
            .toList();
        _unreadCount = data['unread_count'] ?? 0;
        notifyListeners();
      }
    } catch (e) {
      print('Error fetching notifications: $e');
    }
  }

  Future<void> markNotificationAsRead(int notificationId) async {
    try {
      await _apiService.markNotificationAsRead(notificationId);
      await fetchNotifications();
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  Future<void> refreshUnreadCount() async {
    try {
      final response = await _apiService.getUnreadCount();
      if (response['success']) {
        _unreadCount = response['data']['unread_count'] ?? 0;
        notifyListeners();
      }
    } catch (e) {
      print('Error refreshing unread count: $e');
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}