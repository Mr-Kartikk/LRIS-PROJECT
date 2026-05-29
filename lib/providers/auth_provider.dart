import 'package:flutter/material.dart';
import 'package:lris/models/user.dart';
import 'package:lris/services/api_service.dart';
import 'package:lris/services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  String? _token;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  String? get token => _token;  // ADD THIS GETTER
  bool get isAuthenticated => _token != null;
  bool get isLoading => _isLoading;
  String? get error => _error;

  final ApiService _apiService = ApiService();

  // Call this when app starts
  Future<void> loadUser() async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await AuthService.getToken();
      final userData = await AuthService.getUser();

      if (token != null && userData != null) {
        _token = token;
        _user = User.fromJson(userData);
        print('✅ User loaded from storage: ${_user?.fullName}');
      } else {
        print('ℹ️ No stored user found');
      }
    } catch (e) {
      print('❌ Error loading user: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String phoneNumber, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('🔐 Attempting login for: $phoneNumber');
      final response = await _apiService.login(phoneNumber, password);
      print('📥 Login response: $response');

      if (response['success']) {
        final data = response['data'];
        print('📦 Response data: $data');

        // ✅ FIX: Django returns 'token' not 'key'
        final String? token = data['token'];

        if (token != null && token.isNotEmpty) {
          _token = token;
          print('✅ Token received: ${_token!.substring(0, 10)}...');

          // Save token to SharedPreferences
          await AuthService.saveToken(_token!);
          print('✅ Token saved to SharedPreferences');

          // Handle user data
          if (data['user'] != null) {
            _user = User.fromJson(data['user']);
            await AuthService.saveUser(data['user']);
            print('✅ User saved: ${_user?.fullName}');
          } else {
            // If user data not in login response, fetch profile
            await _fetchProfile();
          }

          _isLoading = false;
          notifyListeners();
          return true;
        } else {
          _error = 'Token not found in response';
          print('❌ $_error - response data: $data');
          _isLoading = false;
          notifyListeners();
          return false;
        }
      } else {
        _error = response['error'] ?? 'Login failed';
        print('❌ Login failed: $_error');
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Login error: $e';
      print('❌ Login exception: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> _fetchProfile() async {
    try {
      final response = await _apiService.getProfile();
      if (response['success'] && response['data'] != null) {
        _user = User.fromJson(response['data']);
        await AuthService.saveUser(response['data']);
        print('✅ Profile fetched and saved');
      }
    } catch (e) {
      print('❌ Error fetching profile: $e');
    }
  }

  Future<bool> register(Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('📝 Attempting registration for: ${data['phone_number']}');
      final response = await _apiService.register(data);
      print('📥 Register response: $response');

      if (response['success']) {
        final responseData = response['data'];

        // Some APIs return token on register
        final String? token = responseData['token'];

        if (token != null) {
          _token = token;
          await AuthService.saveToken(_token!);
          print('✅ Token saved from registration');

          if (responseData['user'] != null) {
            _user = User.fromJson(responseData['user']);
            await AuthService.saveUser(responseData['user']);
            print('✅ User saved from registration');
          }
        }

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response['error'] ?? 'Registration failed';
        print('❌ Registration failed: $_error');
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Registration error: $e';
      print('❌ Registration exception: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    try {
      print('🚪 Logging out...');
      await _apiService.logout();
    } catch (e) {
      print('❌ Logout API error: $e');
    } finally {
      await AuthService.clearAuthData();
      _user = null;
      _token = null;
      print('✅ Logout complete');
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.updateProfile(data);
      print('📥 Update profile response: $response');

      if (response['success']) {
        final userData = response['data']['user'];
        if (userData != null) {
          _user = User.fromJson(userData);
          await AuthService.saveUser(userData);
          print('✅ Profile updated');
        }
        _isLoading = false;
        notifyListeners();
      } else {
        _error = response['error'] ?? 'Failed to update profile';
        print('❌ Profile update failed: $_error');
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      _error = 'Update error: $e';
      print('❌ Profile update exception: $e');
      _isLoading = false;
      notifyListeners();
    }
  }
}