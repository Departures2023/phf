import 'package:phf/models/items.dart';
import 'package:phf/models/navigation_category.dart';
import 'package:phf/sevices/database_service.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

Future<List<Items>> getHomePageContent() async {
  try {
    DatabaseService databaseService = DatabaseService();
    List<Items> items = await databaseService.getHomePageItems();
    return items;
  } catch (e) {
    print('Error fetching homepage content: $e');
    return [];
  }
}

// Get navigation categories for the top navigation bar with local caching
Future<List<NavigationCategory>> getNavigationCategories() async {
  try {
    // First, try to load from local cache
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? cachedCategoriesJson = prefs.getString('navigation_categories');
    final String? lastFetchTime = prefs.getString('categories_last_fetch');
    
    // Check if we have cached data and it's not too old (24 hours)
    if (cachedCategoriesJson != null && lastFetchTime != null) {
      final DateTime lastFetch = DateTime.parse(lastFetchTime);
      final DateTime now = DateTime.now();
      final Duration difference = now.difference(lastFetch);
      
      // If cached data is less than 24 hours old, use it
      if (difference.inHours < 24) {
        try {
          final List<dynamic> categoriesList = jsonDecode(cachedCategoriesJson);
          return categoriesList.map((json) => NavigationCategory.fromJson(json)).toList();
        } catch (e) {
          print('Error parsing cached categories: $e');
          // Fall through to fetch from Firebase
        }
      }
    }
    
    // Try to fetch from Firebase Storage first
    try {
      final List<NavigationCategory> categories = await _fetchCategoriesFromFirebase();
      
      // Cache the results
      if (categories.isNotEmpty) {
        final String categoriesJson = jsonEncode(categories.map((cat) => cat.toJson()).toList());
        await prefs.setString('navigation_categories', categoriesJson);
        await prefs.setString('categories_last_fetch', DateTime.now().toIso8601String());
      }
      
      return categories;
    } catch (e) {
      print('Error fetching from Firebase Storage: $e');
      // Fall back to static categories
      return _getStaticCategories();
    }
  } catch (e) {
    print('Error fetching navigation categories: $e');
    
    // Try to return cached data even if it's stale as fallback
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? cachedCategoriesJson = prefs.getString('navigation_categories');
      if (cachedCategoriesJson != null) {
        final List<dynamic> categoriesList = jsonDecode(cachedCategoriesJson);
        return categoriesList.map((json) => NavigationCategory.fromJson(json)).toList();
      }
    } catch (e) {
      print('Error loading fallback cached categories: $e');
    }
    
    // Final fallback to static categories
    return _getStaticCategories();
  }
}

// Fetch categories from Firebase Storage
Future<List<NavigationCategory>> _fetchCategoriesFromFirebase() async {
  final List<NavigationCategory> categories = [];
  
  // List of category file names in Firebase Storage
  final List<String> categoryFiles = [
    'class_item',
    'cloth', 
    'daily_necessities',
    'electronic_product',
    'food',
    'furnature',
    'house',
    'transportation'
  ];
  
  // Get download URLs for each category icon from Firebase Storage
  for (String categoryFile in categoryFiles) {
    try {
      // Reference to the file in Firebase Storage
      Reference ref = FirebaseStorage.instance
          .ref()
          .child('icon')
          .child('$categoryFile.png');
      
      // Get the download URL
      String downloadUrl = await ref.getDownloadURL();
      
      // Create category with proper display name
      String displayName = _getCategoryDisplayName(categoryFile);
      
      categories.add(NavigationCategory(
        id: categoryFile,
        name: displayName,
        image: downloadUrl, // This is the proper Firebase Storage download URL
        route: '/category/$categoryFile',
      ));
    } catch (e) {
      print('Error getting download URL for $categoryFile: $e');
      // Add category with empty image - UI will use fallback icons
      categories.add(NavigationCategory(
        id: categoryFile,
        name: _getCategoryDisplayName(categoryFile),
        image: '', // Empty string will trigger fallback icons in UI
        route: '/category/$categoryFile',
      ));
    }
  }
  
  return categories;
}

// Force refresh navigation categories from Firebase (bypasses cache)
Future<List<NavigationCategory>> refreshNavigationCategories() async {
  try {
    final List<NavigationCategory> categories = await _fetchCategoriesFromFirebase();
    
    // Update cache with fresh data
    if (categories.isNotEmpty) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String categoriesJson = jsonEncode(categories.map((cat) => cat.toJson()).toList());
      await prefs.setString('navigation_categories', categoriesJson);
      await prefs.setString('categories_last_fetch', DateTime.now().toIso8601String());
    }
    
    return categories;
  } catch (e) {
    print('Error refreshing navigation categories: $e');
    return [];
  }
}

// Clear navigation categories cache
Future<void> clearNavigationCategoriesCache() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.remove('navigation_categories');
  await prefs.remove('categories_last_fetch');
}

// Static categories fallback (doesn't require Firebase Storage)
List<NavigationCategory> _getStaticCategories() {
  return [
    NavigationCategory(
      id: 'class_item',
      name: 'Class Items',
      image: '', // Empty image will trigger fallback icons
      route: '/category/class_item',
    ),
    NavigationCategory(
      id: 'cloth',
      name: 'Clothing',
      image: '',
      route: '/category/cloth',
    ),
    NavigationCategory(
      id: 'daily_necessities',
      name: 'Daily Necessities',
      image: '',
      route: '/category/daily_necessities',
    ),
    NavigationCategory(
      id: 'electronic_product',
      name: 'Electronics',
      image: '',
      route: '/category/electronic_product',
    ),
    NavigationCategory(
      id: 'food',
      name: 'Food',
      image: '',
      route: '/category/food',
    ),
    NavigationCategory(
      id: 'furnature',
      name: 'Furniture',
      image: '',
      route: '/category/furnature',
    ),
    NavigationCategory(
      id: 'house',
      name: 'House',
      image: '',
      route: '/category/house',
    ),
    NavigationCategory(
      id: 'transportation',
      name: 'Transportation',
      image: '',
      route: '/category/transportation',
    ),
  ];
}

// Helper function to convert file names to display names
String _getCategoryDisplayName(String categoryFile) {
  switch (categoryFile) {
    case 'class_item':
      return 'Class Items';
    case 'cloth':
      return 'Clothing';
    case 'daily_necessities':
      return 'Daily Necessities';
    case 'electronic_product':
      return 'Electronics';
    case 'food':
      return 'Food';
    case 'furnature':
      return 'Furniture';
    case 'house':
      return 'House';
    case 'transportation':
      return 'Transportation';
    default:
      return categoryFile.replaceAll('_', ' ').split(' ').map((word) => 
        word[0].toUpperCase() + word.substring(1)).join(' ');
  }
}