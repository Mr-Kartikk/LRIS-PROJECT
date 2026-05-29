class AppConstants {
  // API Constants
  static const String apiBaseUrl = 'http://10.0.2.2:8000/api';
  static const int apiTimeout = 30000;

  // App Constants
  static const String appName = 'Lost & Found';
  static const String appVersion = '1.0.0';

  // Shared Preferences Keys
  static const String prefToken = 'token';
  static const String prefUser = 'user';
  static const String prefFirstLaunch = 'first_launch';

  // Colors
  static const int primaryColor = 0xFF2196F3;
  static const int secondaryColor = 0xFF4CAF50;
  static const int accentColor = 0xFFFF9800;
  static const int errorColor = 0xFFF44336;
  static const int successColor = 0xFF4CAF50;
  static const int warningColor = 0xFFFF9800;

  // Status Colors
  static Map<String, int> statusColors = {
    'pending': 0xFFFF9800,
    'found': 0xFF4CAF50,
    'returned': 0xFF4CAF50,
    'closed': 0xFF9E9E9E,
    'donated': 0xFF2196F3,
    'disposed': 0xFFF44336,
  };

  // Messages
  static const String networkError = 'No internet connection';
  static const String serverError = 'Server error occurred';
  static const String unknownError = 'Something went wrong';

  static const String loginSuccess = 'Login successful';
  static const String registerSuccess = 'Registration successful';
  static const String logoutSuccess = 'Logged out successfully';

  static const String itemReportedSuccess = 'Item reported successfully';
  static const String itemUpdatedSuccess = 'Item updated successfully';
  static const String itemDeletedSuccess = 'Item deleted successfully';
}