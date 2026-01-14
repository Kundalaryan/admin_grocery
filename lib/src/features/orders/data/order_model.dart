
class OrderItem {
  final int id;
  final String customerName;
  final String customerPhone; // Updated to match JSON
  final String address;       // Added to match JSON
  final double totalAmount;
  final String status;
  final String createdAt;

  OrderItem({
    required this.id,
    required this.customerName,
    required this.customerPhone,
    required this.address,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] ?? 0,
      customerName: json['customerName'] ?? 'Unknown Customer',
      customerPhone: json['customerPhone'] ?? json['phone'] ?? '',
      address: json['address'] ?? '',

      // FIX: Handle both int and double safely
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,

      status: json['status'] ?? 'UNKNOWN',
      createdAt: json['createdAt'] ?? '',
    );
  }
}

// Keep the OrderListResponse as it was
class OrderListResponse {
  final bool success;
  final List<OrderItem> orders;
  final int totalPages;
  final int totalElements;

  OrderListResponse({
    required this.success,
    required this.orders,
    required this.totalPages,
    required this.totalElements,
  });

  factory OrderListResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    final content = data['content'] as List? ?? [];

    return OrderListResponse(
      success: json['success'] ?? false,
      orders: content.map((e) => OrderItem.fromJson(e)).toList(),
      totalPages: data['totalPages'] ?? 0,
      totalElements: data['totalElements'] ?? 0,
    );
  }
}