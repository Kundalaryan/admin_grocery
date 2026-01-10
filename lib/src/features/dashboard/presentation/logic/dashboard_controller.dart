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

      // TODO: Ensure your DioClient adds the 'Authorization: Bearer <token>' header
      final response = await _dio.get('/admin/dashboard/summary');

      final result = DashboardResponse.fromJson(response.data);

      if (result.success && result.data != null) {
        state = DashboardState(isLoading: false, data: result.data);
      } else {
        state = DashboardState(isLoading: false, errorMessage: result.message);
      }
    } on DioException catch (e) {
      state = DashboardState(
        isLoading: false,
        errorMessage: e.response?.data['message'] ?? "Connection Error",
      );
    }
  }
}

// 3. Provider: The Bridge to UI
final dashboardProvider = StateNotifierProvider<DashboardController, DashboardState>((ref) {
  return DashboardController();
});