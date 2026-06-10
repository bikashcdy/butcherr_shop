// lib/screens/confirmation_screen.dart

import 'package:flutter/material.dart';
import '../constants.dart';
import 'home_screen.dart';

class ConfirmationScreen extends StatelessWidget {
  final String orderNumber;
  final double totalAmount;
  final String deliveryAddress;
  final String paymentMethod;

  const ConfirmationScreen({
    super.key,
    required this.orderNumber,
    required this.totalAmount,
    required this.deliveryAddress,
    required this.paymentMethod,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Red top bar
              Container(color: kRed, height: 80),

              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
                child: Transform.translate(
                  offset: const Offset(0, -40),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: kBorder),
                    ),
                    child: Column(
                      children: [

                        // Success icon
                        Container(
                          width: 64, height: 64,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0FFF4),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.green, width: 3),
                          ),
                          child: const Center(
                            child: Icon(Icons.check, color: Colors.green, size: 32),
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Text('Order Placed!',
                            style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700)),
                        const SizedBox(height: 4),
                        Text('Order #$orderNumber',
                            style: const TextStyle(fontSize: 13, color: kMuted)),

                        // Divider
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Divider(color: kBorder),
                        ),

                        // Payment info
                        _infoRow(
                          icon: Icons.payment,
                          label: 'Payment',
                          value: '${paymentMethod.toUpperCase()} · Paid',
                          valueColor: Colors.green,
                        ),
                        const SizedBox(height: 10),
                        _infoRow(
                          icon: Icons.receipt_long,
                          label: 'Total Amount',
                          value: 'Rs. ${totalAmount.toStringAsFixed(0)}',
                          valueColor: kRed,
                          valueBold: true,
                        ),
                        const SizedBox(height: 10),
                        _infoRow(
                          icon: Icons.location_on_outlined,
                          label: 'Delivery To',
                          value: deliveryAddress,
                        ),

                        // Delivery time box
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF9F3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Text('🛵', style: TextStyle(fontSize: 26)),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text('Estimated Delivery',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF7D5A2A),
                                          fontSize: 13)),
                                  SizedBox(height: 2),
                                  Text('Within 1–2 hours · We\'ll call you',
                                      style: TextStyle(fontSize: 12, color: kMuted)),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Note
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0FFF4),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: const [
                              Icon(Icons.info_outline, color: Colors.green, size: 18),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Final weight confirmed at shop. Price may slightly vary.',
                                  style: TextStyle(fontSize: 11, color: kMuted),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // New order button
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (_) => const HomeScreen()),
                              (route) => false,
                            ),
                            child: const Text('Place Another Order'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
    bool valueBold = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: kMuted),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, color: kMuted)),
              Text(value,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: valueBold ? FontWeight.w700 : FontWeight.w500,
                      color: valueColor ?? Colors.black87)),
            ],
          ),
        ),
      ],
    );
  }
}