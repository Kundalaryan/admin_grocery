// lib/src/core/widgets/custom_text_field.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final String hint;
  final IconData prefixIcon;
  final bool isPassword;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final VoidCallback? onToggleVisibility; // Added for password eye
  final bool? isObscured; // Added for password state

  const CustomTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.prefixIcon,
    required this.controller,
    this.isPassword = false,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.onToggleVisibility,
    this.isObscured,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // UPPERCASE LABEL
        Text(
          label.toUpperCase(),
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF7CA0BA), // Blue-grey label color
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          obscureText: isObscured ?? false,
          validator: validator,
          keyboardType: keyboardType,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A2B47),
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
                color: const Color(0xFFA0AEC0),
                fontSize: 14.sp,
                fontWeight: FontWeight.w500
            ),
            prefixIcon: Icon(prefixIcon, color: const Color(0xFF7CA0BA), size: 20.sp),

            // Password Eye Icon
            suffixIcon: isPassword
                ? IconButton(
              icon: Icon(
                (isObscured ?? true) ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: const Color(0xFF7CA0BA),
                size: 20.sp,
              ),
              onPressed: onToggleVisibility,
            )
                : null,

            contentPadding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
            filled: true,
            fillColor: const Color(0xFFF5F8FC), // The very light blue input bg

            // No Borders (Just rounded)
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)), // Subtle border
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: Color(0xFF1986E6), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}