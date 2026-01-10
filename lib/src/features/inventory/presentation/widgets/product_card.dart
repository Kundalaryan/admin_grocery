import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/product_model.dart';

class ProductCard extends StatelessWidget {
  final ProductItem product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    // Determine Status using .stock
    String statusText = "In Stock";
    Color statusColor = Colors.green;
    Color statusBg = Colors.green.withOpacity(0.1);

    if (product.stock == 0) {
      statusText = "Out of Stock";
      statusColor = Colors.grey;
      statusBg = Colors.grey.withOpacity(0.2);
    } else if (product.stock < 20) {
      statusText = "Low Stock";
      statusColor = Colors.red;
      statusBg = Colors.red.withOpacity(0.1);
    }

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(12.w),
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
          // 1. Image
          Container(
            height: 60.w,
            width: 60.w,
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FB),
              borderRadius: BorderRadius.circular(12.r),
              image: DecorationImage(
                image: NetworkImage(product.imageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),

          SizedBox(width: 12.w),

          // 2. Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700,
                    fontSize: 14.sp,
                    color: const Color(0xFF1A2B47),
                  ),
                ),
                Text(
                  "${product.category} • \$${product.price} / ${product.unit}",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.sp,
                    color: const Color(0xFFA0AEC0),
                  ),
                ),
                SizedBox(height: 4.h),
                // FIX: Display .stock here
                Text(
                  "Qty: ${product.stock}",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A2B47),
                  ),
                ),
              ],
            ),
          ),

          // 3. Status Badge
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: statusBg,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              statusText,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10.sp,
                fontWeight: FontWeight.w700,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}