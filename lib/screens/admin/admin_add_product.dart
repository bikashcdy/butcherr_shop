// lib/screens/admin/admin_add_product.dart

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../constants.dart';

class AdminAddProduct extends StatefulWidget {
  final dynamic product; // null = add, not null = edit

  const AdminAddProduct({super.key, this.product});

  @override
  State<AdminAddProduct> createState() =>
      _AdminAddProductState();
}

class _AdminAddProductState
    extends State<AdminAddProduct> {
  final _formKey     = GlobalKey<FormState>();
  final _nameCtrl    = TextEditingController();
  final _descCtrl    = TextEditingController();
  final _priceCtrl   = TextEditingController();
  final _minCtrl     = TextEditingController();
  final _stepCtrl    = TextEditingController();

  bool _isLoading  = false;
  bool _isEditMode = false;
  String _unit     = 'kg';

  @override
  void initState() {
    super.initState();
    // If product passed = edit mode
    if (widget.product != null) {
      _isEditMode = true;
      _nameCtrl.text  = widget.product['name'];
      _descCtrl.text  = widget.product['description'];
      _priceCtrl.text = widget.product['price_per_kg'].toString();
      _minCtrl.text   = widget.product['min_order'].toString();
      _stepCtrl.text  = widget.product['step'].toString();
      _unit           = widget.product['unit'];
    } else {
      // Default values for new product
      _minCtrl.text  = '0.5';
      _stepCtrl.text = '0.25';
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _minCtrl.dispose();
    _stepCtrl.dispose();
    super.dispose();
  }

  // ── Save product ──────────────────────────
  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final body = {
        'name':         _nameCtrl.text.trim(),
        'description':  _descCtrl.text.trim(),
        'price_per_kg': double.parse(_priceCtrl.text),
        'unit':         _unit,
        'min_order':    double.parse(_minCtrl.text),
        'step':         double.parse(_stepCtrl.text),
      };

      http.Response response;

      if (_isEditMode) {
        // Update existing product
        body['id'] = int.parse(
            widget.product['id'].toString()) as dynamic;
        body['is_available'] = int.parse(
            widget.product['is_available']
                .toString()) as dynamic;
        response = await http.post(
          Uri.parse('$kBaseUrl/update_product.php'),
          headers: {
            'Content-Type': 'application/json'
          },
          body: jsonEncode(body),
        );
      } else {
        // Add new product
        response = await http.post(
          Uri.parse('$kBaseUrl/add_product.php'),
          headers: {
            'Content-Type': 'application/json'
          },
          body: jsonEncode(body),
        );
      }

      if (!mounted) return;
      setState(() => _isLoading = false);

      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        _showSnack(data['message'], Colors.green);
        await Future.delayed(
            const Duration(milliseconds: 500));
        if (!mounted) return;
        Navigator.pop(context);
      } else {
        _showSnack(data['message'], Colors.red);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnack(
          'Failed to save product. Check internet.',
          Colors.red);
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(msg),
          backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            _isEditMode ? 'Edit Product' : 'Add Product'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [

              // ── Product Name ──────────────
              _label('Product Name *'),
              TextFormField(
                controller: _nameCtrl,
                validator: (v) {
                  if (v == null || v.isEmpty)
                    return 'Product name is required';
                  return null;
                },
                decoration: const InputDecoration(
                  hintText: 'e.g. Whole Chicken',
                  prefixIcon: Icon(
                      Icons.set_meal,
                      color: kMuted),
                ),
              ),
              const SizedBox(height: 14),

              // ── Description ───────────────
              _label('Description'),
              TextFormField(
                controller: _descCtrl,
                maxLines: 2,
                decoration: const InputDecoration(
                  hintText:
                      'e.g. Fresh whole chicken, cleaned on request',
                  prefixIcon: Icon(
                      Icons.description_outlined,
                      color: kMuted),
                ),
              ),
              const SizedBox(height: 14),

              // ── Price ─────────────────────
              _label('Price per kg (Rs.) *'),
              TextFormField(
                controller: _priceCtrl,
                keyboardType:
                    TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty)
                    return 'Price is required';
                  if (double.tryParse(v) == null)
                    return 'Enter valid price';
                  if (double.parse(v) <= 0)
                    return 'Price must be greater than 0';
                  return null;
                },
                decoration: const InputDecoration(
                  hintText: 'e.g. 280',
                  prefixIcon: Icon(
                      Icons.attach_money,
                      color: kMuted),
                  prefixText: 'Rs. ',
                ),
              ),
              const SizedBox(height: 14),

              // ── Unit ──────────────────────
              _label('Unit'),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(10),
                  border:
                      Border.all(color: kBorder,
                          width: 1.5),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _unit,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(
                          value: 'kg',
                          child: Text('kg (Kilogram)')),
                      DropdownMenuItem(
                          value: 'piece',
                          child: Text('piece')),
                      DropdownMenuItem(
                          value: 'g',
                          child: Text('g (Gram)')),
                    ],
                    onChanged: (val) =>
                        setState(() => _unit = val!),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // ── Min Order & Step ──────────
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        _label('Min Order *'),
                        TextFormField(
                          controller: _minCtrl,
                          keyboardType:
                              TextInputType.number,
                          validator: (v) {
                            if (v == null ||
                                v.isEmpty)
                              return 'Required';
                            if (double.tryParse(v) ==
                                null)
                              return 'Invalid';
                            return null;
                          },
                          decoration: InputDecoration(
                            hintText: '0.5',
                            suffixText: _unit,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        _label('Step *'),
                        TextFormField(
                          controller: _stepCtrl,
                          keyboardType:
                              TextInputType.number,
                          validator: (v) {
                            if (v == null ||
                                v.isEmpty)
                              return 'Required';
                            if (double.tryParse(v) ==
                                null)
                              return 'Invalid';
                            return null;
                          },
                          decoration: InputDecoration(
                            hintText: '0.25',
                            suffixText: _unit,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Step hint
              const Text(
                '* Step = how much quantity increases/decreases per tap',
                style: TextStyle(
                    fontSize: 11, color: kMuted),
              ),
              const SizedBox(height: 24),

              // ── Save Button ───────────────
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed:
                      _isLoading ? null : _saveProduct,
                  icon: Icon(_isEditMode
                      ? Icons.save
                      : Icons.add),
                  label: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child:
                              CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2))
                      : Text(_isEditMode
                          ? 'Save Changes'
                          : 'Add Product'),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(
          text,
          style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: kMuted),
        ),
      );
}