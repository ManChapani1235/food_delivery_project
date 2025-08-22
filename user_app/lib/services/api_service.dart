import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/category_model.dart';
import '../models/restaurant_model.dart';

class ApiService {
  static const String baseUrl = "http://localhost:4000";

  static Future<List<CategoryModel>> fetchCategories() async {
    final response = await http.get(Uri.parse("$baseUrl/categories"));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      return (data['data'] as List).map((e) {
        String image = e['image'] ?? "";

        // If it starts with http, leave as is
        // If it starts with /, prepend backend URL
        if (image.startsWith('/')) {
          image = "$baseUrl$image";
        }
        // Otherwise, assume it's base64 and leave as is
        e['image'] = image;

        return CategoryModel.fromJson(e);
      }).toList();
    } else {
      throw Exception("Failed to load categories");
    }
  }

  static Future<List<RestaurantModel>> fetchRestaurants({String? category}) async {
    final uri = category != null
        ? Uri.parse("$baseUrl/restaurants?category=$category")
        : Uri.parse("$baseUrl/restaurants");

    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      return (data['data'] as List).map((e) {
        String image = e['image'] ?? "";

        if (image.startsWith('/')) {
          image = "$baseUrl$image";
        }

        e['image'] = image;

        return RestaurantModel.fromJson(e);
      }).toList();
    } else {
      throw Exception("Failed to load restaurants");
    }
  }
}
