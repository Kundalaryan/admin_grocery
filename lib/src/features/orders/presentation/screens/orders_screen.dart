import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../logic/orders_controller.dart';
import '../widgets/order_card.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(ordersProvider);
    final controller = ref.read(ordersProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "Orders",
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1A2B47),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded, color: Colors.black),
            onPressed: () {}, // Open detailed filter drawer if needed
          )
        ],
      ),
      body: Column(
        children: [
          // --- 1. SEARCH BAR ---
          Padding(
            padding: EdgeInsets.all(20.w),
            child: TextField(
              onSubmitted: (value) => controller.fetchOrders(searchQuery: value),
              decoration: InputDecoration(
                hintText: "Search Order ID, Name...",
                hintStyle: TextStyle(fontSize: 14.sp, color: Colors.grey),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 16.w),
              ),
            ),
          ),

          // --- 2. FILTER TABS (Horizontal Scroll) ---
          SizedBox(
            height: 40.h,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              children: [
                _FilterChip("All", "All", state.selectedFilter, controller),
                SizedBox(width: 10.w),
                _FilterChip("Pending", "ORDER_PLACED", state.selectedFilter, controller),
                SizedBox(width: 10.w),
                _FilterChip("Packed", "PACKED", state.selectedFilter, controller),
                SizedBox(width: 10.w),
                _FilterChip("Delivery", "OUT_FOR_DELIVERY", state.selectedFilter, controller),
                SizedBox(width: 10.w),
                _FilterChip("Delivered", "DELIVERED", state.selectedFilter, controller),
                SizedBox(width: 10.w),
                _FilterChip("Cancelled", "CANCELLED", state.selectedFilter, controller),
              ],
            ),
          ),

          SizedBox(height: 20.h),

          // --- 3. ORDER LIST ---
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.orders.isEmpty
                ? Center(child: Text("No orders found", style: TextStyle()))
                : RefreshIndicator(
              onRefresh: () async => controller.fetchOrders(),
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                itemCount: state.orders.length,
                itemBuilder: (context, index) {
                  return OrderCard(order: state.orders[index]);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Helper Widget for the Tab Buttons
class _FilterChip extends StatelessWidget {
  final String label;
  final String apiValue;
  final String currentSelection;
  final OrdersController controller;

  const _FilterChip(this.label, this.apiValue, this.currentSelection, this.controller);

  @override
  Widget build(BuildContext context) {
    final bool isSelected = currentSelection == apiValue;
    return GestureDetector(
      onTap: () => controller.setFilter(apiValue),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1A2B47) : Colors.white,
          borderRadius: BorderRadius.circular(24.r),
          border: isSelected ? null : Border.all(color: Colors.grey.shade300),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : const Color(0xFF64748B),
            ),
          ),
        ),
      ),
    );
  }
}