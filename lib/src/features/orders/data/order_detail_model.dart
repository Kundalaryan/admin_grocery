class ProductItem {
  final int productId;
  final String productName;
  final int quantity;
  final double price;
  final double total;

  ProductItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
    required this.total,
  });

  factory ProductItem.fromJson(Map<String, dynamic> json) {
    return ProductItem(
      productId: json['productId'] ?? 0,
      productName: json['productName'] ?? 'Unknown Item',
      quantity: json['quantity'] ?? 0,
      price: (json['price'] ?? 0).toDouble(),
      total: (json['total'] ?? 0).toDouble(),
    );
  }
}

class OrderDetailData {
  final int orderId;
  final String status;
  final String createdAt;
  final String customerPhone;
  final String address;
  final String deliveryPhone; // Driver phone
  final double totalAmount;
  final List<ProductItem> items;

  OrderDetailData({
    required this.orderId,
    required this.status,
    required this.createdAt,
    required this.customerPhone,
    required this.address,
    required this.deliveryPhone,
    required this.totalAmount,
    required this.items,
  });

  factory OrderDetailData.fromJson(Map<String, dynamic> json) {
    return OrderDetailData(
      orderId: json['orderId'] ?? 0,
      status: json['status'] ?? 'UNKNOWN',
      createdAt: json['createdAt'] ?? '',
      customerPhone: json['customerPhone'] ?? '',
      address: json['address'] ?? '',
      deliveryPhone: json['deliveryPhone'] ?? '',
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      items: (json['items'] as List? ?? [])
          .map((e) => ProductItem.fromJson(e))
          .toList(),
    );
  }
}

class OrderDetailResponse {
  final bool success;
  final String message;
  final OrderDetailData? data;

  OrderDetailResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory OrderDetailResponse.fromJson(Map<String, dynamic> json) {
    return OrderDetailResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? OrderDetailData.fromJson(json['data']) : null,
    );
  }
}