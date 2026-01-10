// 1. The Individual Order Item
class OrderItem {
  final int id;
  final String customerName;
  final String phone;
  final double totalAmount;
  final String status; // ORDER_PLACED, PACKED, etc.
  final String createdAt;

  OrderItem({
    required this.id,
    required this.customerName,
    required this.phone,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] ?? 0,
      customerName: json['customerName'] ?? 'Unknown',
      phone: json['phone'] ?? '',
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      status: json['status'] ?? 'UNKNOWN',
      createdAt: json['createdAt'] ?? '',
    );
  }
}

// 2. The Pagination Wrapper (Spring Boot "Page" object)
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