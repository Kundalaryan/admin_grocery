import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../logic/delivery_controller.dart';
import '../widgets/selectable_order_card.dart';
import '../../../../core/utils/snackbar_utils.dart';

class DeliveryScreen extends ConsumerStatefulWidget {
  const DeliveryScreen({super.key});

  @override
  ConsumerState<DeliveryScreen> createState() => _DeliveryScreenState();
}

class _DeliveryScreenState extends ConsumerState<DeliveryScreen> {
  final _phoneController = TextEditingController();
  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(deliveryProvider);
    final controller = ref.read(deliveryProvider.notifier);
    final selectedCount = state.selectedIds.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false, // 1. Removes Default Back Button
        titleSpacing: 20.w,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Delivery Assignment",
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1A2B47),
              ),
            ),
            Text(
              "Select orders to assign driver",
              style: TextStyle(fontSize: 12.sp, color: Colors.grey),
            ),
          ],
        ),
        // 2. Removed 'actions' (Filter button) completely
      ),
      body: Column(
        children: [
          // --- 1. PHONE INPUT SECTION ---
          Container(
            padding: EdgeInsets.all(20.w),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Delivery Person's Phone Number",
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A2B47),
                  ),
                ),
                SizedBox(height: 10.h),
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: "9876543210",
                    prefixIcon: const Icon(
                      Icons.phone_android,
                      color: Colors.grey,
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF8F9FB),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 14.h,
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  "ASSIGNING TO VERIFIED COURIER",
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF7CA0BA),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),

          // --- 2. HEADER: PACKED ORDERS + SELECT ALL ---
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 20.w, 20.w, 10.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "PACKED ORDERS (${state.packedOrders.length})",
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1A2B47),
                    letterSpacing: 0.5,
                  ),
                ),
                TextButton(
                  onPressed: controller.toggleSelectAll,
                  child: Text(
                    state.isAllSelected ? "Deselect All" : "Select All",
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1986E6),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // --- 3. LIST OF ORDERS ---
          // ... inside build method ...

          // --- 3. LIST OF ORDERS ---
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.packedOrders.isEmpty
                ? Center(
                    child: Text(
                      "No packed orders",
                      style: TextStyle(),
                    ),
                  )
                // ADD REFRESH INDICATOR HERE
                : RefreshIndicator(
                    onRefresh: () async => controller.fetchPackedOrders(),
                    child: ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      itemCount: state.packedOrders.length,
                      itemBuilder: (context, index) {
                        final order = state.packedOrders[index];
                        final isSelected = state.selectedIds.contains(order.id);

                        return SelectableOrderCard(
                          order: order,
                          isSelected: isSelected,
                          onToggle: () => controller.toggleId(order.id),
                        );
                      },
                    ),
                  ),
          ),

          // --- 4. STICKY BOTTOM BUTTON ---
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, -5),
                ),
              ],
            ),
            child: SizedBox(
              height: 54.h,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (state.isAssigning || selectedCount == 0)
                    ? null
                    : () async {
                        if (_phoneController.text.length < 10) {
                          SnackbarUtils.showError(
                            context,
                            "Please enter valid phone",
                          );
                          return;
                        }

                        final success = await controller.assignDriver(
                          _phoneController.text,
                        );

                        if (success && mounted) {
                          SnackbarUtils.showSuccess(
                            context,
                            "Orders assigned successfully!",
                          );
                          _phoneController.clear();
                        } else if (mounted) {
                          SnackbarUtils.showError(
                            context,
                            state.errorMessage ?? "Assignment Failed",
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1986E6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  elevation: 0,
                ),
                child: state.isAssigning
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.assignment_ind,
                            color: Colors.white,
                            size: 20.sp,
                          ),
                          SizedBox(width: 8.w),
                          // 3. FIXED OVERFLOW: Wrapped in Flexible and shortened text
                          Flexible(
                            child: Text(
                              "Assign Driver ($selectedCount)",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
