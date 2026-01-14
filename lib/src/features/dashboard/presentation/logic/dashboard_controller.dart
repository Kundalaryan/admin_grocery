import 'package:dio/dio.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/dashboard_model.dart';

// 1. State: What can happen? (Loading, Loaded, Error)
class DashboardState {
  final bool isLoading;
  final String? errorMessage;
  final DashboardData? data;

  DashboardState({this.isLoading = false, this.errorMessage, this.data});
}

// 2. Controller: The Brain
class DashboardController extends StateNotifier<DashboardState> {
  final Dio _dio = DioClient().dio;

  DashboardController() : super(DashboardState(isLoading: true)) {
    loadDashboard(); // Auto-load on init
  }

  Future<void> loadDashboard() async {
    try {
      state = DashboardState(isLoading: true);

      final response = await _dio.get('/admin/dashboard/summary');

      // 1. Log the data to see what is actually coming (helper for debugging)
      // print("Dashboard Data: ${response.data}");

      final result = DashboardResponse.fromJson(response.data);

      if (result.success && result.data != null) {
        state = DashboardState(isLoading: false, data: result.data);
      } else {
        state = DashboardState(isLoading: false, errorMessage: result.message);
      }
    } on DioException catch (e) {
      // Handle Network Errors
      state = DashboardState(
        isLoading: false,
        errorMessage: e.response?.data['message'] ?? "Connection Error",
      );
    } catch (e, stacktrace) {
      // 2. CRITICAL FIX: Handle Parsing/Type Errors
      // This catches "type 'int' is not a subtype of type 'double'" errors
      print("🚨 Parsing Error: $e");
      print(stacktrace);

      state = DashboardState(
        isLoading: false,
        errorMessage: "Data Error: Please contact support.", // User friendly message
      );
    }
  }
}

// 3. Provider: The Bridge to UI
final dashboardProvider = StateNotifierProvider<DashboardController, DashboardState>((ref) {
  return DashboardController();
});