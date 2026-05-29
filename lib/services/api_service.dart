import 'dart:convert';
//import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // static String get baseUrl {
  //static const String baseUrl = 'http://192.168.1.12:8000/api';
  static const String baseUrl = 'http://127.0.0.1:8000/api';

  //   if (Platform.isAndroid) {
  //     return 'http://10.0.2.2:8000/api';
  //   }
  //   return 'http://localhost:8000/api';
  // }

  Future<Map<String, String>> getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    print("🔑 TOKEN FROM PREFS: $token");

    Map<String, String> headers = {'Content-Type': 'application/json'};

    if (token != null) {
      headers['Authorization'] = 'Token $token';
    }

    return headers;
  }

  // Auth endpoints
  Future<Map<String, dynamic>> login(String phoneNumber, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'phone_number': phoneNumber, 'password': password}),
      );

      return handleResponse(response);
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );

      return handleResponse(response);
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> logout() async {
    try {
      final headers = await getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/auth/logout/'),
        headers: headers,
      );

      return handleResponse(response);
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> getProfile() async {
    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/auth/profile/'),
        headers: headers,
      );

      return handleResponse(response);
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    try {
      final headers = await getHeaders();
      final response = await http.patch(
        Uri.parse('$baseUrl/auth/profile/'),
        headers: headers,
        body: json.encode(data),
      );

      return handleResponse(response);
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> sendChatbotQuery(String message) async {
    try {
      final headers = await getHeaders();
      headers['Content-Type'] = 'application/json';
      final response = await http.post(
        Uri.parse('$baseUrl/chat/query/'),
        headers: headers,
        body: json.encode({'message': message}),
      );
      return handleResponse(response);
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  // Items endpoints
  Future<Map<String, dynamic>> getLostItems() async {
    try {
      print('🔍 Fetching lost items from: $baseUrl/items/lost-items/');
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/items/lost-items/'),
        headers: headers,
      );

      return handleResponse(response);
    } catch (e){
      print('❌ Network error in getLostItems: $e');
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> getFoundItems() async {
    try {
      print('🔍 Fetching found items from: $baseUrl/items/found-items/');
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/items/found-items/'),
        headers: headers,
      );

      print('📥 Found items response status: ${response.statusCode}');

      return handleResponse(response);
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> getMyItems() async {
    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/items/my-items/'),
        headers: headers,
      );

      return handleResponse(response);
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> searchItems(String query, {String type = 'both'}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/items/search/?q=$query&type=$type'),
      );

      return handleResponse(response);
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> createLostItem(Map<String, dynamic> data, dynamic image) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/items/lost-items/'),
      );

      final headers = await getHeaders();
      request.headers.addAll(headers);

      request.fields['title'] = data['title'];
      request.fields['description'] = data['description'];
      request.fields['location_name'] = data['location_name'];
      request.fields['lost_date'] = data['lost_date'];
      if (data['brand'] != null) request.fields['brand'] = data['brand'];
      if (data['color'] != null) request.fields['color'] = data['color'];
      if (data['category'] != null) {
        request.fields['category'] = data['category'].toString();
      }

      if (image != null) {
        if (kIsWeb) {
          // Web platform - image is a web file
          final bytes = await image.readAsBytes();
          final multipartFile = http.MultipartFile.fromBytes(
            'image',
            bytes,
            filename: 'image.jpg',
            contentType: MediaType('image', 'jpeg'),
          );
          request.files.add(multipartFile);
        } else {
          // Mobile platform - image is a File
          request.files.add(
            await http.MultipartFile.fromPath('image', image.path),
          );
        }
      }

      final response = await request.send();
      final responseData = await http.Response.fromStream(response);

      return handleResponse(responseData);
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> createFoundItem(Map<String, dynamic> data, dynamic image,) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/items/found-items/'),
      );

      final headers = await getHeaders();
      request.headers.addAll(headers);

      request.fields['title'] = data['title'];
      request.fields['description'] = data['description'];
      request.fields['location_name'] = data['location_name'];
      request.fields['current_location'] = data['current_location'];
      request.fields['found_date'] = data['found_date'];
      if (data['brand'] != null) request.fields['brand'] = data['brand'];
      if (data['color'] != null) request.fields['color'] = data['color'];
      if (data['category'] != null) {
        request.fields['category'] = data['category'].toString();
      }

      if (image != null) {
        if (kIsWeb) {
          // Web platform - image is a web file
          final bytes = await image.readAsBytes();
          final multipartFile = http.MultipartFile.fromBytes(
            'image',
            bytes,
            filename: 'image.jpg',
            contentType: MediaType('image', 'jpeg'),
          );
          request.files.add(multipartFile);
        } else {
          // Mobile platform - image is a File
          request.files.add(
            await http.MultipartFile.fromPath('image', image.path),
          );
        }
      }
      final response = await request.send();
      final responseData = await http.Response.fromStream(response);

      return handleResponse(responseData);
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> getCategories() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/items/categories/'));
      return handleResponse(response);
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  // ============= CLAIM ENDPOINTS =============

  /// Create a new claim for a found item
  Future<Map<String, dynamic>> createClaim(Map<String, dynamic> data) async {
    try {
      final headers = await getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/items/create-claim/'),
        headers: headers,
        body: json.encode(data),
      );
      return handleResponse(response);
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  /// Get all claims made by the current user
  Future<Map<String, dynamic>> getMyClaims() async {
    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/items/my-claims/'),
        headers: headers,
      );
      return handleResponse(response);
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  /// Get all claims on items the current user found
  Future<Map<String, dynamic>> getClaimsOnMyItems() async {
    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/items/claims-on-my-items/'),
        headers: headers,
      );
      return handleResponse(response);
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  /// Get details of a specific claim
  Future<Map<String, dynamic>> getClaimDetails(int claimId) async {
    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/items/claims/$claimId/'),
        headers: headers,
      );
      return handleResponse(response);
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  /// Accept a claim (only the finder can do this)
  Future<Map<String, dynamic>> acceptClaim(int claimId) async {
    try {
      final headers = await getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/items/claims/$claimId/accept/'),
        headers: headers,
      );
      return handleResponse(response);
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  /// Reject a claim (only the finder can do this)
  Future<Map<String, dynamic>> rejectClaim(int claimId, {String reason = ''}) async {
    try {
      final headers = await getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/items/claims/$claimId/reject/'),
        headers: headers,
        body: json.encode({'reason': reason}),
      );
      return handleResponse(response);
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  /// Withdraw a claim (only the claimant can do this)
  Future<Map<String, dynamic>> withdrawClaim(int claimId) async {
    try {
      final headers = await getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/items/claims/$claimId/withdraw/'),
        headers: headers,
      );
      return handleResponse(response);
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  /// Get all claims for a specific item
  Future<Map<String, dynamic>> getItemClaims(int itemId) async {
    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/items/item-claims/$itemId/'),
        headers: headers,
      );
      return handleResponse(response);
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  // ============= NOTIFICATION ENDPOINTS =============

  /// Get all notifications for current user
  Future<Map<String, dynamic>> getNotifications() async {
    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/items/notifications/'),
        headers: headers,
      );
      return handleResponse(response);
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  /// Mark a specific notification as read
  Future<Map<String, dynamic>> markNotificationAsRead(int notificationId) async {
    try {
      final headers = await getHeaders();
      final response = await http.patch(
        Uri.parse('$baseUrl/items/notifications/$notificationId/'),
        headers: headers,
        body: json.encode({'is_read': true}),
      );
      return handleResponse(response);
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  /// Mark all notifications as read
  Future<Map<String, dynamic>> markAllNotificationsAsRead() async {
    try {
      final headers = await getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/items/notifications/mark-all-read/'),
        headers: headers,
      );
      return handleResponse(response);
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  /// Get unread notification count
  Future<Map<String, dynamic>> getUnreadCount() async {
    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/items/notifications/unread-count/'),
        headers: headers,
      );
      return handleResponse(response);
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  // Helper method
  Map<String, dynamic> handleResponse(http.Response response) {
    final statusCode = response.statusCode;
    final responseBody = response.body;

    try {
      final jsonResponse = json.decode(responseBody);
      print('📥 Response status: $statusCode');
      print('📥 Response type: ${jsonResponse.runtimeType}');

      if (statusCode >= 200 && statusCode < 300) {
        // Check if response is paginated (has 'results' field)
        if (jsonResponse is Map && jsonResponse.containsKey('results')) {
          // ✅ PAGINATED RESPONSE - EXTRACT THE RESULTS ARRAY
          print('✅ Detected paginated response with ${jsonResponse['results'].length} items');
          return {
            'success': true,
            'data': jsonResponse['results'],  // Extract the results array
            'total_count': jsonResponse['count'],
            'next': jsonResponse['next'],
            'previous': jsonResponse['previous'],
          };
        } else if (jsonResponse is List) {
          // ✅ DIRECT ARRAY RESPONSE
          print('✅ Detected direct array response with ${jsonResponse.length} items');
          return {
            'success': true,
            'data': jsonResponse,
          };
        } else {
          // ✅ SINGLE OBJECT RESPONSE
          print('✅ Detected single object response');
          return {
            'success': true,
            'data': jsonResponse,
          };
        }
      } else {
        // Error handling
        String errorMsg = 'Request failed';

        if (jsonResponse is Map) {
          if (jsonResponse.containsKey('detail')) {
            errorMsg = jsonResponse['detail'].toString();
          } else if (jsonResponse.containsKey('error')) {
            errorMsg = jsonResponse['error'].toString();
          } else if (jsonResponse.containsKey('message')) {
            errorMsg = jsonResponse['message'].toString();
          }
        }

        return {
          'success': false,
          'error': errorMsg,
          'data': jsonResponse,
        };
      }
    } catch (e) {
      print('❌ Error parsing response: $e');
      return {
        'success': false,
        'error': 'Failed to parse response: $e',
        'raw_body': responseBody.length > 200 ? '${responseBody.substring(0, 200)}...' : responseBody,
      };
    }
  }
}