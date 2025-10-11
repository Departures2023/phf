# PHF (Grinnell Student Marketplace) - App Architecture Diagram

## 🎯 Project Overview
**PHF** is a secondhand item selling app designed exclusively for Grinnell students, allowing them to buy and sell items ranging from small goods like dining dollars to larger items such as bicycles or secondhand cars.

## 🏗️ System Architecture

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                           PHF STUDENT MARKETPLACE APP                           │
│                              (Flutter Frontend)                                │
└─────────────────────────────────────────────────────────────────────────────────┘
                                        │
                                        ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│                              FIREBASE BACKEND                                   │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐                │
│  │   Firestore     │  │ Firebase Storage│  │ Firebase Auth   │                │
│  │   Database      │  │   (Images)      │  │   (Users)       │                │
│  │                 │  │                 │  │                 │                │
│  │ • Users         │  │ • Item Images   │  │ • Login/Logout  │                │
│  │ • Items         │  │ • Category Icons│  │ • Registration  │                │
│  │ • Transactions  │  │ • User Avatars  │  │ • Password Reset│                │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘                │
└─────────────────────────────────────────────────────────────────────────────────┘
```

## 📱 Flutter App Structure

### Main App Flow
```
main.dart (Entry Point)
    │
    ├── Firebase.initializeApp()
    ├── FirebaseFirestore.settings
    └── MyApp (MaterialApp)
            │
            └── Menu (Bottom Navigation)
                    │
                    ├── HomePage (Tab 0)
                    ├── CartPage (Tab 1) 
                    ├── SellPage (Tab 2)
                    └── ProfilePage (Tab 3)
```

### UI Components Hierarchy
```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                                MENU (Main Container)                            │
│  ┌─────────────────────────────────────────────────────────────────────────┐    │
│  │                           Bottom Navigation Bar                         │    │
│  │  [🏠 Home] [🛒 Cart] [📷 Sell] [👤 Profile]                            │    │
│  └─────────────────────────────────────────────────────────────────────────┘    │
│                                                                                 │
│  ┌─────────────────────────────────────────────────────────────────────────┐    │
│  │                            Current Page                                 │    │
│  │  ┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐ ┌─────────┐ │    │
│  │  │   HomePage      │ │   CartPage      │ │   SellPage      │ │Profile  │ │    │
│  │  │                 │ │                 │ │                 │ │Page     │ │    │
│  │  │ • TopNavBar     │ │ • Cart Items    │ │ • Item Form     │ │• Header │ │    │
│  │  │ • Item Grid     │ │ • Checkout      │ │ • Image Upload  │ │• Tabs   │ │    │
│  │  │ • Categories    │ │ • Payment       │ │ • Price Input   │ │• Lists  │ │    │
│  │  └─────────────────┘ └─────────────────┘ └─────────────────┘ └─────────┘ │    │
│  └─────────────────────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────────────────────┘
```

## 🗂️ Data Models

### Users Model
```dart
class Users {
  int userId;           // Unique user identifier
  String name;          // User's display name
  String password;      // User's password (encrypted)
  String email;         // User's email address
  String avatar;        // Profile picture URL
  double buyerCredit;   // Rating as buyer (0-5)
  double sellerCredit;  // Rating as seller (0-5)
  List<int> itemSold;   // List of sold item IDs
  List<int> itemBought; // List of bought item IDs
}
```

### Items Model
```dart
class Items {
  int itemId;           // Unique item identifier
  String itemName;      // Item title/name
  String image;         // Item image URL
  double price;         // Item price
  String category;      // Item category
  Timestamp launchTime; // When item was posted
  String sellerId;      // ID of user selling item
  String? buyerId;      // ID of user who bought item
  bool isSold;          // Whether item is sold
}
```

### NavigationCategory Model
```dart
class NavigationCategory {
  String id;            // Category identifier
  String name;          // Category display name
  String image;         // Category icon URL
  String? route;        // Navigation route
}
```

## 🎨 UI Features

### HomePage Features
- **Top Navigation Bar**: Category-based navigation (8 categories)
  - Class Items, Clothing, Daily Necessities, Electronics
  - Food, Furniture, House, Transportation
- **Item Grid**: 2-column grid showing available items
- **Item Cards**: Display item image, name, and price
- **Real-time Updates**: Firebase integration for live data

### ProfilePage Features
- **User Header**: Avatar, name, ratings, item counts
- **Tabbed Interface**: 
  - Currently Selling
  - Items Sold
  - Items Bought
- **Rating System**: Separate buyer/seller credit scores
- **Transaction History**: Track of all user activities

### CartPage & SellPage
- **CartPage**: Shopping cart functionality (placeholder)
- **SellPage**: Item listing creation (placeholder)

## 🔧 Services & Backend Integration

### DatabaseService
```dart
class DatabaseService {
  // Firestore Collections
  - users: User profiles and data
  - items: Item listings and details
  
  // Methods
  - getUsers(): Stream of all users
  - addUser(): Add new user
  - getItems(): Stream of available items
  - getHomePageItems(): Get items for homepage
  - addItem(): Add new item listing
}
```

### ServiceMethods
```dart
// Helper Functions
- getHomePageContent(): Fetch homepage items
- getNavigationCategories(): Fetch category icons from Firebase Storage
- _getCategoryDisplayName(): Convert file names to display names
```

## 🎨 Design System

### Color Scheme
- **Primary**: Pink/Magenta `Color.fromARGB(180, 200, 23, 138)`
- **Secondary**: Green `Colors.green`
- **Surface**: Light Beige `Color.fromARGB(212, 237, 211, 190)`
- **Error**: Red `Colors.red`
- **Text**: Black on light backgrounds, White on primary

### Typography & Layout
- **Responsive Design**: Uses `flutter_screenutil` for screen adaptation
- **Material Design**: Follows Material Design principles
- **Custom Theme**: Pink/magenta primary color scheme

## 🔄 Data Flow

### Item Display Flow
```
Firebase Storage → Category Icons → TopNavBar
Firestore → Items Collection → HomePage Grid
Firebase Storage → Item Images → Item Cards
```

### User Interaction Flow
```
User Action → UI Update → Firebase Service → Database Update → Real-time Sync
```

## 🚀 Key Features

### Current Implementation
✅ **Firebase Integration**: Core, Firestore, Storage
✅ **User Management**: Profile system with ratings
✅ **Item Listings**: Display and categorization
✅ **Navigation**: Bottom navigation with 4 main sections
✅ **Responsive UI**: Screen-adaptive design
✅ **Real-time Data**: Live updates from Firebase

### Planned Features (Based on Project Scope)
🔄 **User Authentication**: Login/registration system
🔄 **In-app Chat**: Communication between buyers/sellers
🔄 **Transaction Records**: Complete transaction history
🔄 **Payment Integration**: Secure payment processing
🔄 **Search & Filter**: Advanced item discovery
🔄 **Push Notifications**: Real-time updates

## 🎯 Target Users
- **Primary**: Grinnell College students
- **Use Cases**: 
  - Selling textbooks, furniture, electronics
  - Buying secondhand items from peers
  - Trading dining dollars and meal plans
  - Finding transportation (bikes, cars)

## 🔧 Technical Stack
- **Frontend**: Flutter (Dart)
- **Backend**: Firebase (Google Cloud)
- **Database**: Cloud Firestore
- **Storage**: Firebase Storage
- **Authentication**: Firebase Auth (planned)
- **Platforms**: Android, iOS, Web, Windows, macOS

This architecture provides a solid foundation for a student marketplace app with room for expansion and feature additions as the project evolves.
