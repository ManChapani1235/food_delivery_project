import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/category_model.dart';
import '../models/restaurant_model.dart';
import 'api_config.dart';

class ApiService {
  static Future<List<CategoryModel>> fetchCategories() async {
    final response = await http.get(Uri.parse(ApiConfig.endpoint('/categories')));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      return (data['data'] as List).map((e) {
        String image = e['image'] ?? "";

        if (image.startsWith('/')) {
          image = "${ApiConfig.baseUrl}$image";
        }
        e['image'] = image;

        return CategoryModel.fromJson(e);
      }).toList();
    } else {
      throw Exception("Failed to load categories");
    }
  }

  static Future<List<RestaurantModel>> fetchRestaurants({String? category}) async {
    final base = Uri.parse(ApiConfig.endpoint('/restaurants'));
    final uri = category != null && category.isNotEmpty
        ? base.replace(queryParameters: {"category": category})
        : base;

    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      return (data['data'] as List).map((e) {
        String image = e['image'] ?? "";

        if (image.startsWith('/')) {
          image = "${ApiConfig.baseUrl}$image";
        }

        e['image'] = image;

        return RestaurantModel.fromJson(e);
      }).toList();
    } else {
      throw Exception("Failed to load restaurants");
    }
  }
}
