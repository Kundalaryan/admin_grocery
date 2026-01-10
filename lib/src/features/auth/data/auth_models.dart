// lib/src/features/auth/data/auth_models.dart

// 1. Request Body (What you send)
class LoginRequest {
  final String phone;
  final String password;

  LoginRequest({
    required this.phone,
    required this.password,
  });

  // Convert Object -> JSON
  Map<String, dynamic> toJson() {
    return {
      'phone': phone,
      'password': password,
    };
  }
}

// 2. The Inner Data (Token & Role)
class UserData {
  final String token;
  final String role;

  UserData({
    required this.token,
    required this.role,
  });

  // Convert JSON -> Object
  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      token: json['token'] ?? '', // Default to empty string if null
      role: json['role'] ?? '',
    );
  }
}

// 3. The API Wrapper
class LoginResponse {
  final bool success;
  final String message;
  final UserData? data;

  LoginResponse({
    required this.success,
    required this.message,
    this.data,
  });

  // Convert JSON -> Object
  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? 'Unknown Error',
      // If data is null, return null. If not, parse it.
      data: json['data'] != null ? UserData.fromJson(json['data']) : null,
    );
  }
}