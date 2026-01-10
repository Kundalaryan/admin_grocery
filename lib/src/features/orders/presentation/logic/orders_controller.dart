import 'package:dio/dio.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/order_model.dart';

// 1. State: Holds the list and loading status
class OrdersState {
  final bool isLoading;
  final List<OrderItem> orders;
  final String selectedFilter; // "All", "ORDER_PLACED", etc.
  final String? errorMessage;

  OrdersState({
    this.isLoading = false,
    this.orders = const [],
    this.selectedFilter = 'All',
    this.errorMessage,
  });

  // Helper to copy state easily
  OrdersState copyWith({
    bool? isLoading,
    List<OrderItem>? orders,
    String? selectedFilter,
    String? errorMessage,
  }) {
    return OrdersState(
      isLoading: isLoading ?? this.isLoading,
      orders: orders ?? this.orders,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// 2. Controller
class OrdersController extends StateNotifier<OrdersState> {
  final Dio _dio = DioClient().dio;

  OrdersController() : super(OrdersState(isLoading: true)) {
    fetchOrders(); // Load "All" initially
  }

  // A. Change Filter
  void setFilter(String status) {
    state = state.copyWith(selectedFilter: status, isLoading: true);
    fetchOrders();
  }

  // B. Fetch Data from API
  Future<void> fetchOrders({String searchQuery = ''}) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      // Prepare Query Parameters
      final Map<String, dynamic> queryParams = {
        'page': 0,
        'size': 20, // Fetch 20 at a time
      };

      // Only add status if it's NOT "All"
      if (state.selectedFilter != 'All') {
        queryParams['status'] = state.selectedFilter;
      }

      // Add search if user typed something
      if (searchQuery.isNotEmpty) {
        queryParams['phone'] = searchQuery; // API searches by phone? Or name? Adjust accordingly
      }

      final response = await _dio.get(
        '/admin/orders',
        queryParameters: queryParams,
      );

      final result = OrderListResponse.fromJson(response.data);

      if (result.success) {
        state = state.copyWith(isLoading: false, orders: result.orders);
      } else {
        state = state.copyWith(isLoading: false, orders: [], errorMessage: "Failed to load");
      }
    } on DioException catch (e) {
      state = state.copyWith(
          isLoading: false,
          errorMessage: e.response?.data['message'] ?? "Connection Error"
      );
    }
  }
}

// 3. Provider
final ordersProvider = StateNotifierProvider<OrdersController, OrdersState>((ref) {
  return OrdersController();
});