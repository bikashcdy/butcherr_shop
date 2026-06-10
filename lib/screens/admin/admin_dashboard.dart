// lib/screens/admin/admin_dashboard.dart

import 'package:flutter/material.dart';
import '../../constants.dart';
import '../../services/auth_service.dart';
import '../../models/user.dart';
import 'admin_orders.dart';
import 'admin_products.dart';
import '../login_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  User? _admin;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadAdmin();
  }

  Future<void> _loadAdmin() async {
    final user = await AuthService.getCurrentUser();
    setState(() => _admin = user);
  }

  // ── Logout ────────────────────────────────
  Future<void> _logout() async {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
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
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Admin Dashboard',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700)),
            Text(
              _admin?.name ?? 'Admin',
              style: const TextStyle(
                  fontSize: 11,
                  color: Colors.white70),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),

      // ── Bottom Navigation ─────────────────
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) =>
            setState(() => _selectedIndex = index),
        selectedItemColor: kRed,
        unselectedItemColor: kMuted,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.set_meal),
            label: 'Products',
          ),
        ],
      ),

      // ── Body ─────────────────────────────
      body: _selectedIndex == 0
          ? const AdminOrders()
          : const AdminProducts(),
    );
  }
}