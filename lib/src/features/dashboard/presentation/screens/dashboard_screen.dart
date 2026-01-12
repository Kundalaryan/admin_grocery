import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../logic/dashboard_controller.dart';
import '../widgets/stat_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dashboardProvider);
    final currencyFormat = NumberFormat.simpleCurrency(locale: 'en_IN');

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),

      // --- 1. Top Bar ---
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 20.w,
        title: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 20.r,
              backgroundImage: const NetworkImage("https://i.pravatar.cc/150?img=11"),
              backgroundColor: Colors.grey.shade200,
            ),
            SizedBox(width: 12.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Good Morning,",
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                ),
                Text(
                  "Store Manager",
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ],
            )
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none_rounded, color: Colors.black),
          ),
        ],
      ),

      // ---------------------------------------------------------
      // REMOVED: bottomNavigationBar
      // The MainWrapper now handles the navigation bar.
      // ---------------------------------------------------------

      // --- 3. Main Content ---
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.errorMessage != null
          ? Center(child: Text("Error: ${state.errorMessage}"))
          : RefreshIndicator(
        onRefresh: () async => ref.read(dashboardProvider.notifier).loadDashboard(),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.w),
          child: Column(
            children: [
              // A. Total Cash Hero Card
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(24.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(6.w),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                              child: Icon(Icons.attach_money, color: Colors.green, size: 18.sp),
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              "Total Cash Collected",
                              style: TextStyle(
                                color: const Color(0xFF64748B),
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12.h),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              currencyFormat.format(state.data!.totalCashCollected),
                              style: TextStyle(
                                fontSize: 28.sp,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                            SizedBox(width: 10.w),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                              child: Text(
                                "↗ 15%",
                                style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12.sp
                                ),
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20.h),

              // B. The Grid of Stats
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16.w,
                mainAxisSpacing: 16.h,
                childAspectRatio: 0.85,
                children: [
                  StatCard(
                    title: "Total Orders",
                    value: "${state.data!.totalOrders}",
                    trend: "+5% vs yesterday",
                    icon: Icons.shopping_bag_outlined,
                    color: Colors.blue,
                  ),
                  StatCard(
                    title: "Packed",
                    value: "${state.data!.packedOrders}",
                    trend: "+12% vs yesterday",
                    icon: Icons.inventory_2_outlined,
                    color: Colors.orange,
                  ),
                  StatCard(
                    title: "Out for Delivery",
                    value: "${state.data!.outForDelivery}",
                    trend: "+3% vs yesterday",
                    icon: Icons.local_shipping_outlined,
                    color: const Color(0xFF1986E6),
                  ),
                  StatCard(
                    title: "Delivered",
                    value: "${state.data!.deliveredOrders}",
                    trend: "+8% vs yesterday",
                    icon: Icons.check_circle_outline,
                    color: Colors.teal,
                  ),
                ],
              ),

              SizedBox(height: 20.h),

              // C. Cancelled Orders
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(Icons.cancel_outlined, color: Colors.red, size: 24.sp),
                    ),
                    SizedBox(width: 16.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Cancelled Orders",
                          style: TextStyle(
                            color: const Color(0xFF64748B),
                            fontSize: 13.sp,
                          ),
                        ),
                        Text(
                          "${state.data!.cancelledOrders}",
                          style: TextStyle(
                            color: const Color(0xFF0F172A),
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "-2% vs",
                            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 11.sp),
                          ),
                          Text(
                            "yesterday",
                            style: TextStyle(color: Colors.red, fontSize: 11.sp),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),

              SizedBox(height: 30.h),
            ],
          ),
        ),
      ),
    );
  }
}