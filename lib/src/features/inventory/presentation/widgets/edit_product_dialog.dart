import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/product_model.dart';
import '../logic/inventory_controller.dart';

class EditProductDialog extends ConsumerStatefulWidget {
  final ProductItem product;

  const EditProductDialog({super.key, required this.product});

  @override
  ConsumerState<EditProductDialog> createState() => _EditProductDialogState();
}

class _EditProductDialogState extends ConsumerState<EditProductDialog> {
  late TextEditingController _priceController;
  late TextEditingController _stockController;
  late String _selectedCategory;

  // NEW STATE VARIABLE
  late bool _isActive;

  final List<String> _categories = ["Fruit", "Vegetable", "Dairy", "Bakery", "Beverages"];
  File? _newImageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _priceController = TextEditingController(text: widget.product.price.toString());
    _stockController = TextEditingController(text: widget.product.stock.toString());
    _selectedCategory = _categories.contains(widget.product.category) ? widget.product.category : _categories.first;

    // Initialize Toggle State
    _isActive = widget.product.active;
  }

  // ... (Keep _pickImage and _showImageSourceModal as they were) ...
  Future<void> _pickImage(ImageSource source) async {
    try {
      print("📸 Attempting to pick image from $source...");

      final XFile? photo = await _picker.pickImage(
        source: source,
        maxWidth: 800, // Optimization: Resize image to save bandwidth
        maxHeight: 800,
        imageQuality: 85,
      );

      if (photo != null) {
        print("✅ Image selected: ${photo.path}");
        setState(() {
          _newImageFile = File(photo.path);
        });
      } else {
        print("⚠️ User cancelled selection");
      }
    } catch (e) {
      print("❌ ERROR picking image: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error opening camera/gallery: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }
  void _showImageSourceModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20.r))),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Update Photo", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 16.sp)),
              SizedBox(height: 20.h),

              // Option 1: Camera
              ListTile(
                leading: Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(color: const Color(0xFFE3F2FD), borderRadius: BorderRadius.circular(8.r)),
                  child: const Icon(Icons.camera_alt, color: Color(0xFF1986E6)),
                ),
                title: Text("Take Photo", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
                onTap: () {
                  Navigator.pop(ctx); // Close sheet
                  _pickImage(ImageSource.camera); // Open Camera
                },
              ),
              SizedBox(height: 8.h),

              // Option 2: Gallery
              ListTile(
                leading: Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(color: const Color(0xFFE3F2FD), borderRadius: BorderRadius.circular(8.r)),
                  child: const Icon(Icons.photo_library, color: Color(0xFF1986E6)),
                ),
                title: Text("Choose from Gallery", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
                onTap: () {
                  Navigator.pop(ctx); // Close sheet
                  _pickImage(ImageSource.gallery); // Open Gallery
                },
              ),
            ],
          ),
        );
      },
    );
  }


  // --- UPDATED SAVE LOGIC ---
  Future<void> _updateItem() async {
    final controller = ref.read(inventoryProvider.notifier);

    bool imageSuccess = true;
    bool detailsSuccess = true;
    bool statusSuccess = true; // Track status API result

    // 1. Image
    if (_newImageFile != null) {
      imageSuccess = await controller.updateProductImage(widget.product.id, _newImageFile!);
    }

    // 2. Status (Check if changed)
    if (_isActive != widget.product.active) {
      statusSuccess = await controller.toggleProductStatus(widget.product.id, _isActive);
    }

    // 3. Details (Check diffs)
    Map<String, dynamic> changes = {};
    double newPrice = double.tryParse(_priceController.text) ?? 0;
    if (newPrice != widget.product.price) changes['price'] = newPrice;

    int newStock = int.tryParse(_stockController.text) ?? 0;
    if (newStock != widget.product.stock) changes['stock'] = newStock;

    if (_selectedCategory != widget.product.category) changes['category'] = _selectedCategory;

    if (changes.isNotEmpty) {
      detailsSuccess = await controller.updateProductDetails(widget.product.id, changes);
    } else if (statusSuccess) {
      // If we only changed status but not text, we still need to refresh the list
      // We can manually trigger a fetch here since updateProductDetails won't be called
      await controller.fetchProducts();
    }

    if (mounted) {
      if (imageSuccess && detailsSuccess && statusSuccess) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Updated successfully"), backgroundColor: Colors.green));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Update failed"), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(inventoryProvider).isLoading;
    final isUploading = ref.watch(inventoryProvider).isUploading;
    final isBusy = isLoading || isUploading;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
      backgroundColor: Colors.white,
      insetPadding: EdgeInsets.all(20.w),
      child: SingleChildScrollView( // Add scroll for smaller screens
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Edit Item", style: GoogleFonts.plusJakartaSans(fontSize: 20.sp, fontWeight: FontWeight.w800, color: const Color(0xFF1A2B47))),
              SizedBox(height: 8.h),
              Text("Update details for ${widget.product.name}", textAlign: TextAlign.center, style: GoogleFonts.plusJakartaSans(fontSize: 12.sp, color: Colors.grey)),
              SizedBox(height: 24.h),

              // Image
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    height: 100.w, width: 100.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade200, width: 2),
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: _newImageFile != null ? FileImage(_newImageFile!) as ImageProvider : NetworkImage(widget.product.imageUrl),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: isBusy ? null : () => _showImageSourceModal(context), // Use your existing modal function
                    child: CircleAvatar(radius: 18.r, backgroundColor: const Color(0xFF1986E6), child: Icon(Icons.camera_alt, color: Colors.white, size: 16.sp)),
                  ),
                ],
              ),
              SizedBox(height: 24.h),

              // Inputs
              Row(
                children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("PRICE", style: _labelStyle), SizedBox(height: 8.h), _buildInput(_priceController, prefix: "\$ ")])),
                  SizedBox(width: 16.w),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("STOCK", style: _labelStyle), SizedBox(height: 8.h), _buildInput(_stockController)])),
                ],
              ),
              SizedBox(height: 16.h),

              // Category
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("CATEGORY", style: _labelStyle),
                  SizedBox(height: 8.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12.r)),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedCategory, isExpanded: true,
                        items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                        onChanged: (val) => setState(() => _selectedCategory = val!),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 16.h),

              // --- NEW: PRODUCT STATUS TOGGLE ---
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 1. WRAP LEFT TEXT IN EXPANDED (Fixes Overflow)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Product Status",
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 14.sp, fontWeight: FontWeight.w700, color: const Color(0xFF1A2B47)
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            "Toggle to enable or disable item",
                            maxLines: 2, // Allow wrapping if needed
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 11.sp, color: Colors.grey, height: 1.2
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(width: 8.w), // Gap between text and switch

                    // 2. RIGHT SIDE (Switch)
                    Row(
                      mainAxisSize: MainAxisSize.min, // Keep it compact
                      children: [
                        Text(
                          _isActive ? "Enabled" : "Disabled",
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: _isActive ? const Color(0xFF1986E6) : Colors.grey,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        // Wrap switch in SizedBox to control width if needed
                        SizedBox(
                          height: 30.h,
                          child: Switch.adaptive(
                            value: _isActive,
                            activeColor: const Color(0xFF1986E6),
                            onChanged: (val) {
                              setState(() {
                                _isActive = val;
                              });
                            },
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              // ----------------------------------

              SizedBox(height: 32.h),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: isBusy ? null : () => Navigator.pop(context),
                      style: TextButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 14.h), backgroundColor: const Color(0xFFF1F5F9), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r))),
                      child: Text("Cancel", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: const Color(0xFF1A2B47))),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isBusy ? null : _updateItem,
                      style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 14.h), backgroundColor: const Color(0xFF1986E6), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r))),
                      child: isBusy
                          ? SizedBox(height: 20.h, width: 20.h, child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Text("Update Item", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: Colors.white)),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  TextStyle get _labelStyle => GoogleFonts.plusJakartaSans(fontSize: 10.sp, fontWeight: FontWeight.w700, color: Colors.grey, letterSpacing: 0.5);

  Widget _buildInput(TextEditingController controller, {String prefix = ""}) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 16.sp),
      decoration: InputDecoration(
        prefixText: prefix,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: const BorderSide(color: Color(0xFF1986E6))),
      ),
    );
  }
}