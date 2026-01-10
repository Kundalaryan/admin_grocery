import 'package:dio/dio.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../../core/network/dio_client.dart'; // Import your DioClient
import '../../../../core/utils/token_storage.dart';
import '../../data/auth_models.dart';

// This state represents the UI: Is it loading? Is there an error?
class LoginState {
  final bool isLoading;
  final String? errorMessage;
  final LoginResponse? successData;

  LoginState({this.isLoading = false, this.errorMessage, this.successData});
}

class LoginController extends StateNotifier<LoginState> {
  final Dio _dio = DioClient().dio; // Access the Dio instance

  LoginController() : super(LoginState());

   // Start Spinner

    // Inside LoginController class...

    Future<bool> login(String phone, String password) async {
      state = LoginState(isLoading: true);

      try {
        final response = await _dio.post(
          '/auth/login',
          // Update: We now call our manual toJson() method
          data: LoginRequest(phone: phone, password: password).toJson(),
        );

        final loginResponse = LoginResponse.fromJson(response.data);

        if (loginResponse.success) {
          // 1. SAVE THE TOKEN!
          if (loginResponse.data != null) {
            await TokenStorage.saveToken(loginResponse.data!.token);
          }

          state = LoginState(isLoading: false, successData: loginResponse);
          return true;
        } else {
          state = LoginState(isLoading: false, errorMessage: loginResponse.message);
          return false;
        }
      } on DioException catch (e) {
        String errorMsg = "Connection error";

        if (e.response != null) {
          final data = e.response?.data;

          // Check 1: Is the error response a JSON Map? (Expected)
          if (data is Map<String, dynamic>) {
            errorMsg = data['message'] ?? "Unknown Server Error";
          }
          // Check 2: Is it just a String? (Common for 403 HTML/Text responses)
          else if (data is String) {
            // If the server returns a long HTML page, we don't want to show that.
            // We show the Status Code instead.
            errorMsg = "Server Error: ${e.response?.statusCode} (Access Denied)";
          }
        }

        state = LoginState(isLoading: false, errorMessage: errorMsg);
        return false;
      }
    }
  }


// The Provider needed to access this in the UI
final loginProvider = StateNotifierProvider<LoginController, LoginState>((ref) {
  return LoginController();
});