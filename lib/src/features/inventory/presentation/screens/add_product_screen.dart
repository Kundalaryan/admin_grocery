import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../logic/inventory_controller.dart';

class AddProductScreen extends ConsumerStatefulWidget {
  const AddProductScreen({super.key});

  @override
  ConsumerState<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends ConsumerState<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _descController = TextEditingController();
  final _unitValueController = TextEditingController(text: "1");

  // State variables
  String? _selectedCategory;
  String _selectedUnit = "pc";

  final List<String> _categories = ["Fruit", "Vegetable", "Dairy", "Bakery", "Beverages"];
  final List<String> _units = ["pc", "kg", "g", "ltr", "ml", "box", "pack"];

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(inventoryProvider).isLoading;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Add New Product",
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18.sp,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1A2B47),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _nameController.clear();
              _priceController.clear();
              _stockController.clear();
              _descController.clear();
              _unitValueController.text = "1";
              setState(() {
                _selectedCategory = null;
                _selectedUnit = "pc";
              });
            },
            child: Text(
              "Reset",
              style: GoogleFonts.plusJakartaSans(
                color: const Color(0xFF1986E6),
                fontWeight: FontWeight.w600,
              ),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- 1. PRODUCT NAME ---
              Text("Product Name", style: _labelStyle),
              SizedBox(height: 8.h),
              _buildTextField(
                controller: _nameController,
                hint: "e.g. Red Delicious Apple",
              ),

              SizedBox(height: 20.h),

              // --- 2. CATEGORY ---
              Text("Category", style: _labelStyle),
              SizedBox(height: 8.h),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: _inputDecoration("Select a category"),
                icon: const Icon(Icons.keyboard_arrow_down),
                items: _categories.map((cat) => DropdownMenuItem(
                  value: cat,
                  child: Text(cat, style: GoogleFonts.plusJakartaSans(fontSize: 14.sp)),
                )).toList(),
                onChanged: (val) => setState(() => _selectedCategory = val),
                validator: (val) => val == null ? "Required" : null,
              ),

              SizedBox(height: 20.h),

              // --- 3. UNIT (Number Field + Dropdown) ---
              Text("Unit", style: _labelStyle),
              SizedBox(height: 8.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // A. Unit Value (e.g. 500)
                  Expanded(
                    flex: 1,
                    child: _buildTextField(
                      controller: _unitValueController,
                      hint: "1",
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  SizedBox(width: 12.w),

                  // B. Unit Type (e.g. gm)
                  Expanded(
                    flex: 1,
                    child: DropdownButtonFormField<String>(
                      value: _selectedUnit,
                      decoration: _inputDecoration("Type"),
                      items: _units.map((u) => DropdownMenuItem(
                        value: u,
                        child: Text(u, style: GoogleFonts.plusJakartaSans(fontSize: 14.sp)),
                      )).toList(),
                      onChanged: (val) => setState(() => _selectedUnit = val!),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20.h),

              // --- 4. PRICE & STOCK ---
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Price (\$)", style: _labelStyle),
                        SizedBox(height: 8.h),
                        _buildTextField(
                          controller: _priceController,
                          hint: "0.00",
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Stock Quantity", style: _labelStyle),
                        SizedBox(height: 8.h),
                        _buildTextField(
                          controller: _stockController,
                          hint: "0",
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20.h),

              // --- 5. DESCRIPTION ---
              Text("Description", style: _labelStyle),
              SizedBox(height: 8.h),
              _buildTextField(
                controller: _descController,
                hint: "Brief details about the product...",
                maxLines: 4,
              ),

              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),

      // --- 6. SUBMIT BUTTON ---
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))],
        ),
        child: SizedBox(
          height: 50.h,
          child: ElevatedButton(
            onPressed: isLoading ? null : _submitForm,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1986E6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
            ),
            child: isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : Text("Add Product", style: GoogleFonts.plusJakartaSans(fontSize: 16.sp, fontWeight: FontWeight.w700, color: Colors.white)),
          ),
        ),
      ),
    );
  }

  // --- LOGIC ---
  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {

      // --- FIX: REMOVED SPACE (e.g. "500"+"g" = "500g") ---
      String finalUnit = "${_unitValueController.text.trim()}$_selectedUnit";

      final success = await ref.read(inventoryProvider.notifier).addProduct(
        name: _nameController.text,
        category: _selectedCategory!,
        unit: finalUnit, // Send string without space
        price: double.tryParse(_priceController.text) ?? 0,
        stock: int.tryParse(_stockController.text) ?? 0,
        description: _descController.text,
      );

      if (success && mounted) {
        Navigator.pop(context); // Go back to Inventory Screen
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Product Added Successfully"), backgroundColor: Colors.green),
        );
      }
    }
  }

  // --- STYLES ---
  TextStyle get _labelStyle => GoogleFonts.plusJakartaSans(
    fontSize: 14.sp, fontWeight: FontWeight.w700, color: const Color(0xFF1A2B47),
  );

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: (val) => val == null || val.isEmpty ? "Required" : null,
      decoration: _inputDecoration(hint),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.plusJakartaSans(color: Colors.grey.shade400, fontSize: 14.sp),
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: Color(0xFF1986E6)),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: Colors.red),
      ),
    );
  }
}