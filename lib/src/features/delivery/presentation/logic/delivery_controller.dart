import 'package:dio/dio.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../../core/network/dio_client.dart';
import '../../../orders/data/order_model.dart'; // Reuse existing model

class DeliveryState {
  final bool isLoading;
  final bool isAssigning;
  final List<OrderItem> packedOrders;
  final Set<int> selectedIds; // Tracks checked boxes
  final String? errorMessage;

  DeliveryState({
    this.isLoading = false,
    this.isAssigning = false,
    this.packedOrders = const [],
    this.selectedIds = const {},
    this.errorMessage,
  });

  DeliveryState copyWith({
    bool? isLoading,
    bool? isAssigning,
    List<OrderItem>? packedOrders,
    Set<int>? selectedIds,
    String? errorMessage,
  }) {
    return DeliveryState(
      isLoading: isLoading ?? this.isLoading,
      isAssigning: isAssigning ?? this.isAssigning,
      packedOrders: packedOrders ?? this.packedOrders,
      selectedIds: selectedIds ?? this.selectedIds,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  // Helper to check if all are selected
  bool get isAllSelected => packedOrders.isNotEmpty && selectedIds.length == packedOrders.length;
}

class DeliveryController extends StateNotifier<DeliveryState> {
  final Dio _dio = DioClient().dio;

  DeliveryController() : super(DeliveryState(isLoading: true)) {
    fetchPackedOrders();
  }

  // 1. Fetch PACKED Orders
  Future<void> fetchPackedOrders() async {
    try {
      state = state.copyWith(isLoading: true);

      final response = await _dio.get(
        '/admin/orders',
        queryParameters: {'status': 'PACKED'},
      );

      // Parse List directly (based on your prompt input that it returns [])
      // If it returns {data: []} like before, use response.data['data']
      final List rawList = response.data is List ? response.data : response.data['data']['content'] ?? [];

      final orders = rawList.map((e) => OrderItem.fromJson(e)).toList();

      state = state.copyWith(isLoading: false, packedOrders: orders, selectedIds: {});
    } on DioException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: "Failed to load orders");
    }
  }

  // 2. Selection Logic
  void toggleId(int id) {
    final newSet = Set<int>.from(state.selectedIds);
    if (newSet.contains(id)) {
      newSet.remove(id);
    } else {
      newSet.add(id);
    }
    state = state.copyWith(selectedIds: newSet);
  }

  void toggleSelectAll() {
    if (state.isAllSelected) {
      state = state.copyWith(selectedIds: {});
    } else {
      final allIds = state.packedOrders.map((e) => e.id).toSet();
      state = state.copyWith(selectedIds: allIds);
    }
  }

  // 3. Bulk Assignment Logic
  Future<bool> assignDriver(String phone) async {
    if (state.selectedIds.isEmpty) return false;

    try {
      state = state.copyWith(isAssigning: true);

      // Loop through all selected IDs and call API for each
      // We use Future.wait to run them in parallel (Faster)
      final futures = state.selectedIds.map((id) {
        return _dio.patch(
          '/admin/orders/$id/assign',
          queryParameters: {'deliveryPhone': phone},
        );
      });

      await Future.wait(futures);

      // Refresh list to remove assigned orders
      await fetchPackedOrders();

      state = state.copyWith(isAssigning: false);
      return true;
    } on DioException catch (e) {
      state = state.copyWith(isAssigning: false, errorMessage: "Failed to assign some orders");
      return false;
    }
  }
}

final deliveryProvider = StateNotifierProvider<DeliveryController, DeliveryState>((ref) {
  return DeliveryController();
});