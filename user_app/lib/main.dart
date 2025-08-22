import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/splash_screen.dart';
import 'services/location_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Check if user token exists before starting app
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString("auth_token");

  if (token != null && token.isNotEmpty) {
    try {
      // Try updating location silently if permission already granted
      await LocationService.requestAndSaveLocation(token);
    } catch (e) {
      // Avoid crashing if permission denied or error occurs
      debugPrint("Location update skipped: $e");
    }
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food Delivery App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      home: const SplashScreen(), // Keep splash as the first screen
    );
  }
}
