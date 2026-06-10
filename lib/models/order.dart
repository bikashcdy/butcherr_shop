  // lib/models/order.dart

class CartItem {
  final int productId;
  final String productName;
  double quantity;
  final double pricePerKg;
  final String unit;

  CartItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.pricePerKg,
    this.unit = 'kg',
  });

  double get subtotal => quantity * pricePerKg;

  Map<String, dynamic> toJson() => {
    'product_id': productId,
    'quantity':   quantity,
  };
}

class OrderRequest {
  final String customerName;
  final String customerPhone;
  final String deliveryAddress;
  final String ward;
  final String city;
  final String specialNotes;
  final String paymentMethod;
  final List<CartItem> items;
  final int userId;

  OrderRequest({
    required this.customerName,
    required this.customerPhone,
    required this.deliveryAddress,
    required this.ward,
    required this.city,
    required this.specialNotes,
    required this.paymentMethod,
    required this.items,
    this.userId = 0,
  });

  Map<String, dynamic> toJson() => {
    'customer_name':    customerName,
    'customer_phone':   customerPhone,
    'delivery_address': deliveryAddress,
    'ward':             ward,
    'city':             city,
    'special_notes':    specialNotes,
    'payment_method':   paymentMethod,
    'user_id':          userId,
    'items': items.map((i) => i.toJson()).toList(),
  };
}

class OrderResponse {
  final bool success;
  final int orderId;
  final String orderNumber;
  final double totalAmount;
  final String message;

  OrderResponse({
    required this.success,
    required this.orderId,
    required this.orderNumber,
    required this.totalAmount,
    required this.message,
  });

  factory OrderResponse.fromJson(Map<String, dynamic> json) {
    return OrderResponse(
      success:     json['success'] ?? false,
      orderId:     json['order_id'] ?? 0,
      orderNumber: json['order_number'] ?? '',
      totalAmount: double.parse((json['total_amount'] ?? 0).toString()),
      message:     json['message'] ?? '',
    );
  }
}