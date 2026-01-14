import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../logic/orders_controller.dart';
import '../widgets/order_card.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(ordersProvider);
    final controller = ref.read(ordersProvider.notifier);

    String dateLabel = "Filter Date";
    Color dateColor = Colors.grey;
    if (state.dateRange != null) {
      final start = DateFormat('MMM d').format(state.dateRange!.start);
      final end = DateFormat('MMM d').format(state.dateRange!.end);
      dateLabel = "$start - $end";
      dateColor = const Color(0xFF1986E6);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "Orders",
          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w800, color: const Color(0xFF1A2B47)),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded, color: Colors.black),
            onPressed: () {},
          )
        ],
      ),
      body: Column(
        children: [
          // 1. SEARCH
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
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide.none),
                contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 16.w),
              ),
            ),
          ),

          // 2. FILTERS
          SizedBox(
            height: 40.h,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              children: [
                Container(
                  margin: EdgeInsets.only(right: 10.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24.r),
                    border: Border.all(color: dateColor.withOpacity(0.5)),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          borderRadius: BorderRadius.only(topLeft: Radius.circular(24.r), bottomLeft: Radius.circular(24.r), topRight: state.dateRange == null ? Radius.circular(24.r) : Radius.zero, bottomRight: state.dateRange == null ? Radius.circular(24.r) : Radius.zero),
                          onTap: () async {
                            final picked = await showDateRangePicker(
                              context: context,
                              firstDate: DateTime(2024),
                              lastDate: DateTime(2030),
                              builder: (context, child) {
                                return Theme(data: Theme.of(context).copyWith(colorScheme: const ColorScheme.light(primary: Color(0xFF1986E6), onPrimary: Colors.white)), child: child!);
                              },
                            );
                            if (picked != null) controller.setDateRange(picked);
                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                            child: Row(children: [Icon(Icons.calendar_today, size: 14.sp, color: dateColor), SizedBox(width: 6.w), Text(dateLabel, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: dateColor))]),
                          ),
                        ),
                        if (state.dateRange != null)
                          InkWell(
                            borderRadius: BorderRadius.only(topRight: Radius.circular(24.r), bottomRight: Radius.circular(24.r)),
                            onTap: () => controller.setDateRange(null),
                            child: Padding(padding: EdgeInsets.fromLTRB(4.w, 8.h, 12.w, 8.h), child: Icon(Icons.close, size: 16.sp, color: Colors.grey)),
                          )
                      ],
                    ),
                  ),
                ),
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

          // --- 3. INFINITE SCROLL LIST ---
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.orders.isEmpty
                ? Center(child: Text("No orders found", style: TextStyle()))
                : NotificationListener<ScrollNotification>(
              // A. DETECT SCROLL TO BOTTOM
              onNotification: (ScrollNotification scrollInfo) {
                if (scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 200 && // Load when 200px from bottom
                    !state.isLoadingMore && // Don't trigger if already loading
                    state.hasMore) { // Check if API has more data
                  controller.loadNextPage();
                }
                return true;
              },
              child: RefreshIndicator(
                onRefresh: () async => controller.fetchOrders(),
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  // Add +1 item for the bottom spinner
                  itemCount: state.orders.length + (state.isLoadingMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    // B. SHOW SPINNER AT BOTTOM
                    if (index == state.orders.length) {
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 20.h),
                        child: const Center(child: CircularProgressIndicator()),
                      );
                    }
                    // C. SHOW ORDER CARD
                    return OrderCard(order: state.orders[index]);
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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
        decoration: BoxDecoration(color: isSelected ? const Color(0xFF1A2B47) : Colors.white, borderRadius: BorderRadius.circular(24.r), border: isSelected ? null : Border.all(color: Colors.grey.shade300)),
        child: Center(child: Text(label, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: isSelected ? Colors.white : const Color(0xFF64748B)))),
      ),
    );
  }
}