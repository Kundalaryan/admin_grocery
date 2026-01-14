import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/order_model.dart';

class OrdersState {
  final bool isLoading;      // Initial load spinner
  final bool isLoadingMore;  // Bottom spinner when scrolling
  final List<OrderItem> orders;
  final String selectedFilter;
  final DateTimeRange? dateRange;
  final String? errorMessage;

  // Pagination Fields
  final int page;
  final bool hasMore;

  OrdersState({
    this.isLoading = false,
    this.isLoadingMore = false,
    this.orders = const [],
    this.selectedFilter = 'All',
    this.dateRange,
    this.errorMessage,
    this.page = 0,
    this.hasMore = true,
  });

  OrdersState copyWith({
    bool? isLoading,
    bool? isLoadingMore,
    List<OrderItem>? orders,
    String? selectedFilter,
    DateTimeRange? dateRange,
    String? errorMessage,
    int? page,
    bool? hasMore,
  }) {
    return OrdersState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      orders: orders ?? this.orders,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      dateRange: dateRange ?? this.dateRange,
      errorMessage: errorMessage ?? this.errorMessage,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

class OrdersController extends StateNotifier<OrdersState> {
  final Dio _dio = DioClient().dio;
  Timer? _pollingTimer;
  final int _pageSize = 20; // Fetch 20 at a time

  OrdersController() : super(OrdersState(isLoading: true)) {
    fetchOrders(); // Initial Load (Page 0)
    _startPolling();
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      // Only poll if we are on the first page to avoid messing up scroll position
      if (state.page == 0 && !state.isLoadingMore) {
        fetchOrders(isBackground: true);
      }
    });
  }

  void setDateRange(DateTimeRange? range) {
    // Reset to Page 0 when filter changes
    state = OrdersState(
      isLoading: true,
      orders: [], // Clear list to avoid confusion
      selectedFilter: state.selectedFilter,
      dateRange: range,
      page: 0,
      hasMore: true,
    );
    fetchOrders();
  }

  void setFilter(String status) {
    state = OrdersState(
      isLoading: true,
      orders: [],
      selectedFilter: status,
      dateRange: state.dateRange,
      page: 0,
      hasMore: true,
    );
    fetchOrders();
  }

  // 1. Fetch First Page (Reset)
  Future<void> fetchOrders({
    String searchQuery = '',
    bool isBackground = false
  }) async {
    try {
      if (!isBackground) {
        state = state.copyWith(isLoading: true, errorMessage: null);
      }

      final params = _buildParams(0, searchQuery); // Always page 0

      final response = await _dio.get('/admin/orders', queryParameters: params);
      final result = OrderListResponse.fromJson(response.data);

      if (result.success) {
        state = state.copyWith(
          isLoading: false,
          orders: result.orders,
          page: 0,
          // If we got fewer items than requested, we reached the end
          hasMore: result.orders.length >= _pageSize,
        );
      } else {
        if (!isBackground) state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      if (!isBackground) state = state.copyWith(isLoading: false, errorMessage: "Error loading data");
    }
  }

  // 2. Load Next Page (Pagination)
  Future<void> loadNextPage() async {
    // Stop if already loading or no more data
    if (state.isLoading || state.isLoadingMore || !state.hasMore) return;

    try {
      state = state.copyWith(isLoadingMore: true);

      final nextPage = state.page + 1;
      final params = _buildParams(nextPage, ''); // Use current filters

      final response = await _dio.get('/admin/orders', queryParameters: params);
      final result = OrderListResponse.fromJson(response.data);

      if (result.success) {
        // APPEND new orders to the existing list
        final newOrders = [...state.orders, ...result.orders];

        state = state.copyWith(
          isLoadingMore: false,
          orders: newOrders,
          page: nextPage,
          hasMore: result.orders.length >= _pageSize,
        );
      } else {
        state = state.copyWith(isLoadingMore: false);
      }
    } catch (e) {
      state = state.copyWith(isLoadingMore: false);
    }
  }

  // Helper to build query params
  Map<String, dynamic> _buildParams(int page, String searchQuery) {
    final Map<String, dynamic> queryParams = {
      'page': page,
      'size': _pageSize,
    };

    if (state.selectedFilter != 'All') {
      queryParams['status'] = state.selectedFilter;
    }

    if (searchQuery.isNotEmpty) {
      queryParams['phone'] = searchQuery;
    }

    if (state.dateRange != null) {
      final formatter = DateFormat('yyyy-MM-dd');
      queryParams['from'] = formatter.format(state.dateRange!.start);
      queryParams['to'] = formatter.format(state.dateRange!.end);
    }
    return queryParams;
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }
}

final ordersProvider = StateNotifierProvider.autoDispose<OrdersController, OrdersState>((ref) {
  return OrdersController();
});