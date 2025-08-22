import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/api_config.dart';

class ProfileService {
  static String get _baseUrl => ApiConfig.endpoint('/api/user');

  static Future<bool> updateField({
    required String token,
    required String userId,
    required Map<String, dynamic> body,
  }) async {
    try {
      final res = await http.put(
        Uri.parse("$_baseUrl/update-profile/$userId"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(body),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data["success"] == true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> changePassword({
    required String token,
    required String userId,
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final res = await http.post(
        Uri.parse("$_baseUrl/change-password/$userId"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "oldPassword": oldPassword,
          "newPassword": newPassword,
        }),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data["success"] == true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
