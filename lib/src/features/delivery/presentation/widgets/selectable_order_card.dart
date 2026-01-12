import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../orders/data/order_model.dart';

class SelectableOrderCard extends StatelessWidget {
  final OrderItem order;
  final bool isSelected;
  final VoidCallback onToggle;

  const SelectableOrderCard({
    super.key,
    required this.order,
    required this.isSelected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: isSelected
              ? Border.all(color: const Color(0xFF1986E6), width: 2) // Blue border when selected
              : Border.all(color: Colors.transparent, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // 1. Custom Checkbox
            Container(
              height: 24.w,
              width: 24.w,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF1986E6) : Colors.white,
                borderRadius: BorderRadius.circular(6.r),
                border: Border.all(
                  color: isSelected ? const Color(0xFF1986E6) : Colors.grey.shade300,
                ),
              ),
              child: isSelected
                  ? Icon(Icons.check, size: 16.sp, color: Colors.white)
                  : null,
            ),

            SizedBox(width: 16.w),

            // 2. Order Icon (Brown Bag from design)
            Container(
              height: 60.w,
              width: 60.w,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(Icons.shopping_bag, color: Colors.brown.shade300, size: 30.sp),
            ),

            SizedBox(width: 12.w),

            // 3. Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "#ORD-${order.id}",
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14.sp,
                          color: const Color(0xFF1A2B47),
                        ),
                      ),
                      // Packed Badge
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          "PACKED",
                          style: TextStyle(
                              fontSize: 10.sp, fontWeight: FontWeight.w700, color: Colors.green
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    order.customerName,
                    style: TextStyle(
                      fontSize: 13.sp, color: const Color(0xFF64748B),
                    ),
                  ),
                  Text(
                    "Amount: \₹${order.totalAmount}", // Simplify items logic for now
                    style: TextStyle(
                      fontSize: 12.sp, color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}