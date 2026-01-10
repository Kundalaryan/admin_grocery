import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

// --- IMPORTS ---
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/pattern_background.dart'; // <--- ADD THIS IMPORT
import '../../../main_wrapper.dart';
import '../logic/login_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordHidden = true;

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(loginProvider);
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      body: PatternBackground(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              children: [
                // --- THE MAIN CARD ---
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32.r),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1986E6).withOpacity(0.08),
                        blurRadius: 40,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8.w),
                              decoration: BoxDecoration(
                                color: primaryColor,
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              child: Icon(Icons.store_rounded, color: Colors.white, size: 20.sp),
                            ),
                            SizedBox(width: 10.w),
                            Text(
                              "MARKETADMIN",
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFFA0AEC0),
                                letterSpacing: 1.0,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 24.h),

                        // Headlines
                        Text(
                          "Hello,\nWelcome Back!",
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 32.sp,
                            fontWeight: FontWeight.w800,
                            height: 1.2,
                            color: const Color(0xFF1A2B47),
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          "Manage your grocery inventory &\nsales easily.",
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF7CA0BA),
                            height: 1.5,
                          ),
                        ),
                        SizedBox(height: 32.h),

                        // Inputs
                        CustomTextField(
                          label: "Phone Number",
                          hint: "Enter your phone",
                          prefixIcon: Icons.phone_outlined,
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Required';
                            if (value.length < 10) return 'Invalid phone number';
                            return null;
                          },
                        ),
                        SizedBox(height: 20.h),
                        CustomTextField(
                          label: "Password",
                          hint: "Enter your password",
                          prefixIcon: Icons.lock_outline_rounded,
                          controller: _passwordController,
                          isPassword: true,
                          isObscured: _isPasswordHidden,
                          onToggleVisibility: () {
                            setState(() {
                              _isPasswordHidden = !_isPasswordHidden;
                            });
                          },
                          validator: (val) => val!.length < 3 ? "Password too short" : null,
                        ),

                        // Forgot Password
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {},
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              "Forgot Password?",
                              style: GoogleFonts.plusJakartaSans(
                                color: primaryColor,
                                fontWeight: FontWeight.w700,
                                fontSize: 14.sp,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 24.h),

                        // Error Message Box
                        if (loginState.errorMessage != null)
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(12.w),
                            margin: EdgeInsets.only(bottom: 16.h),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(color: Colors.red.withOpacity(0.2)),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.error_outline, color: Colors.red, size: 20.sp),
                                SizedBox(width: 8.w),
                                Expanded(
                                  child: Text(
                                    loginState.errorMessage!,
                                    style: TextStyle(color: Colors.red, fontSize: 13.sp),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // --- LOGIN BUTTON WITH NAVIGATION ---
                        SizedBox(
                          width: double.infinity,
                          height: 56.h,
                          child: ElevatedButton(
                            onPressed: loginState.isLoading
                                ? null
                                : () async {
                              if (_formKey.currentState!.validate()) {
                                // 1. Call API and capture result
                                final success = await ref.read(loginProvider.notifier).login(
                                  _phoneController.text,
                                  _passwordController.text,
                                );

                                // 2. If success, Navigate
                                if (success && context.mounted) {
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(builder: (context) => const MainWrapper())
                                  );
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              elevation: 4,
                              shadowColor: primaryColor.withOpacity(0.4),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16.r),
                              ),
                            ),
                            child: loginState.isLoading
                                ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                            )
                                : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Log In",
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20.sp)
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: 24.h),

                        // Footer
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Need help? ",
                                style: GoogleFonts.plusJakartaSans(
                                  color: const Color(0xFF7CA0BA),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14.sp,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {},
                                child: Text(
                                  "Contact Support",
                                  style: GoogleFonts.plusJakartaSans(
                                    color: primaryColor,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14.sp,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 32.h),
                // Bottom Icon
                Icon(
                  Icons.verified_user_outlined,
                  color: const Color(0xFFB0C4DE),
                  size: 28.sp,
                ),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}