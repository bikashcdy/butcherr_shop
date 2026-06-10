// lib/screens/customer/order_detail.dart

import 'package:flutter/material.dart';
import '../../constants.dart';

class OrderDetail extends StatelessWidget {
  final dynamic order;

  const OrderDetail({super.key, required this.order});

  // ── Status color ──────────────────────────
  Color _statusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'preparing':
        return Colors.purple;
      case 'out_for_delivery':
        return Colors.teal;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // ── Status steps ──────────────────────────
  int _statusStep(String status) {
    switch (status) {
      case 'pending':
        return 0;
      case 'confirmed':
        return 1;
      case 'preparing':
        return 2;
      case 'out_for_delivery':
        return 3;
      case 'delivered':
        return 4;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = order['order_status'];
    final statusColor = _statusColor(status);
    final currentStep = _statusStep(status);
    final isCancelled = status == 'cancelled';

    return Scaffold(
      appBar: AppBar(
        title: Text('#${order['order_number']}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [

            // ── Status Banner ─────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius:
                    BorderRadius.circular(12),
                border:
                    Border.all(color: statusColor),
              ),
              child: Row(
                children: [
                  Icon(
                    isCancelled
                        ? Icons.cancel
                        : status == 'delivered'
                            ? Icons.check_circle
                            : Icons.pending_actions,
                    color: statusColor,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        status
                            .replaceAll('_', ' ')
                            .toUpperCase(),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: statusColor,
                        ),
                      ),
                      Text(
                        _statusMessage(status),
                        style: const TextStyle(
                            fontSize: 12,
                            color: kMuted),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Order Progress ────────────
            if (!isCancelled) ...[
              _sectionTitle('ORDER PROGRESS'),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(12),
                  border:
                      Border.all(color: kBorder),
                ),
                child: Column(
                  children: [
                    _progressStep(
                        'Order Placed', 0,
                        currentStep,
                        Icons.receipt),
                    _progressStep(
                        'Confirmed', 1,
                        currentStep,
                        Icons.thumb_up),
                    _progressStep(
                        'Preparing', 2,
                        currentStep,
                        Icons.set_meal),
                    _progressStep(
                        'Out for Delivery', 3,
                        currentStep,
                        Icons.delivery_dining),
                    _progressStep(
                        'Delivered', 4,
                        currentStep,
                        Icons.home,
                        isLast: true),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // ── Order Details ─────────────
            _sectionTitle('ORDER DETAILS'),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(12),
                border: Border.all(color: kBorder),
              ),
              child: Column(
                children: [
                  _detailRow('Order Number',
                      '#${order['order_number']}'),
                  _detailRow('Date',
                      order['created_at']),
                  _detailRow('Items',
                      order['items_summary'] ??
                          'N/A'),
                  if (order['special_notes'] !=
                          null &&
                      order['special_notes']
                          .isNotEmpty)
                    _detailRow('Notes',
                        order['special_notes']),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Delivery Address ──────────
            _sectionTitle('DELIVERY ADDRESS'),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(12),
                border: Border.all(color: kBorder),
              ),
              child: Column(
                children: [
                  _detailRow('Address',
                      order['delivery_address']),
                  _detailRow('Ward',
                      order['ward'] ?? 'N/A'),
                  _detailRow('City',
                      order['city'] ?? 'N/A'),
                  _detailRow('Phone',
                      order['customer_phone']),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Payment Info ──────────────
            _sectionTitle('PAYMENT'),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(12),
                border: Border.all(color: kBorder),
              ),
              child: Column(
                children: [
                  _detailRow(
                      'Method',
                      order['payment_method']
                          .toString()
                          .toUpperCase()),
                  _detailRow(
                      'Status',
                      order['payment_status']
                          .toString()
                          .toUpperCase()),
                  const Divider(color: kBorder),
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment
                            .spaceBetween,
                    children: [
                      const Text(
                        'Total Paid',
                        style: TextStyle(
                            fontWeight:
                                FontWeight.w700,
                            fontSize: 15),
                      ),
                      Text(
                        'Rs. ${order['total_amount']}',
                        style: const TextStyle(
                            fontWeight:
                                FontWeight.w700,
                            fontSize: 15,
                            color: kRed),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Delivery Info ─────────────
            if (status != 'delivered' &&
                status != 'cancelled') ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF9F3),
                  borderRadius:
                      BorderRadius.circular(12),
                ),
                child: Row(
                  children: const [
                    Text('🛵',
                        style:
                            TextStyle(fontSize: 26)),
                    SizedBox(width: 12),
                    Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Estimated Delivery',
                          style: TextStyle(
                              fontWeight:
                                  FontWeight.w600,
                              color:
                                  Color(0xFF7D5A2A),
                              fontSize: 13),
                        ),
                        Text(
                          'Within 1-2 hours · We will call you',
                          style: TextStyle(
                              fontSize: 12,
                              color: kMuted),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // ── Back Button ───────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () =>
                    Navigator.pop(context),
                child: const Text('Back to Orders'),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // ── Helper widgets ────────────────────────
  String _statusMessage(String status) {
    switch (status) {
      case 'pending':
        return 'Your order is waiting for confirmation';
      case 'confirmed':
        return 'Your order has been confirmed!';
      case 'preparing':
        return 'Your chicken is being prepared';
      case 'out_for_delivery':
        return 'Your order is on the way!';
      case 'delivered':
        return 'Your order has been delivered!';
      case 'cancelled':
        return 'Your order has been cancelled';
      default:
        return '';
    }
  }

  Widget _progressStep(
      String label,
      int step,
      int currentStep,
      IconData icon,
      {bool isLast = false}) {
    final isDone = currentStep >= step;
    final isActive = currentStep == step;

    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isDone ? kRed : kBorder,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isDone
                    ? Colors.white
                    : kMuted,
                size: 16,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 30,
                color: isDone ? kRed : kBorder,
              ),
          ],
        ),
        const SizedBox(width: 12),
        Padding(
          padding:
              const EdgeInsets.only(top: 6),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isActive
                  ? FontWeight.w700
                  : FontWeight.w400,
              color:
                  isDone ? kRed : kMuted,
            ),
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(String text) => Padding(
        padding:
            const EdgeInsets.only(bottom: 8),
        child: Text(
          text,
          style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: kMuted,
              letterSpacing: 1),
        ),
      );

  Widget _detailRow(
      String label, String value) {
    return Padding(
      padding:
          const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                  fontSize: 13,
                  color: kMuted),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight:
                      FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}