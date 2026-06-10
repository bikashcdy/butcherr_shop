// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import '../services/cart_provider.dart';
import '../services/auth_service.dart';
import '../models/user.dart';
import '../widgets/product_card.dart';
import 'cart_screen.dart';
import 'customer/my_orders.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Product> _products = [];
  bool _loading = true;
  User? _user;

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await AuthService.getCurrentUser();
    setState(() => _user = user);
  }

  Future<void> _loadProducts() async {
    final products = await ApiService.getProducts();
    setState(() {
      _products = products;
      _loading  = false;
    });
  }

  // ── Logout ────────────────────────────────
  Future<void> _logout() async {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Logout'),
        content: const Text(
            'Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await AuthService.logout();
              if (!mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            child: const Text('Logout',
                style: TextStyle(color: kRed)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      // ── APP BAR ───────────────────────────
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('🔪 Chiksy',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700)),
            Text(kShopLocation,
                style: const TextStyle(
                    fontSize: 11,
                    color: Colors.white70)),
          ],
        ),
        actions: [
          // My Orders button
          IconButton(
            icon: const Icon(Icons.receipt_long),
            tooltip: 'My Orders',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const MyOrders()),
            ),
          ),

          // Cart button
          Stack(
            children: [
              IconButton(
                icon: const Icon(
                    Icons.shopping_cart_outlined),
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            const CartScreen())),
              ),
              if (cart.itemCount > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle),
                    child: Center(
                      child: Text(
                        '${cart.itemCount}',
                        style: const TextStyle(
                            color: kRed,
                            fontSize: 10,
                            fontWeight:
                                FontWeight.w700),
                      ),
                    ),
                  ),
                ),
            ],
          ),

          // Logout button
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: _logout,
          ),
        ],
      ),

      // ── BODY ──────────────────────────────
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(
                  color: kRed))
          : RefreshIndicator(
              color: kRed,
              onRefresh: _loadProducts,
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  // Welcome banner
                  Container(
                    width: double.infinity,
                    color: kRedLight,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        const Text('🥩',
                            style:
                                TextStyle(fontSize: 28)),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome, ${_user?.name.split(' ').first ?? 'Customer'}!',
                              style: const TextStyle(
                                  fontWeight:
                                      FontWeight.w600,
                                  fontSize: 14),
                            ),
                            const Text(
                              'Order by weight · Delivered to your door',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: kMuted),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Section title
                  const Padding(
                    padding: EdgeInsets.fromLTRB(
                        16, 16, 16, 8),
                    child: Text(
                      'OUR FRESH CUTS',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: kMuted,
                          letterSpacing: 1),
                    ),
                  ),

                  // Product list
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(
                          16, 0, 16, 100),
                      itemCount: _products.length,
                      itemBuilder: (context, index) =>
                          ProductCard(
                              product:
                                  _products[index]),
                    ),
                  ),
                ],
              ),
            ),

      // ── BOTTOM BAR ────────────────────────
      bottomNavigationBar: cart.itemCount > 0
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              const CartScreen())),
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                          'View Cart (${cart.itemCount} items)'),
                      Text(
                        'Rs. ${cart.totalAmount.toStringAsFixed(0)}',
                        style: const TextStyle(
                            fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ),
            )
          : null,
    );
  }
}