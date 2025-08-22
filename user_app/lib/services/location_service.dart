import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class LocationService {
  // Replace with your local machine IP address for real device testing
  // Example: "http://192.168.1.100:4000/api/user/update-location"
  static const String backendUrl =
      "http://localhost:4000/api/user/update-location"; // 10.0.2.2 for Android emulator

  /// Requests location permission, retrieves location, stores locally,
  /// and updates backend automatically.
  static Future<bool> requestAndSaveLocation(String token) async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print("❌ Location services are disabled.");
        return false;
      }

      // Request permission if needed
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print("❌ Location permission denied by user.");
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print("❌ Location permission permanently denied.");
        return false;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Save location locally in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble("latitude", position.latitude);
      await prefs.setDouble("longitude", position.longitude);

      print("✅ Saved location locally: "
          "Lat ${position.latitude}, Lng ${position.longitude}");

      // Send location to backend
      final response = await http.post(
        Uri.parse(backendUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "latitude": position.latitude,
          "longitude": position.longitude,
        }),
      );

      if (response.statusCode == 200) {
        final resData = jsonDecode(response.body);
        print("✅ Location updated on backend: ${resData['location']}");
        return true;
      } else {
        print("❌ Failed to update location on backend: ${response.body}");
        return false;
      }
    } catch (e) {
      print("⚠️ Error in requestAndSaveLocation: $e");
      return false;
    }
  }
}
