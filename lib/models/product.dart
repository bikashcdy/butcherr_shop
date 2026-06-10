// lib/models/product.dart

class Product {
  final int id;
  final String name;
  final String description;
  final double pricePerKg;
  final String unit;
  final double minOrder;
  final double step;
  final String emoji;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.pricePerKg,
    this.unit = 'kg',
    this.minOrder = 0.5,
    this.step = 0.25,
    this.emoji = '🐔',
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id:          int.parse(json['id'].toString()),
      name:        json['name'],
      description: json['description'] ?? '',
      pricePerKg:  double.parse(json['price_per_kg'].toString()),
      unit:        json['unit'] ?? 'kg',
      minOrder:    double.parse(json['min_order'].toString()),
      step:        double.parse(json['step'].toString()),
    );
  }
}