// lib/services/cart_provider.dart

import 'package:flutter/material.dart';
import '../models/order.dart';
import '../models/product.dart';

class CartProvider extends ChangeNotifier {
  final Map<int, CartItem> _items = {};

  Map<int, CartItem> get items => _items;

  int get itemCount => _items.length;

  double get totalAmount {
    double total = 0;
    for (var item in _items.values) {
      total += item.subtotal;
    }
    return total;
  }

  bool hasItem(int productId) => _items.containsKey(productId);

  double getQty(int productId) => _items[productId]?.quantity ?? 0;

  void addItem(Product product) {
    if (_items.containsKey(product.id)) {
      _items[product.id]!.quantity =
          double.parse((_items[product.id]!.quantity + product.step).toStringAsFixed(2));
    } else {
      _items[product.id] = CartItem(
        productId:   product.id,
        productName: product.name,
        quantity:    product.minOrder,
        pricePerKg:  product.pricePerKg,
        unit:        product.unit,
      );
    }
    notifyListeners();
  }

  void removeItem(Product product) {
    if (!_items.containsKey(product.id)) return;

    final newQty = double.parse(
        (_items[product.id]!.quantity - product.step).toStringAsFixed(2));

    if (newQty < product.minOrder) {
      _items.remove(product.id);
    } else {
      _items[product.id]!.quantity = newQty;
    }
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  List<CartItem> get itemList => _items.values.toList();
}