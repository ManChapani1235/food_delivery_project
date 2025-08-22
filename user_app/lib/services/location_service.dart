import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class LocationService {
  static String get backendUrl => ApiConfig.endpoint('/api/user/update-location');

  /// Requests location permission, retrieves location, stores locally,
  /// and updates backend automatically.
  static Future<bool> requestAndSaveLocation(String token) async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print("❌ Location services are disabled.");
        return false;
      }

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

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble("latitude", position.latitude);
      await prefs.setDouble("longitude", position.longitude);

      print("✅ Saved location locally: "
          "Lat ${position.latitude}, Lng ${position.longitude}");

      final response = await http.put(
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
