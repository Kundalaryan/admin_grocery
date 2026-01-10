import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/utils/token_storage.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import '../../../main_wrapper.dart';

// Note: Later we will move colors to src/core/theme/app_colors.dart
class AppColors {
  static const Color primaryBlue = Color(0xFF1E88E5); // The blue from the icon
  static const Color lightBlueBg = Color(0xFFF0F4F8); // Very light blue for gradient
  static const Color white = Colors.white;
  static const Color darkText = Color(0xFF0D1B2A);
  static const Color greyText = Color(0xFF90949D);
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    // 1. Wait a bit for the animation to show (UX)
    await Future.delayed(const Duration(seconds: 2));

    // 2. Check Storage
    final token = await TokenStorage.getToken();

    if (!mounted) return;

    if (token != null && token.isNotEmpty) {
      // 3. Token found -> Go to Dashboard
      print("✅ Token found, Auto-login");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainWrapper()),
      );
    } else {
      // 4. No Token -> Go to Login
      print("❌ No Token, Go to Login");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        // 2. The Subtle Gradient Background
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFE3F2FD), // Light Blue top
              Colors.white,      // White bottom
            ],
          ),
        ),
        child: Column(
          children: [
            // Spacer pushes content to center
            const Spacer(flex: 2),

            // --- 3. The Logo Card ---
            Container(
              height: 120.h,
              width: 120.h, // Square shape
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24.r), // Adaptive radius
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.1),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Center(
                // Replacing SVG with Icon for immediate testing
                child: Icon(
                  Icons.store_rounded,
                  size: 60.sp,
                  color: AppColors.primaryBlue,
                ),
              ),
            ),

            SizedBox(height: 30.h),

            // --- 4. Main Title ---
            Text(
              "Store Manager",
              style: GoogleFonts.poppins(
                fontSize: 28.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.darkText,
                letterSpacing: -0.5,
              ),
            ),

            SizedBox(height: 8.h),

            // --- 5. Subtitle ---
            Text(
              "Admin Dashboard",
              style: GoogleFonts.poppins(
                fontSize: 16.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.greyText,
              ),
            ),

            SizedBox(height: 50.h),

            // --- 6. Custom Progress Bar ---
            SizedBox(
              width: 150.w, // Fixed width for the loader
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.r),
                child: LinearProgressIndicator(
                  minHeight: 6.h,
                  backgroundColor: Colors.blue.withOpacity(0.1),
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
                ),
              ),
            ),

            const Spacer(flex: 2),

            // --- 7. Footer ---
            Text(
              "Powered by GroceryOS",
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.greyText.withOpacity(0.8),
              ),
            ),
            SizedBox(height: 5.h),
            Text(
              "v1.0",
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                color: AppColors.greyText.withOpacity(0.5),
              ),
            ),

            SizedBox(height: 40.h), // Bottom Safe Area
          ],
        ),
      ),
    );
  }
}