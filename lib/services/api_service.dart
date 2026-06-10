// lib/services/api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants.dart';
import '../models/product.dart';
import '../models/order.dart';

class ApiService {
  // ─── Fetch all products ─────────────────────────────
  static Future<List<Product>> getProducts() async {
    try {
      final response = await http
          .get(Uri.parse('$kBaseUrl/get_products.php'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final List list = data['products'];
          return list.map((p) => Product.fromJson(p)).toList();
        }
      }
    } catch (e) {
      // Return demo products if server not reachable
      return _demoProducts();
    }
    return _demoProducts();
  }

  // ─── Place an order ─────────────────────────────────
  static Future<OrderResponse> placeOrder(OrderRequest order) async {
    final response = await http.post(
      Uri.parse('$kBaseUrl/place_order.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(order.toJson()),
    );

    final data = jsonDecode(response.body);
    return OrderResponse.fromJson(data);
  }

  // ─── Verify Khalti payment ──────────────────────────
  static Future<bool> verifyKhalti({
    required String token,
    required int amount,
    required int orderId,
  }) async {
    final response = await http.post(
      Uri.parse('$kBaseUrl/verify_khalti.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'token': token, 'amount': amount, 'order_id': orderId}),
    );
    final data = jsonDecode(response.body);
    return data['success'] == true;
  }

  // ─── Verify eSewa payment ───────────────────────────
  static Future<bool> verifyEsewa({
    required String oid,
    required double amt,
    required String refId,
    required int orderId,
  }) async {
    final response = await http.post(
      Uri.parse('$kBaseUrl/verify_esewa.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'oid': oid, 'amt': amt, 'refId': refId, 'order_id': orderId
      }),
    );
    final data = jsonDecode(response.body);
    return data['success'] == true;
  }

  // ─── Demo products (offline fallback) ───────────────
  static List<Product> _demoProducts() {
    return [
      Product(id: 1, name: 'Whole Chicken',  description: 'Fresh whole chicken, cleaned on request', pricePerKg: 280, minOrder: 1.0, step: 0.5,  emoji: '🐔'),
      Product(id: 2, name: 'Breast Pieces',  description: 'Boneless chicken breast, tender and lean', pricePerKg: 350, minOrder: 0.5, step: 0.25, emoji: '🍗'),
      Product(id: 3, name: 'Leg Pieces',     description: 'Juicy chicken legs with bone',             pricePerKg: 300, minOrder: 0.5, step: 0.25, emoji: '🍖'),
      Product(id: 4, name: 'Wings',          description: 'Fresh chicken wings',                      pricePerKg: 260, minOrder: 0.5, step: 0.25, emoji: '🐓'),
      Product(id: 5, name: 'Chicken Liver',  description: 'Fresh liver and giblets',                  pricePerKg: 200, minOrder: 0.25,step: 0.25, emoji: '🫀'),
      Product(id: 6, name: 'Mixed Pieces',   description: 'Assorted chicken pieces, great value',     pricePerKg: 270, minOrder: 0.5, step: 0.5,  emoji: '🥩'),
    ];
  }
} 