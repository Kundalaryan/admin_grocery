import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class OrderTimeline extends StatelessWidget {
  final String currentStatus;

  const OrderTimeline({super.key, required this.currentStatus});

  @override
  Widget build(BuildContext context) {
    // Define the sequence of steps
    final steps = ["ORDER_PLACED", "PACKED", "OUT_FOR_DELIVERY", "DELIVERED"];
    final labels = ["Order Placed", "Packing", "Out for Delivery", "Delivered"];

    // Find where we are currently (e.g., index 2)
    int currentIndex = steps.indexOf(currentStatus);
    if (currentIndex == -1) currentIndex = 0; // Default if unknown

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Order Status", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 16.sp)),
              Text("Edit Status", style: GoogleFonts.plusJakartaSans(color: const Color(0xFF1986E6), fontWeight: FontWeight.w600, fontSize: 13.sp)),
            ],
          ),
          SizedBox(height: 20.h),

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: steps.length,
            itemBuilder: (context, index) {
              final bool isCompleted = index <= currentIndex;
              final bool isLast = index == steps.length - 1;

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. The Line and Dot
                  Column(
                    children: [
                      Container(
                        width: 24.w,
                        height: 24.w,
                        decoration: BoxDecoration(
                          color: isCompleted ? const Color(0xFF1986E6) : const Color(0xFFE2E8F0),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isCompleted ? Icons.check : Icons.circle,
                          color: Colors.white,
                          size: 14.sp,
                        ),
                      ),
                      if (!isLast)
                        Container(
                          width: 2.w,
                          height: 30.h, // Length of line
                          color: isCompleted ? const Color(0xFF1986E6) : const Color(0xFFE2E8F0),
                        ),
                    ],
                  ),
                  SizedBox(width: 12.w),

                  // 2. The Text
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        labels[index],
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w700,
                          fontSize: 14.sp,
                          color: isCompleted ? const Color(0xFF1A2B47) : Colors.grey,
                        ),
                      ),
                      if (isCompleted) ...[
                        SizedBox(height: 2.h),
                        Text(
                          "Completed", // You can put actual dates here if API provides them per status
                          style: GoogleFonts.plusJakartaSans(fontSize: 11.sp, color: Colors.grey),
                        ),
                      ],
                      SizedBox(height: 20.h), // Spacing between items
                    ],
                  )
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}