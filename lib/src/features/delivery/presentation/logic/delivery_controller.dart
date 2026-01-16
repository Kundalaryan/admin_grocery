import 'dart:async'; // <--- Import for Timer
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../../core/network/dio_client.dart';
import '../../../orders/data/order_model.dart';

class DeliveryState {
  final bool isLoading;
  final bool isAssigning;
  final List<OrderItem> packedOrders;
  final Set<int> selectedIds;
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

  bool get isAllSelected => packedOrders.isNotEmpty && selectedIds.length == packedOrders.length;
}

class DeliveryController extends StateNotifier<DeliveryState> {
  final Dio _dio = DioClient().dio;
  Timer? _pollingTimer;

  DeliveryController() : super(DeliveryState(isLoading: true)) {
    fetchPackedOrders(); // Initial Load
    _startPolling(); // Start 30s Loop
  }

  // 1. Start the 30 Second Timer
  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      // Run silently (isBackground: true)
      fetchPackedOrders(isBackground: true);
    });
  }

  // 2. Fetch Logic with Background Support
  Future<void> fetchPackedOrders({bool isBackground = false}) async {
    try {
      // Only show spinner if user pulled to refresh or initial load
      if (!isBackground) {
        state = state.copyWith(isLoading: true, errorMessage: null);
      }

      final response = await _dio.get(
        '/admin/orders',
        queryParameters: {'status': 'PACKED'},
      );

      final List rawList = response.data is List ? response.data : response.data['data']['content'] ?? [];
      final orders = rawList.map((e) => OrderItem.fromJson(e)).toList();

      // If background refresh, keep the selected IDs if they are still in the new list
      Set<int> newSelection = {};
      if (isBackground) {
        final newIds = orders.map((e) => e.id).toSet();
        // Keep IDs that are still valid
        newSelection = state.selectedIds.intersection(newIds);
      }

      state = state.copyWith(
          isLoading: false,
          packedOrders: orders,
          selectedIds: isBackground ? newSelection : {} // Reset selection on manual refresh
      );
    } on DioException catch (e) {
      if (!isBackground) {
        state = state.copyWith(isLoading: false, errorMessage: "Failed to load orders");
      }
    } catch (e) {
      // Catch parsing errors safely
      if (!isBackground) {
        state = state.copyWith(isLoading: false, errorMessage: "Data Error");
      }
    }
  }

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

  Future<bool> assignDriver(String phone) async {
    if (state.selectedIds.isEmpty) return false;

    try {
      state = state.copyWith(isAssigning: true);

      final futures = state.selectedIds.map((id) {
        return _dio.patch(
          '/admin/orders/$id/assign',
          queryParameters: {'deliveryPhone': phone},
        );
      });

      await Future.wait(futures);

      await fetchPackedOrders(); // Refresh list immediately

      state = state.copyWith(isAssigning: false);
      return true;
    } on DioException catch (e) {
      state = state.copyWith(isAssigning: false, errorMessage: "Assignment Failed");
      return false;
    }
  }

  // 3. Cleanup Timer
  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }
}

// Ensure autoDispose is used so timer stops when leaving screen
final deliveryProvider = StateNotifierProvider.autoDispose<DeliveryController, DeliveryState>((ref) {
  return DeliveryController();
});