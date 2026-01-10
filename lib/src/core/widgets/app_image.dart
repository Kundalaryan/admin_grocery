import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppImage extends StatelessWidget {
  final String imageUrl;
  final double width;
  final double height;
  final double borderRadius;

  const AppImage({
    super.key,
    required this.imageUrl,
    required this.width,
    required this.height,
    this.borderRadius = 0,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius.r),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        width: width,
        height: height,
        fit: BoxFit.cover,
        // 1. Show a grey box while loading (Smooth)
        placeholder: (context, url) => Container(
          color: Colors.grey.shade100,
        ),
        // 2. Show an error icon if URL is broken (No crash)
        errorWidget: (context, url, error) => Container(
          color: Colors.grey.shade100,
          child: Icon(Icons.broken_image, color: Colors.grey, size: 20.sp),
        ),
      ),
    );
  }
}