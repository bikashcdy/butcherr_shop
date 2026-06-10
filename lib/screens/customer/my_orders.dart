// lib/screens/customer/my_orders.dart

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../constants.dart';
import '../../services/auth_service.dart';
import 'order_detail.dart';

class MyOrders extends StatefulWidget {
  const MyOrders({super.key});

  @override
  State<MyOrders> createState() => _MyOrdersState();
}

class _MyOrdersState extends State<MyOrders> {
  List<dynamic> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  // ── Load orders ───────────────────────────
  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);
    try {
      final user = await AuthService.getCurrentUser();
      if (user == null) return;

      final response = await http.get(
        Uri.parse(
            '$kBaseUrl/order_status.php?user_id=${user.id}'),
      ).timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        setState(() {
          _orders    = data['orders'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _orders    = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  // ── Cancel order ──────────────────────────
  Future<void> _cancelOrder(int orderId) async {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cancel Order'),
        content: const Text(
            'Are you sure you want to cancel this order?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                final user =
                    await AuthService.getCurrentUser();
                final response = await http.post(
                  Uri.parse(
                      '$kBaseUrl/cancel_order.php'),
                  headers: {
                    'Content-Type': 'application/json'
                  },
                  body: jsonEncode({
                    'order_id': orderId,
                    'user_id':  user?.id ?? 0,
                  }),
                );
                final data =
                    jsonDecode(response.body);
                _showSnack(data['message'],
                    data['success'] == true
                        ? Colors.green
                        : Colors.red);
                _loadOrders();
              } catch (e) {
                _showSnack('Failed to cancel order',
                    Colors.red);
              }
            },
            child: const Text('Yes, Cancel',
                style: TextStyle(color: kRed)),
          ),
        ],
      ),
    );
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(msg),
          backgroundColor: color),
    );
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                  color: kRed))
          : _orders.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      const Text('🛒',
                          style: TextStyle(
                              fontSize: 60)),
                      const SizedBox(height: 16),
                      const Text(
                        'No orders yet!',
                        style: TextStyle(
                            fontSize: 16,
                            color: kMuted),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Order some fresh chicken!',
                        style: TextStyle(
                            fontSize: 13,
                            color: kMuted),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () =>
                            Navigator.pop(context),
                        child: const Text(
                            'Browse Menu'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  color: kRed,
                  onRefresh: _loadOrders,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _orders.length,
                    itemBuilder: (context, index) {
                      final order = _orders[index];
                      final status =
                          order['order_status'];
                      final statusColor =
                          _statusColor(status);
                      final isPending =
                          status == 'pending';

                      return GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                OrderDetail(
                                    order: order),
                          ),
                        ),
                        child: Container(
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
                                color: kBorder),
                          ),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                            children: [
                              // Order number & status
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment
                                        .spaceBetween,
                                children: [
                                  Text(
                                    '#${order['order_number']}',
                                    style: const TextStyle(
                                        fontWeight:
                                            FontWeight
                                                .w700,
                                        fontSize: 14),
                                  ),
                                  Container(
                                    padding: const EdgeInsets
                                        .symmetric(
                                        horizontal: 10,
                                        vertical: 4),
                                    decoration:
                                        BoxDecoration(
                                      color: statusColor
                                          .withOpacity(
                                              0.1),
                                      borderRadius:
                                          BorderRadius
                                              .circular(
                                                  20),
                                      border: Border.all(
                                          color:
                                              statusColor),
                                    ),
                                    child: Text(
                                      status
                                          .replaceAll(
                                              '_', ' ')
                                          .toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight:
                                            FontWeight
                                                .w700,
                                        color:
                                            statusColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),

                              // Items
                              Row(
                                children: [
                                  const Icon(
                                      Icons.set_meal,
                                      size: 14,
                                      color: kMuted),
                                  const SizedBox(
                                      width: 4),
                                  Expanded(
                                    child: Text(
                                      order['items_summary'] ??
                                          'N/A',
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color: kMuted),
                                      maxLines: 1,
                                      overflow:
                                          TextOverflow
                                              .ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),

                              // Address
                              Row(
                                children: [
                                  const Icon(
                                      Icons.location_on,
                                      size: 14,
                                      color: kMuted),
                                  const SizedBox(
                                      width: 4),
                                  Expanded(
                                    child: Text(
                                      order['delivery_address'],
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color: kMuted),
                                      maxLines: 1,
                                      overflow:
                                          TextOverflow
                                              .ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),

                              // Total & time
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment
                                        .spaceBetween,
                                children: [
                                  Text(
                                    'Rs. ${order['total_amount']}',
                                    style: const TextStyle(
                                        fontWeight:
                                            FontWeight
                                                .w700,
                                        fontSize: 15,
                                        color: kRed),
                                  ),
                                  Text(
                                    order['created_at'],
                                    style: const TextStyle(
                                        fontSize: 11,
                                        color: kMuted),
                                  ),
                                ],
                              ),

                              // Cancel button
                              // (only for pending orders)
                              if (isPending) ...[
                                const SizedBox(
                                    height: 10),
                                const Divider(
                                    color: kBorder),
                                const SizedBox(
                                    height: 6),
                                Row(
                                  children: [
                                    const Icon(
                                        Icons
                                            .timer_outlined,
                                        size: 14,
                                        color:
                                            Colors.orange),
                                    const SizedBox(
                                        width: 4),
                                    const Expanded(
                                      child: Text(
                                        'You can cancel within 30 minutes',
                                        style: TextStyle(
                                            fontSize: 11,
                                            color: Colors
                                                .orange),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () =>
                                          _cancelOrder(
                                        int.parse(order[
                                                'id']
                                            .toString()),
                                      ),
                                      child: Container(
                                        padding: const EdgeInsets
                                            .symmetric(
                                            horizontal:
                                                12,
                                            vertical:
                                                6),
                                        decoration:
                                            BoxDecoration(
                                          color:
                                              kRedLight,
                                          borderRadius:
                                              BorderRadius
                                                  .circular(
                                                      8),
                                          border: Border.all(
                                              color:
                                                  kRed),
                                        ),
                                        child: const Text(
                                          'Cancel',
                                          style: TextStyle(
                                              color: kRed,
                                              fontSize:
                                                  12,
                                              fontWeight:
                                                  FontWeight
                                                      .w600),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],

                              // View details hint
                              const SizedBox(height: 6),
                              const Text(
                                'Tap to view full details →',
                                style: TextStyle(
                                    fontSize: 11,
                                    color: kRed,
                                    fontWeight:
                                        FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}