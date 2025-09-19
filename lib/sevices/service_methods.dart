import 'package:phf/models/items.dart';
import 'package:phf/models/navigation_category.dart';
import 'package:phf/sevices/database_service.dart';
import 'package:firebase_storage/firebase_storage.dart';

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

// Get navigation categories for the top navigation bar
Future<List<NavigationCategory>> getNavigationCategories() async {
  try {
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
        // Add category with placeholder if image fails to load
        categories.add(NavigationCategory(
          id: categoryFile,
          name: _getCategoryDisplayName(categoryFile),
          image: '', // Empty string will trigger error fallback in UI
          route: '/category/$categoryFile',
        ));
      }
    }
    
    return categories;
  } catch (e) {
    print('Error fetching navigation categories: $e');
    return [];
  }
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