// lib/screens/admin/admin_products.dart

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../constants.dart';
import 'admin_add_product.dart';

class AdminProducts extends StatefulWidget {
  const AdminProducts({super.key});

  @override
  State<AdminProducts> createState() =>
      _AdminProductsState();
}

class _AdminProductsState extends State<AdminProducts> {
  List<dynamic> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  // ── Load products ─────────────────────────
  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(
        Uri.parse('$kBaseUrl/get_products.php'),
      ).timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        setState(() {
          _products  = data['products'];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnack('Failed to load products');
    }
  }

  // ── Delete product ────────────────────────
  Future<void> _deleteProduct(int id) async {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Product'),
        content: const Text(
            'Are you sure you want to delete this product?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                final response = await http.post(
                  Uri.parse(
                      '$kBaseUrl/delete_product.php'),
                  headers: {
                    'Content-Type': 'application/json'
                  },
                  body: jsonEncode({'id': id}),
                );
                final data = jsonDecode(response.body);
                _showSnack(data['message']);
                _loadProducts();
              } catch (e) {
                _showSnack('Failed to delete product');
              }
            },
            child: const Text('Delete',
                style: TextStyle(color: kRed)),
          ),
        ],
      ),
    );
  }

  // ── Toggle availability ───────────────────
  Future<void> _toggleAvailability(
      dynamic product) async {
    try {
      final newAvailability =
          product['is_available'] == '1' ? 0 : 1;
      await http.post(
        Uri.parse('$kBaseUrl/update_product.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id':           int.parse(product['id'].toString()),
          'name':         product['name'],
          'description':  product['description'],
          'price_per_kg': double.parse(product['price_per_kg'].toString()),
          'unit':         product['unit'],
          'min_order':    double.parse(product['min_order'].toString()),
          'step':         double.parse(product['step'].toString()),
          'is_available': newAvailability,
        }),
      );
      _loadProducts();
      _showSnack(newAvailability == 1
          ? 'Product is now available'
          : 'Product hidden from menu');
    } catch (e) {
      _showSnack('Failed to update product');
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  // ── Emojis for products ───────────────────
  String _getEmoji(int index) {
    const emojis = ['🐔', '🍗', '🍖', '🐓', '🫀', '🥩'];
    return emojis[index % emojis.length];
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(
            child: CircularProgressIndicator(
                color: kRed))
        : RefreshIndicator(
            color: kRed,
            onRefresh: _loadProducts,
            child: Column(
              children: [
                // ── Add Product Button ────────
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const AdminAddProduct(),
                          ),
                        );
                        _loadProducts();
                      },
                      icon: const Icon(Icons.add),
                      label:
                          const Text('Add New Product'),
                    ),
                  ),
                ),

                // ── Products count ────────────
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16),
                  child: Row(
                    children: [
                      Text(
                        '${_products.length} Products',
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: kMuted),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // ── Products list ─────────────
                Expanded(
                  child: _products.isEmpty
                      ? const Center(
                          child: Text(
                            'No products yet.\nAdd your first product!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: kMuted,
                                fontSize: 15),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets
                              .fromLTRB(16, 0, 16, 16),
                          itemCount: _products.length,
                          itemBuilder: (context, index) {
                            final product =
                                _products[index];
                            final isAvailable =
                                product['is_available']
                                    .toString() ==
                                '1';

                            return Container(
                              margin: const EdgeInsets
                                  .only(bottom: 12),
                              padding:
                                  const EdgeInsets.all(
                                      14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.circular(
                                        12),
                                border: Border.all(
                                  color: isAvailable
                                      ? kBorder
                                      : Colors.grey
                                          .shade300,
                                ),
                              ),
                              child: Row(
                                children: [
                                  // Emoji icon
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration:
                                        BoxDecoration(
                                      color: isAvailable
                                          ? kRedLight
                                          : Colors.grey
                                              .shade100,
                                      borderRadius:
                                          BorderRadius
                                              .circular(
                                                  10),
                                    ),
                                    child: Center(
                                      child: Text(
                                        _getEmoji(index),
                                        style: const TextStyle(
                                            fontSize: 24),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                      width: 12),

                                  // Product info
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment
                                              .start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              product[
                                                  'name'],
                                              style: TextStyle(
                                                fontSize:
                                                    14,
                                                fontWeight:
                                                    FontWeight
                                                        .w600,
                                                color: isAvailable
                                                    ? kRed
                                                    : kMuted,
                                              ),
                                            ),
                                            const SizedBox(
                                                width: 6),
                                            Container(
                                              padding: const EdgeInsets
                                                  .symmetric(
                                                  horizontal:
                                                      6,
                                                  vertical:
                                                      2),
                                              decoration:
                                                  BoxDecoration(
                                                color: isAvailable
                                                    ? Colors
                                                        .green
                                                        .shade50
                                                    : Colors
                                                        .grey
                                                        .shade100,
                                                borderRadius:
                                                    BorderRadius
                                                        .circular(
                                                            6),
                                              ),
                                              child: Text(
                                                isAvailable
                                                    ? 'Available'
                                                    : 'Hidden',
                                                style: TextStyle(
                                                  fontSize:
                                                      10,
                                                  fontWeight:
                                                      FontWeight
                                                          .w600,
                                                  color: isAvailable
                                                      ? Colors
                                                          .green
                                                      : kMuted,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(
                                            height: 2),
                                        Text(
                                          product[
                                              'description'],
                                          style: const TextStyle(
                                              fontSize: 11,
                                              color: kMuted),
                                          maxLines: 1,
                                          overflow:
                                              TextOverflow
                                                  .ellipsis,
                                        ),
                                        const SizedBox(
                                            height: 4),
                                        Text(
                                          'Rs. ${product['price_per_kg']} / ${product['unit']} · Min: ${product['min_order']} ${product['unit']}',
                                          style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight:
                                                  FontWeight
                                                      .w500),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Action buttons
                                  Column(
                                    children: [
                                      // Edit button
                                      GestureDetector(
                                        onTap: () async {
                                          await Navigator
                                              .push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  AdminAddProduct(
                                                product:
                                                    product,
                                              ),
                                            ),
                                          );
                                          _loadProducts();
                                        },
                                        child: Container(
                                          padding:
                                              const EdgeInsets
                                                  .all(6),
                                          decoration:
                                              BoxDecoration(
                                            color: Colors
                                                .blue
                                                .shade50,
                                            borderRadius:
                                                BorderRadius
                                                    .circular(
                                                        6),
                                          ),
                                          child: const Icon(
                                            Icons.edit,
                                            color:
                                                Colors.blue,
                                            size: 18,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                          height: 6),

                                      // Toggle availability
                                      GestureDetector(
                                        onTap: () =>
                                            _toggleAvailability(
                                                product),
                                        child: Container(
                                          padding:
                                              const EdgeInsets
                                                  .all(6),
                                          decoration:
                                              BoxDecoration(
                                            color: isAvailable
                                                ? Colors
                                                    .orange
                                                    .shade50
                                                : Colors
                                                    .green
                                                    .shade50,
                                            borderRadius:
                                                BorderRadius
                                                    .circular(
                                                        6),
                                          ),
                                          child: Icon(
                                            isAvailable
                                                ? Icons
                                                    .visibility_off
                                                : Icons
                                                    .visibility,
                                            color: isAvailable
                                                ? Colors
                                                    .orange
                                                : Colors
                                                    .green,
                                            size: 18,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                          height: 6),

                                      // Delete button
                                      GestureDetector(
                                        onTap: () =>
                                            _deleteProduct(
                                          int.parse(product[
                                                  'id']
                                              .toString()),
                                        ),
                                        child: Container(
                                          padding:
                                              const EdgeInsets
                                                  .all(6),
                                          decoration:
                                              BoxDecoration(
                                            color: kRedLight,
                                            borderRadius:
                                                BorderRadius
                                                    .circular(
                                                        6),
                                          ),
                                          child: const Icon(
                                            Icons.delete,
                                            color: kRed,
                                            size: 18,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
  }
}