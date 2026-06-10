// lib/screens/admin/admin_orders.dart

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../constants.dart';

class AdminOrders extends StatefulWidget {
  const AdminOrders({super.key});

  @override
  State<AdminOrders> createState() => _AdminOrdersState();
}

class _AdminOrdersState extends State<AdminOrders> {
  List<dynamic> _orders = [];
  bool _isLoading       = true;
  String _filter        = 'all';

  // Stats
  int    _totalOrders   = 0;
  int    _pendingOrders = 0;
  int    _todayOrders   = 0;
  double _revenue       = 0;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  // ── Load orders ───────────────────────────
  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(
        Uri.parse('$kBaseUrl/admin_orders.php'),
      ).timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        setState(() {
          _orders       = data['orders'];
          _totalOrders  = int.parse(data['stats']['total'].toString());
          _pendingOrders = int.parse(data['stats']['pending'].toString());
          _todayOrders  = int.parse(data['stats']['today'].toString());
          _revenue      = double.parse(data['stats']['revenue'].toString());
          _isLoading    = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  // ── Update order status ───────────────────
  Future<void> _updateStatus(int orderId, String status) async {
    try {
      await http.post(
        Uri.parse('$kBaseUrl/update_order.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'order_id': orderId,
          'status':   status,
        }),
      );
      _loadOrders();
    } catch (e) {
      _showSnack('Failed to update status');
    }
  }

  // ── Delete order ──────────────────────────
  Future<void> _deleteOrder(int orderId) async {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Order'),
        content: const Text(
            'Are you sure you want to delete this order?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await http.post(
                  Uri.parse('$kBaseUrl/delete_order.php'),
                  headers: {'Content-Type': 'application/json'},
                  body: jsonEncode({'order_id': orderId}),
                );
                _loadOrders();
                _showSnack('Order deleted successfully');
              } catch (e) {
                _showSnack('Failed to delete order');
              }
            },
            child: const Text('Delete',
                style: TextStyle(color: kRed)),
          ),
        ],
      ),
    );
  }

  // ── Show order details ────────────────────
  void _showOrderDetails(dynamic order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
              top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: kBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order #${order['order_number']}',
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700),
                  ),
                  _statusBadge(order['order_status']),
                ],
              ),
            ),

            const Divider(color: kBorder),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [

                    // ── Customer Info ─────────
                    _detailSection('👤 Customer Details'),
                    _detailRow('Name',
                        order['customer_name']),
                    _detailRow('Phone',
                        order['customer_phone']),
                    _detailRow('Email',
                        order['user_email'] ?? 'N/A'),
                    const SizedBox(height: 16),

                    // ── Delivery Address ──────
                    _detailSection('📍 Delivery Address'),
                    _detailRow('Address',
                        order['delivery_address']),
                    _detailRow('Ward',
                        order['ward'] ?? 'N/A'),
                    _detailRow('City',
                        order['city'] ?? 'N/A'),
                    const SizedBox(height: 16),

                    // ── Order Items ───────────
                    _detailSection('🛒 Order Items'),
                    Text(
                      order['items_summary'] ?? 'N/A',
                      style: const TextStyle(
                          fontSize: 13, color: kMuted),
                    ),
                    const SizedBox(height: 8),
                    if (order['special_notes'] != null &&
                        order['special_notes'].isNotEmpty)
                      _detailRow('Special Notes',
                          order['special_notes']),
                    const SizedBox(height: 16),

                    // ── Payment Info ──────────
                    _detailSection('💳 Payment'),
                    _detailRow('Method',
                        order['payment_method']
                            .toString()
                            .toUpperCase()),
                    _detailRow('Status',
                        order['payment_status']
                            .toString()
                            .toUpperCase()),
                    _detailRow('Total',
                        'Rs. ${order['total_amount']}'),
                    const SizedBox(height: 16),

                    // ── Order Time ────────────
                    _detailSection('🕐 Order Time'),
                    _detailRow('Placed at',
                        order['created_at']),
                    const SizedBox(height: 16),

                    // ── Update Status ─────────
                    _detailSection('📦 Update Status'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        'pending',
                        'confirmed',
                        'preparing',
                        'out_for_delivery',
                        'delivered',
                        'cancelled',
                      ].map((status) {
                        final isSelected =
                            order['order_status'] == status;
                        return GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            _updateStatus(
                                int.parse(order['id']
                                    .toString()),
                                status);
                          },
                          child: Container(
                            padding: const EdgeInsets
                                .symmetric(
                                horizontal: 12,
                                vertical: 6),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? kRed
                                  : kRedLight,
                              borderRadius:
                                  BorderRadius.circular(20),
                            ),
                            child: Text(
                              status.replaceAll('_', ' ')
                                  .toUpperCase(),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? Colors.white
                                    : kRed,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),

                    // ── Delete Button ─────────
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _deleteOrder(int.parse(
                              order['id'].toString()));
                        },
                        icon: const Icon(Icons.delete,
                            color: kRed),
                        label: const Text('Delete Order',
                            style:
                                TextStyle(color: kRed)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                              color: kRed),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Filtered orders ───────────────────────
  List<dynamic> get _filteredOrders {
    if (_filter == 'all') return _orders;
    return _orders
        .where((o) => o['order_status'] == _filter)
        .toList();
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(
            child: CircularProgressIndicator(color: kRed))
        : RefreshIndicator(
            color: kRed,
            onRefresh: _loadOrders,
            child: CustomScrollView(
              slivers: [
                // ── Stats ─────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Stats grid
                        GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics:
                              const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.8,
                          children: [
                            _statBox('Total Orders',
                                '$_totalOrders',
                                Icons.receipt_long),
                            _statBox('Pending',
                                '$_pendingOrders',
                                Icons.pending_actions),
                            _statBox("Today's Orders",
                                '$_todayOrders',
                                Icons.today),
                            _statBox('Revenue',
                                'Rs. ${_revenue.toStringAsFixed(0)}',
                                Icons.attach_money),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Filter chips
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              'all',
                              'pending',
                              'confirmed',
                              'preparing',
                              'out_for_delivery',
                              'delivered',
                              'cancelled',
                            ].map((f) {
                              final selected = _filter == f;
                              return GestureDetector(
                                onTap: () => setState(
                                    () => _filter = f),
                                child: Container(
                                  margin: const EdgeInsets
                                      .only(right: 8),
                                  padding: const EdgeInsets
                                      .symmetric(
                                      horizontal: 14,
                                      vertical: 7),
                                  decoration: BoxDecoration(
                                    color: selected
                                        ? kRed
                                        : kRedLight,
                                    borderRadius:
                                        BorderRadius.circular(
                                            20),
                                  ),
                                  child: Text(
                                    f.replaceAll('_', ' ')
                                        .toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight:
                                          FontWeight.w600,
                                      color: selected
                                          ? Colors.white
                                          : kRed,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Orders List ───────────────
                _filteredOrders.isEmpty
                    ? const SliverFillRemaining(
                        child: Center(
                          child: Text('No orders found',
                              style: TextStyle(
                                  color: kMuted)),
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final order =
                                _filteredOrders[index];
                            return GestureDetector(
                              onTap: () =>
                                  _showOrderDetails(order),
                              child: Container(
                                margin: const EdgeInsets
                                    .fromLTRB(16, 0, 16, 12),
                                padding:
                                    const EdgeInsets.all(14),
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
                                        _statusBadge(order[
                                            'order_status']),
                                      ],
                                    ),
                                    const SizedBox(height: 6),

                                    // Customer name & phone
                                    Row(
                                      children: [
                                        const Icon(
                                            Icons.person,
                                            size: 14,
                                            color: kMuted),
                                        const SizedBox(
                                            width: 4),
                                        Text(
                                          order['customer_name'],
                                          style: const TextStyle(
                                              fontSize: 13,
                                              color: kMuted),
                                        ),
                                        const SizedBox(
                                            width: 12),
                                        const Icon(
                                            Icons.phone,
                                            size: 14,
                                            color: kMuted),
                                        const SizedBox(
                                            width: 4),
                                        Text(
                                          order['customer_phone'],
                                          style: const TextStyle(
                                              fontSize: 13,
                                              color: kMuted),
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
                                    const SizedBox(height: 4),

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
                                    const SizedBox(height: 8),

                                    // Total & payment
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
                                        Container(
                                          padding: const EdgeInsets
                                              .symmetric(
                                              horizontal: 8,
                                              vertical: 3),
                                          decoration:
                                              BoxDecoration(
                                            color: order['payment_method'] ==
                                                    'khalti'
                                                ? kKhalti
                                                : kEsewa,
                                            borderRadius:
                                                BorderRadius
                                                    .circular(
                                                        6),
                                          ),
                                          child: Text(
                                            order['payment_method']
                                                .toString()
                                                .toUpperCase(),
                                            style: const TextStyle(
                                                color: Colors
                                                    .white,
                                                fontSize: 10,
                                                fontWeight:
                                                    FontWeight
                                                        .w700),
                                          ),
                                        ),
                                      ],
                                    ),

                                    // Time
                                    const SizedBox(height: 4),
                                    Text(
                                      order['created_at'],
                                      style: const TextStyle(
                                          fontSize: 11,
                                          color: kMuted),
                                    ),

                                    // Tap hint
                                    const SizedBox(height: 4),
                                    const Text(
                                      'Tap to see full details →',
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
                          childCount: _filteredOrders.length,
                        ),
                      ),
              ],
            ),
          );
  }

  // ── Helper widgets ────────────────────────
  Widget _statBox(String label, String value,
      IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorder),
      ),
      child: Row(
        children: [
          Icon(icon, color: kRed, size: 22),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(value,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: kRed)),
              Text(label,
                  style: const TextStyle(
                      fontSize: 10, color: kMuted)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(String status) {
    Color color;
    switch (status) {
      case 'pending':
        color = Colors.orange;
        break;
      case 'confirmed':
        color = Colors.blue;
        break;
      case 'preparing':
        color = Colors.purple;
        break;
      case 'out_for_delivery':
        color = Colors.teal;
        break;
      case 'delivered':
        color = Colors.green;
        break;
      case 'cancelled':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(
        status.replaceAll('_', ' ').toUpperCase(),
        style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: color),
      ),
    );
  }

  Widget _detailSection(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(title,
          style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: kMuted)),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label,
                style: const TextStyle(
                    fontSize: 13, color: kMuted)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}