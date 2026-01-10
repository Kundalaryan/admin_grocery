import 'dart:io';
import 'dart:ui'; // This will work now
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../logic/inventory_controller.dart';
import '../widgets/product_card.dart';
import 'add_product_screen.dart';

class InventoryScreen extends ConsumerWidget {
  const InventoryScreen({super.key});

  // --- CSV PICKER FUNCTION ---
  Future<void> _pickAndUploadCsv(WidgetRef ref, BuildContext context) async {
    // Pick the file
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result != null && result.files.single.path != null) {
      File file = File(result.files.single.path!);

      // Call Controller
      final success = await ref
          .read(inventoryProvider.notifier)
          .uploadCsv(file);

      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("CSV Uploaded Successfully"),
            backgroundColor: Colors.green,
          ),
        );
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Upload Failed"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(inventoryProvider);
    final controller = ref.read(inventoryProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "Inventory Management",
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18.sp,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1A2B47),
          ),
        ),
        actions: [
          // Add Button
          Container(
            margin: EdgeInsets.only(right: 16.w),
            decoration: const BoxDecoration(
              color: Color(0xFF1986E6),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.add, color: Colors.white),
              onPressed: () {
                // Navigate to Add Product Screen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddProductScreen()),
                );
              },
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(height: 16.h),

          // --- 1. FILTER TABS ---
          SizedBox(
            height: 40.h,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              children: [
                _FilterTab("All Items", state.activeFilter, controller),
                SizedBox(width: 10.w),
                _FilterTab("Low Stock", state.activeFilter, controller),
                SizedBox(width: 10.w),
                _FilterTab("Out of Stock", state.activeFilter, controller),
              ],
            ),
          ),

          SizedBox(height: 16.h),

          // --- 2. PRODUCT LIST ---
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.filteredProducts.isEmpty
                ? Center(
                    child: Text(
                      "No items found",
                      style: GoogleFonts.plusJakartaSans(),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () async => controller.fetchProducts(),
                    child: ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      itemCount: state.filteredProducts.length,
                      itemBuilder: (context, index) {
                        return ProductCard(
                          product: state.filteredProducts[index],
                        );
                      },
                    ),
                  ),
          ),

          // --- 3. BULK UPDATE SECTION (Sticky Bottom) ---
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Bulk Update",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      "Download Template",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13.sp,
                        color: const Color(0xFF1986E6),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Text(
                  "Update stock instantly via CSV.",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.sp,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 20.h),

                // --- 4. THE FIX: USING DOTTED BORDER PACKAGE ---
                GestureDetector(
                  onTap: () => _pickAndUploadCsv(ref, context),
                  child: DashedRect(
                    color: Colors.grey.shade400,
                    strokeWidth: 1.5,
                    gap: 6.0,
                    child: Container(
                      height: 100.h,
                      width: double.infinity,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: state.isUploading
                          ? const CircularProgressIndicator()
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.cloud_upload_outlined,
                                  color: Colors.grey,
                                  size: 30.sp,
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  "Tap to upload or drag and drop",
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13.sp,
                                    color: const Color(0xFF1986E6),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  "CSV files only (Max 5MB)",
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11.sp,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),

                SizedBox(height: 20.h),

                SizedBox(
                  width: double.infinity,
                  height: 50.h,
                  child: ElevatedButton(
                    onPressed: () => _pickAndUploadCsv(ref, context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1986E6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      "Confirm Upload",
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- HELPER WIDGETS ---

class _FilterTab extends StatelessWidget {
  final String label;
  final String activeFilter;
  final InventoryController controller;

  const _FilterTab(this.label, this.activeFilter, this.controller);

  @override
  Widget build(BuildContext context) {
    final isSelected = label == activeFilter;
    return GestureDetector(
      onTap: () => controller.setFilter(label),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1986E6) : Colors.white,
          borderRadius: BorderRadius.circular(24.r),
          border: isSelected ? null : Border.all(color: Colors.grey.shade300),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.plusJakartaSans(
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

class DashedRect extends StatelessWidget {
  final Widget child;
  final Color color;
  final double strokeWidth;
  final double gap;

  const DashedRect({
    super.key,
    required this.child,
    this.color = Colors.grey,
    this.strokeWidth = 1.0,
    this.gap = 5.0,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedRectPainter(
        color: color,
        strokeWidth: strokeWidth,
        gap: gap,
      ),
      child: child,
    );
  }
}

class _DashedRectPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;

  _DashedRectPainter({
    required this.color,
    required this.strokeWidth,
    required this.gap,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final double dashWidth = gap;
    final double dashSpace = gap;

    // Create a rounded rectangle path
    final RRect rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(12), // Hardcoded radius to match design
    );

    final Path path = Path()..addRRect(rrect);

    // Logic to draw dashes along the path
    Path dashPath = Path();
    double distance = 0.0;

    for (PathMetric pathMetric in path.computeMetrics()) {
      while (distance < pathMetric.length) {
        dashPath.addPath(
          pathMetric.extractPath(distance, distance + dashWidth),
          Offset.zero,
        );
        distance += dashWidth + dashSpace;
      }
      distance = 0.0; // Reset for next contour (though RRect only has one)
    }

    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
