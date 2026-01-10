import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../data/order_model.dart';
import '../screens/order_detail_screen.dart'; // <--- 1. ADD THIS IMPORT

class OrderCard extends StatelessWidget {
  final OrderItem order;

  const OrderCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    // Helper to format date
    String formattedDate = order.createdAt;
    try {
      final date = DateTime.parse(order.createdAt);
      formattedDate = DateFormat('MMM d, h:mm a').format(date);
    } catch (e) {
      // Keep original string if parse fails
    }

    // <--- 2. WRAP WITH GESTURE DETECTOR
    return GestureDetector(
      onTap: () {
        // Navigate to Detail Screen with the Order ID
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderDetailScreen(orderId: order.id),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
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
            // 1. Icon Box (Left)
            Container(
              height: 50.h,
              width: 50.h,
              decoration: BoxDecoration(
                color: _getStatusColor(order.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                _getStatusIcon(order.status),
                color: _getStatusColor(order.status),
                size: 24.sp,
              ),
            ),

            SizedBox(width: 16.w),

            // 2. Middle Details
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
                      // Status Badge
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: _getStatusColor(order.status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          _formatStatus(order.status),
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w700,
                            color: _getStatusColor(order.status),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    order.customerName,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        formattedDate,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: const Color(0xFFA0AEC0),
                        ),
                      ),
                      Text(
                        NumberFormat.simpleCurrency().format(order.totalAmount),
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1986E6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- HELPERS FOR STYLING ---

  Color _getStatusColor(String status) {
    switch (status) {
      case 'ORDER_PLACED': return Colors.orange;
      case 'PACKED': return Colors.blue;
      case 'OUT_FOR_DELIVERY': return const Color(0xFF1986E6);
      case 'DELIVERED': return Colors.green;
      case 'CANCELLED': return Colors.red;
      default: return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'ORDER_PLACED': return Icons.shopping_bag_outlined;
      case 'PACKED': return Icons.inventory_2_outlined;
      case 'OUT_FOR_DELIVERY': return Icons.local_shipping_outlined;
      case 'DELIVERED': return Icons.check_circle_outline;
      case 'CANCELLED': return Icons.cancel_outlined;
      default: return Icons.help_outline;
    }
  }

  String _formatStatus(String status) {
    return status.split('_').map((str) =>
    "${str[0]}${str.substring(1).toLowerCase()}"
    ).join(' ');
  }
}