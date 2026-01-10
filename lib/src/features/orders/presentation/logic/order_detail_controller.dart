import 'package:dio/dio.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/order_detail_model.dart';

class OrderDetailState {
  final bool isLoading;
  final OrderDetailData? order;
  final String? errorMessage;

  OrderDetailState({this.isLoading = false, this.order, this.errorMessage});
}

class OrderDetailController extends StateNotifier<OrderDetailState> {
  final Dio _dio = DioClient().dio;

  OrderDetailController() : super(OrderDetailState());

  // Pass the ID to this function
  Future<void> fetchOrderDetails(int orderId) async {
    try {
      state = OrderDetailState(isLoading: true);

      // Call API: /admin/orders/getdetails/123
      final response = await _dio.get('/admin/orders/getdetails/$orderId');

      final result = OrderDetailResponse.fromJson(response.data);

      if (result.success && result.data != null) {
        state = OrderDetailState(isLoading: false, order: result.data);
      } else {
        state = OrderDetailState(isLoading: false, errorMessage: result.message);
      }
    } on DioException catch (e) {
      state = OrderDetailState(
          isLoading: false,
          errorMessage: e.response?.data['message'] ?? "Connection Error"
      );
    }
  }
  Future<bool> updateOrderStatus(int orderId, String newStatus) async {
    try {
      // 1. Call the PATCH API
      final response = await _dio.patch(
        '/admin/orders/$orderId/status',
        data: {
          "status": newStatus // Request Body
        },
      );

      // 2. Check response
      // We check response.data directly because we didn't make a model for the generic response
      if (response.data['success'] == true) {

        // 3. IMPORTANT: Refresh the UI by fetching the details again
        await fetchOrderDetails(orderId);

        return true; // Success
      } else {
        return false; // Failed logic
      }
    } on DioException catch (e) {
      // You might want to show a toast here in a real app
      return false;
    }
  }
  Future<bool> cancelOrder(int orderId) async {
    try {
      // 1. Call the Cancel API (PATCH /admin/orders/{id}/cancel)
      // No data body needed based on your description, just the path.
      final response = await _dio.patch('/admin/orders/$orderId/cancel');

      // 2. Check response
      if (response.data['success'] == true) {

        // 3. Refresh the UI to show the red "Cancelled" status
        await fetchOrderDetails(orderId);
        return true;
      } else {
        return false;
      }
    } on DioException catch (e) {
      return false;
    }
  }
}


// Global provider
final orderDetailProvider = StateNotifierProvider.autoDispose<OrderDetailController, OrderDetailState>((ref) {
  return OrderDetailController();
});