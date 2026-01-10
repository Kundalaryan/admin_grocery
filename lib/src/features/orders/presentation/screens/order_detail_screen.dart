import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../logic/order_detail_controller.dart';
import '../widgets/order_timeline.dart';

class OrderDetailScreen extends ConsumerStatefulWidget {
  final int orderId; // We need the ID to load data

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  ConsumerState<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends ConsumerState<OrderDetailScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        ref.read(orderDetailProvider.notifier).fetchOrderDetails(widget.orderId)
    );
  }

  // --- 1. NEW HELPER FUNCTION FOR BOTTOM SHEET ---
  void _showStatusUpdateSheet(BuildContext context, int orderId, String currentStatus) {
    Map<String, String> options = {};

    // Logic for next steps
    if (currentStatus == 'ORDER_PLACED') {
      options = {'PACKED': 'Mark as Packed', 'CANCELLED': 'Cancel Order'};
    } else if (currentStatus == 'PACKED') {
      options = {'OUT_FOR_DELIVERY': 'Mark Out for Delivery', 'CANCELLED': 'Cancel Order'};
    } else if (currentStatus == 'OUT_FOR_DELIVERY') {
      options = {'DELIVERED': 'Mark Delivered', 'CANCELLED': 'Cancel Order'};
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Order cannot be updated further")),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (ctx) {
        return Container(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Update Order Status",
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700
                ),
              ),
              SizedBox(height: 20.h),

              ...options.entries.map((entry) {
                final isCancel = entry.key == 'CANCELLED';

                return Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50.h,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isCancel ? Colors.red.shade50 : const Color(0xFF1986E6),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      ),
                      onPressed: () async {
                        Navigator.pop(ctx); // Close sheet

                        bool success = false;
                        final notifier = ref.read(orderDetailProvider.notifier);

                        // --- NEW LOGIC: CHOOSE THE RIGHT API ---
                        if (isCancel) {
                          // Call the Specific Cancel API
                          success = await notifier.cancelOrder(orderId);
                        } else {
                          // Call the General Status Update API
                          success = await notifier.updateOrderStatus(orderId, entry.key);
                        }
                        // ----------------------------------------

                        if (success && mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(isCancel ? "Order Cancelled" : "Status updated to ${entry.value}"),
                              backgroundColor: isCancel ? Colors.red : Colors.green,
                            ),
                          );
                        } else if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Action failed"),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      child: Text(
                        entry.value,
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w600,
                          color: isCancel ? Colors.red : Colors.white,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(orderDetailProvider);
    final currency = NumberFormat.simpleCurrency();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          "Order #ORD-${widget.orderId}",
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18.sp,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1A2B47),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {},
          )
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.errorMessage != null
          ? Center(child: Text("Error: ${state.errorMessage}"))
          : state.order == null
          ? const Center(child: Text("No Data"))
          : SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          children: [
            // --- 1. Customer & Address Card ---
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: const Color(0xFFF1F5F9),
                        child: Icon(Icons.person, color: Colors.grey, size: 20.sp),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Customer", style: GoogleFonts.plusJakartaSans(fontSize: 14.sp, fontWeight: FontWeight.w700)),
                            Text(state.order!.customerPhone, style: GoogleFonts.plusJakartaSans(fontSize: 12.sp, color: Colors.grey)),
                          ],
                        ),
                      ),
                      CircleAvatar(
                        backgroundColor: Colors.green.withOpacity(0.1),
                        child: IconButton(
                          icon: Icon(Icons.phone, color: Colors.green, size: 18.sp),
                          onPressed: () {}, // Call action
                        ),
                      )
                    ],
                  ),
                  const Divider(height: 30),
                  Text("DELIVERY ADDRESS", style: GoogleFonts.plusJakartaSans(fontSize: 11.sp, fontWeight: FontWeight.w600, color: Colors.grey, letterSpacing: 1.0)),
                  SizedBox(height: 8.h),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.location_on, color: Colors.grey, size: 18.sp),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          state.order!.address,
                          style: GoogleFonts.plusJakartaSans(fontSize: 13.sp, color: const Color(0xFF1A2B47), height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 20.h),

            // --- 2. Timeline Status ---
            OrderTimeline(currentStatus: state.order!.status),

            SizedBox(height: 20.h),

            // --- 3. Action Buttons ---
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                    ),
                    child: Text("Invoice", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, color: Colors.black)),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ElevatedButton(
                    // --- 2. CONNECTED THE BUTTON HERE ---
                    onPressed: () => _showStatusUpdateSheet(
                        context,
                        widget.orderId,
                        state.order!.status
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1986E6),
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                    ),
                    child: Text("Update Status", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, color: Colors.white)),
                  ),
                ),
              ],
            ),

            SizedBox(height: 20.h),

            // --- 4. Product List ---
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Column(
                children: [
                  // List Items
                  ...state.order!.items.map((item) => Padding(
                    padding: EdgeInsets.only(bottom: 16.h),
                    child: Row(
                      children: [
                        // Image Placeholder
                        Container(
                          height: 50.w,
                          width: 50.w,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Icon(Icons.shopping_bag_outlined, color: Colors.grey.shade400),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.productName, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13.sp)),
                              Text("Qty: ${item.quantity}", style: GoogleFonts.plusJakartaSans(color: const Color(0xFF1986E6), fontWeight: FontWeight.w600, fontSize: 12.sp)),
                            ],
                          ),
                        ),
                        Text(
                            currency.format(item.total),
                            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13.sp)
                        ),
                      ],
                    ),
                  )),

                  const Divider(height: 30),

                  // Totals
                  _SummaryRow("Subtotal", currency.format(state.order!.totalAmount)),
                  _SummaryRow("Delivery Fee", currency.format(0.00)),
                  _SummaryRow("Tax", currency.format(0.00)),
                  SizedBox(height: 10.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Total Amount", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 16.sp)),
                      Text(currency.format(state.order!.totalAmount), style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 16.sp, color: const Color(0xFF1986E6))),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }
}

// Helper for summary rows
class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  const _SummaryRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.plusJakartaSans(color: Colors.grey, fontSize: 13.sp)),
          Text(value, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 13.sp)),
        ],
      ),
    );
  }
}