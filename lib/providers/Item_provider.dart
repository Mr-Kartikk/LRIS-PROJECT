import 'package:flutter/material.dart';
import 'dart:io';
import 'package:lris/models/lost_item.dart';
import 'package:lris/models/found_item.dart';
import 'package:lris/services/api_service.dart';

class ItemProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  // All items (global feed)
  List<LostItem> _allLostItems = [];
  List<FoundItem> _allFoundItems = [];

  // User's items
  List<LostItem> _myLostItems = [];
  List<FoundItem> _myFoundItems = [];

  // Categories
  List<dynamic> _categories = [];

  // Matches
  final List<Map<String, dynamic>> _potentialMatches = [];

  // State
  bool _isLoading = false;
  String? _error;

  // Getters
  List<LostItem> get allLostItems => _allLostItems;
  List<FoundItem> get allFoundItems => _allFoundItems;
  List<LostItem> get myLostItems => _myLostItems;
  List<FoundItem> get myFoundItems => _myFoundItems;
  List<dynamic> get categories => _categories;
  List<Map<String, dynamic>> get potentialMatches => _potentialMatches;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // ============= FETCH ALL ITEMS (GLOBAL FEED) =============

  Future<void> fetchAllLostItems() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.getLostItems();
      print('📦 Lost items provider response: $response');

      if (response['success']) {
        final data = response['data'] as List;
        _allLostItems = data.map((item) => LostItem.fromJson(item)).toList();
        print('✅ Loaded ${_allLostItems.length} lost items');
      } else {
        _error = response['error'];
        print('❌ Error in fetchAllLostItems: ${response['error']}');
      }
    } catch (e) {
      _error = e.toString();
      print('❌ Exception in fetchAllLostItems: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAllFoundItems() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.getFoundItems();
      print('📦 Found items provider response: $response');

      if (response['success']) {
        final data = response['data'] as List;
        _allFoundItems = data.map((item) => FoundItem.fromJson(item)).toList();
        print('✅ Loaded ${_allFoundItems.length} found items');
      } else {
        _error = response['error'];
        print('❌ Error in fetchAllFoundItems: ${response['error']}');
      }
    } catch (e) {
      _error = e.toString();
      print('❌ Exception in fetchAllFoundItems: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ============= FETCH USER'S ITEMS =============

  Future<void> fetchMyItems() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.getMyItems();

      if (response['success']) {
        final data = response['data'];
        _myLostItems = (data['lost_items'] as List)
            .map((item) => LostItem.fromJson(item))
            .toList();
        _myFoundItems = (data['found_items'] as List)
            .map((item) => FoundItem.fromJson(item))
            .toList();

        // After fetching user's items, find potential matches
        _findPotentialMatches();
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

  // ============= FIND POTENTIAL MATCHES =============

  void _findPotentialMatches() {
    _potentialMatches.clear();

    // Match my lost items with all found items
    for (var lostItem in _myLostItems) {
      for (var foundItem in _allFoundItems) {
        if (_isMatch(lostItem, foundItem)) {
          _potentialMatches.add({
            'type': 'lost_to_found',
            'myItem': lostItem,
            'matchedItem': foundItem,
            'score': _calculateMatchScore(lostItem, foundItem),
            'message': 'Your lost "${lostItem.title}" matches a found item!'
          });
        }
      }
    }

    // Match my found items with all lost items
    for (var foundItem in _myFoundItems) {
      for (var lostItem in _allLostItems) {
        if (_isMatch(lostItem, foundItem)) {
          _potentialMatches.add({
            'type': 'found_to_lost',
            'myItem': foundItem,
            'matchedItem': lostItem,
            'score': _calculateMatchScore(lostItem, foundItem),
            'message': 'Your found "${foundItem.title}" matches someone\'s lost item!'
          });
        }
      }
    }

    // Sort by match score (highest first)
    _potentialMatches.sort((a, b) => b['score'].compareTo(a['score']));

    notifyListeners();
  }

  bool _isMatch(LostItem lost, FoundItem found) {
    // Skip if same user
    if (lost.user != null && found.user != null) {
      if (lost.user!['id'] == found.user!['id']) return false;
    }


    // Skip if items are already resolved
    if (lost.status != 'pending' || found.status != 'pending') return false;

    // Calculate match score
    double score = _calculateMatchScore(lost, found);

    // Return true if score is above threshold (60%)
    return score >= 0.6;
  }

  double _calculateMatchScore(LostItem lost, FoundItem found) {
    double totalScore = 0;
    int criteriaCount = 0;

    // Category match (30% weight)
    if (lost.category != null && found.category != null) {
      if (lost.category == found.category) {
        totalScore += 0.3;
      }
      criteriaCount++;
    }

    // Title similarity (25% weight)
    if (lost.title.isNotEmpty && found.title.isNotEmpty) {
      double similarity = _textSimilarity(
          lost.title.toLowerCase(),
          found.title.toLowerCase()
      );
      totalScore += similarity * 0.25;
      criteriaCount++;
    }

    // Brand match (20% weight)
    if (lost.brand != null && found.brand != null &&
        lost.brand!.isNotEmpty && found.brand!.isNotEmpty) {
      if (lost.brand!.toLowerCase() == found.brand!.toLowerCase()) {
        totalScore += 0.2;
      }
      criteriaCount++;
    }

    // Color match (15% weight)
    if (lost.color != null && found.color != null &&
        lost.color!.isNotEmpty && found.color!.isNotEmpty) {
      if (lost.color!.toLowerCase() == found.color!.toLowerCase()) {
        totalScore += 0.15;
      }
      criteriaCount++;
    }

    // Location similarity (10% weight)
    if (lost.locationName.isNotEmpty && found.locationName.isNotEmpty) {
      double locationSim = _textSimilarity(
          lost.locationName.toLowerCase(),
          found.locationName.toLowerCase()
      );
      totalScore += locationSim * 0.1;
      criteriaCount++;
    }

    return criteriaCount > 0 ? totalScore : 0;
  }

  double _textSimilarity(String text1, String text2) {
    if (text1 == text2) return 1.0;
    if (text1.contains(text2) || text2.contains(text1)) return 0.8;

    // Simple word matching
    Set<String> words1 = text1.split(' ').toSet();
    Set<String> words2 = text2.split(' ').toSet();

    if (words1.isEmpty || words2.isEmpty) return 0.0;

    int commonWords = words1.intersection(words2).length;
    int totalWords = words1.union(words2).length;

    return commonWords / totalWords;
  }

  // ============= CREATE ITEMS =============

  Future<bool> createLostItem({
    required String title,
    required String description,
    required String location,
    required DateTime lostDate,
    String? brand,
    String? color,
    int? category,
    File? image,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = {
        'title': title,
        'description': description,
        'location_name': location,
        'lost_date': lostDate.toIso8601String(),
        'brand': brand,
        'color': color,
        'category': category,
      };

      final response = await _apiService.createLostItem(data, image);

      _isLoading = false;

      if (response['success']) {
        await fetchAllLostItems();
        await fetchMyItems(); // This will trigger matching
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

  Future<bool> createFoundItem({
    required String title,
    required String description,
    required String location,
    required String currentLocation,
    required DateTime foundDate,
    String? brand,
    String? color,
    int? category,
    File? image,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = {
        'title': title,
        'description': description,
        'location_name': location,
        'current_location': currentLocation,
        'found_date': foundDate.toIso8601String(),
        'brand': brand,
        'color': color,
        'category': category,
      };

      final response = await _apiService.createFoundItem(data, image);

      _isLoading = false;

      if (response['success']) {
        await fetchAllFoundItems();
        await fetchMyItems(); // This will trigger matching
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

  // ============= SEARCH =============

  Future<void> searchItems(String query) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.searchItems(query);

      if (response['success']) {
        final data = response['data'];

        if (data['lost_items'] != null) {
          _allLostItems = (data['lost_items'] as List)
              .map((item) => LostItem.fromJson(item))
              .toList();
        }

        if (data['found_items'] != null) {
          _allFoundItems = (data['found_items'] as List)
              .map((item) => FoundItem.fromJson(item))
              .toList();
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

  // ============= FETCH CATEGORIES =============

  Future<void> fetchCategories() async {
    try {
      final response = await _apiService.getCategories();
      if (response['success']) {
        _categories = response['data'] as List;
      }
    } catch (e) {
      print('Error fetching categories: $e');
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}