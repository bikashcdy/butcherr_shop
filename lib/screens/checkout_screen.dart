// lib/screens/checkout_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../models/order.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/cart_provider.dart';
import 'confirmation_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey    = GlobalKey<FormState>();
  final _nameCtrl   = TextEditingController();
  final _phoneCtrl  = TextEditingController();
  final _streetCtrl = TextEditingController();
  final _wardCtrl   = TextEditingController();
  final _cityCtrl   = TextEditingController(text: 'Butwal');
  final _notesCtrl  = TextEditingController();

  String _paymentMethod = 'esewa';
  bool   _isLoading     = false;

  @override
  void initState() {
    super.initState();
    _loadUserDetails();
  }

  // ── Load user details automatically ───────
  Future<void> _loadUserDetails() async {
    final user = await AuthService.getCurrentUser();
    if (user != null) {
      setState(() {
        _nameCtrl.text = user.name;
      });
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _streetCtrl.dispose();
    _wardCtrl.dispose();
    _cityCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  // ── Place Order ───────────────────────────
  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final cart = Provider.of<CartProvider>(
        context, listen: false);

    // Get current user
    final user = await AuthService.getCurrentUser();

    final orderRequest = OrderRequest(
      customerName:    _nameCtrl.text.trim(),
      customerPhone:   _phoneCtrl.text.trim(),
      deliveryAddress: _streetCtrl.text.trim(),
      ward:            _wardCtrl.text.trim(),
      city:            _cityCtrl.text.trim(),
      specialNotes:    _notesCtrl.text.trim(),
      paymentMethod:   _paymentMethod,
      items:           cart.itemList,
      userId:          user?.id ?? 0,
    );

    try {
      final response =
          await ApiService.placeOrder(orderRequest);

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (response.success) {
        if (_paymentMethod == 'khalti') {
          _initiateKhalti(response, cart);
        } else {
          _initiateEsewa(response, cart);
        }
      } else {
        _showSnack(response.message);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnack('Failed to place order. Check internet.');
    }
  }

  // ── Khalti Payment ────────────────────────
  void _initiateKhalti(
      OrderResponse order, CartProvider cart) {
    // TODO: Add Khalti SDK integration
    _goToConfirmation(order, cart);
  }

  // ── eSewa Payment ─────────────────────────
  void _initiateEsewa(
      OrderResponse order, CartProvider cart) {
    // TODO: Add eSewa WebView integration
    _goToConfirmation(order, cart);
  }

  void _goToConfirmation(
      OrderResponse order, CartProvider cart) {
    cart.clearCart();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => ConfirmationScreen(
          orderNumber: order.orderNumber,
          totalAmount: order.totalAmount,
          deliveryAddress:
              '${_streetCtrl.text}, Ward ${_wardCtrl.text}, ${_cityCtrl.text}',
          paymentMethod: _paymentMethod,
        ),
      ),
      (route) => route.isFirst,
    );
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(msg),
            backgroundColor: kRedDark));
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
          title: const Text('Delivery & Payment')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [

              // ── YOUR DETAILS ──────────────
              _sectionTitle('YOUR DETAILS'),
              _field(
                controller: _nameCtrl,
                label: 'Full Name *',
                hint: 'e.g. Ram Bahadur Thapa',
                validator: (v) => v!.isEmpty
                    ? 'Name is required'
                    : null,
              ),
              const SizedBox(height: 10),
              _field(
                controller: _phoneCtrl,
                label: 'Phone Number *',
                hint: '98XXXXXXXX',
                keyboardType: TextInputType.phone,
                maxLength: 10,
                validator: (v) {
                  if (v == null || v.isEmpty)
                    return 'Phone is required';
                  if (!RegExp(r'^9[78]\d{8}$')
                      .hasMatch(v))
                    return 'Enter valid Nepal number';
                  return null;
                },
              ),

              // ── DELIVERY ADDRESS ──────────
              const SizedBox(height: 16),
              _sectionTitle('DELIVERY ADDRESS'),
              _field(
                controller: _streetCtrl,
                label: 'Street / Tole *',
                hint: 'e.g. Shantinagar Tole',
                validator: (v) => v!.isEmpty
                    ? 'Address is required'
                    : null,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: _field(
                      controller: _wardCtrl,
                      label: 'Ward No.',
                      hint: 'e.g. 5',
                      keyboardType:
                          TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 3,
                    child: _field(
                      controller: _cityCtrl,
                      label: 'City *',
                      hint: 'Butwal',
                      validator: (v) => v!.isEmpty
                          ? 'City required'
                          : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _notesCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText:
                      'Cutting Instructions (optional)',
                  hintText:
                      'e.g. Small pieces, remove skin...',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(10)),
                ),
              ),

              // ── PAYMENT METHOD ────────────
              const SizedBox(height: 16),
              _sectionTitle('PAYMENT METHOD'),
              _payOption(
                label: 'eSewa',
                value: 'esewa',
                color: kEsewa,
                icon: 'e',
              ),
              const SizedBox(height: 8),
              _payOption(
                label: 'Khalti',
                value: 'khalti',
                color: kKhalti,
                icon: 'K',
              ),

              // ── ORDER SUMMARY ─────────────
              const SizedBox(height: 16),
              _sectionTitle('ORDER SUMMARY'),
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
                    ...cart.itemList.map((item) =>
                        Padding(
                          padding: const EdgeInsets
                              .symmetric(vertical: 4),
                          child: Row(
                            mainAxisAlignment:
                                MainAxisAlignment
                                    .spaceBetween,
                            children: [
                              Text(
                                '${item.productName} (${item.quantity} kg)',
                                style: const TextStyle(
                                    fontSize: 13,
                                    color: kMuted),
                              ),
                              Text(
                                'Rs. ${item.subtotal.toStringAsFixed(0)}',
                                style: const TextStyle(
                                    fontSize: 13),
                              ),
                            ],
                          ),
                        )),
                    const Divider(color: kBorder),
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment
                              .spaceBetween,
                      children: [
                        const Text('Total',
                            style: TextStyle(
                                fontWeight:
                                    FontWeight.w700,
                                fontSize: 15)),
                        Text(
                          'Rs. ${cart.totalAmount.toStringAsFixed(0)}',
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

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      _isLoading ? null : _placeOrder,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child:
                              CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2))
                      : Text(
                          'Confirm & Pay with ${_paymentMethod == 'khalti' ? 'Khalti' : 'eSewa'} →'),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text,
            style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: kMuted,
                letterSpacing: 1)),
      );

  Widget _field({
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType? keyboardType,
    int? maxLength,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLength: maxLength,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        counterText: '',
      ),
    );
  }

  Widget _payOption({
    required String label,
    required String value,
    required Color color,
    required String icon,
  }) {
    final selected = _paymentMethod == value;
    return GestureDetector(
      onTap: () =>
          setState(() => _paymentMethod = value),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected ? kRedLight : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: selected ? kRed : kBorder,
              width: selected ? 2 : 1),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                  color: color,
                  borderRadius:
                      BorderRadius.circular(6)),
              child: Text(icon,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700)),
            ),
            const SizedBox(width: 12),
            Text(label,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500)),
            const Spacer(),
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    color:
                        selected ? kRed : kBorder,
                    width: 2),
              ),
              child: selected
                  ? Center(
                      child: Container(
                          width: 8,
                          height: 8,
                          decoration:
                              const BoxDecoration(
                                  color: kRed,
                                  shape: BoxShape
                                      .circle)))
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}