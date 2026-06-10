// lib/widgets/product_card.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../models/product.dart';
import '../services/cart_provider.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final qty  = cart.getQty(product.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            // Emoji icon
            Container(
              width: 54, height: 54,
              decoration: BoxDecoration(
                color: kRedLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(product.emoji, style: const TextStyle(fontSize: 26)),
              ),
            ),
            const SizedBox(width: 14),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(product.description,
                      style: const TextStyle(fontSize: 11, color: kMuted)),
                  const SizedBox(height: 4),
                  Text('Rs. ${product.pricePerKg.toStringAsFixed(0)} / ${product.unit}',
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600, color: kRed)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: kBone,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text('Min: ${product.minOrder} ${product.unit}',
                        style: const TextStyle(fontSize: 10, color: kMuted)),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            // Quantity control
            Column(
              children: [
                // + button
                _QBtn(
                  icon: Icons.add,
                  onTap: () => cart.addItem(product),
                ),
                const SizedBox(height: 6),
                // Quantity display
                SizedBox(
                  width: 38,
                  child: Column(
                    children: [
                      Text(qty > 0 ? qty.toString() : '0',
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600),
                          textAlign: TextAlign.center),
                      Text(product.unit,
                          style: const TextStyle(fontSize: 10, color: kMuted),
                          textAlign: TextAlign.center),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                // - button
                _QBtn(
                  icon: Icons.remove,
                  onTap: qty > 0 ? () => cart.removeItem(product) : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _QBtn({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28, height: 28,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: onTap != null ? kRed : kBorder, width: 1.5),
          color: onTap != null ? Colors.transparent : kBone,
        ),
        child: Icon(icon, size: 16, color: onTap != null ? kRed : kMuted),
      ),
    );
  }
}