import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const baseUrl = 'http://localhost:4000/api'; // your backend URL

  static Future<List> getUserOrders(String userId) async {
    final res = await http.get(Uri.parse('$baseUrl/orders/user/$userId'));
    return json.decode(res.body);
  }

  static Future<bool> placeOrder(Map orderData) async {
    final res = await http.post(
      Uri.parse('$baseUrl/orders'),
      body: json.encode(orderData),
      headers: {'Content-Type': 'application/json'},
    );
    return res.statusCode == 200;
  }
}
