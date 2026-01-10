class DashboardData {
  final int totalOrders;
  final int packedOrders;
  final int outForDelivery;
  final int deliveredOrders;
  final int cancelledOrders;
  final double totalCashCollected;

  DashboardData({
    required this.totalOrders,
    required this.packedOrders,
    required this.outForDelivery,
    required this.deliveredOrders,
    required this.cancelledOrders,
    required this.totalCashCollected,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      totalOrders: json['totalOrders'] ?? 0,
      packedOrders: json['packedOrders'] ?? 0,
      outForDelivery: json['outForDelivery'] ?? 0,
      deliveredOrders: json['deliveredOrders'] ?? 0,
      cancelledOrders: json['cancelledOrders'] ?? 0,
      // Handle double even if API sends int (e.g., 500 instead of 500.00)
      totalCashCollected: (json['totalCashCollected'] ?? 0).toDouble(),
    );
  }
}

class DashboardResponse {
  final bool success;
  final String message;
  final DashboardData? data;

  DashboardResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory DashboardResponse.fromJson(Map<String, dynamic> json) {
    return DashboardResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? DashboardData.fromJson(json['data']) : null,
    );
  }
}