import 'package:flutter/material.dart';
import 'UI/menu.dart';
import 'models/users.dart';
import 'sevices/database_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

/// Main entry point of the PHF Flutter application.
/// 
/// This function initializes Firebase services before running the app.
/// Firebase must be initialized before any Firebase services can be used.
/// 
/// Steps performed:
/// 1. Ensures Flutter binding is initialized
/// 2. Initializes Firebase with platform-specific options
/// 3. Runs the main application widget
void main() async {
  // Ensure Flutter binding is initialized before using any Flutter services
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase with platform-specific configuration
  // This loads the firebase_options.dart file which contains platform-specific settings
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: true);
  // Determine initial user
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final int? savedUserId = prefs.getInt('currentUserId');
  Users? initialUser;
  if (savedUserId != null) {
    initialUser = await DatabaseService().getUserById(savedUserId);
  }

  // Run the main application
  runApp(MyApp(initialUser: initialUser));

}
/// Main application widget for the PHF Flutter app.
/// 
/// This widget serves as the root of the application and configures:
/// - Application title
/// - Theme configuration with custom color scheme
/// - Navigation to the main menu
/// 
/// The app uses a custom color scheme with:
/// - Primary color: Pink/magenta for headers
/// - Surface color: Light beige for backgrounds
/// - White text on primary surfaces
class MyApp extends StatelessWidget {
  final Users? initialUser;
  const MyApp({super.key, this.initialUser});

  /// Builds the main application widget.
  /// 
  /// Returns a MaterialApp wrapped in a Container with:
  /// - Custom theme configuration
  /// - Debug banner disabled
  /// - Menu widget as the home screen
  /// 
  /// [context] - The build context for this widget
  /// Returns the configured MaterialApp widget
  @override
  Widget build(BuildContext context) {
    return Container(
      child: MaterialApp(
        title: 'PHF',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: const ColorScheme(
            // Primary color for app bars and primary buttons (pink/magenta)
            primary: Color.fromARGB(180, 200, 23, 138),
            // Secondary color for secondary buttons and accents
            secondary: Colors.green,
            // Error color for error states and validation
            error: Colors.red,
            // Light theme configuration
            brightness: Brightness.light,
            // Color for text/icons on error backgrounds
            onError: Colors.yellow,
            // Text color on primary surfaces (white text on pink)
            onPrimary: Colors.white,
            // Text color on secondary surfaces
            onSecondary: Color.fromARGB(255, 0, 0, 0),
            // Text color on surface backgrounds
            onSurface: Color.fromARGB(255, 0, 0, 0),
            // Background color for cards and surfaces (light beige)
            surface: Color.fromARGB(212, 237, 211, 190),
          )
          // useMaterial3: true,
          // colorScheme: ColorScheme.fromSeed(
          //   seedColor: const Color.fromARGB(255, 225, 4, 129),
          // ),
        ),
          home: Menu(
            currentUser: initialUser ?? Users(
              userId: 1,
              name: "Sample User",
              password: "password",
              email: "user@example.com",
              avatar: "",
              buyerCredit: 4.2,
              sellerCredit: 3.8,
              itemSold: [1, 2, 3, 4, 5],
              itemBought: [6, 7, 8],
            ),
          )
      ),
    );
  }
}