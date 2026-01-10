// lib/src/features/inventory/data/product_model.dart

class ProductItem {
  final int id;
  final String name;
  final String category;
  final String imageUrl;
  final double price;
  final int stock;
  final String unit;
  final bool active; // Added active status

  ProductItem({
    required this.id,
    required this.name,
    required this.category,
    required this.imageUrl,
    required this.price,
    required this.stock,
    required this.unit,
    required this.active,
  });

  factory ProductItem.fromJson(Map<String, dynamic> json) {
    return ProductItem(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unknown',
      category: json['category'] ?? 'General',
      unit: json['unit'] ?? '',
      stock: json['stock'] ?? 0,
      price: (json['price'] ?? 0).toDouble(),
      imageUrl: json['imageUrl'] ?? 'https://via.placeholder.com/150',
      active: json['active'] ?? true,
    );
  }
}

// --- THIS WAS MISSING ---
class ProductListResponse {
  final bool success;
  final List<ProductItem> products;

  ProductListResponse({required this.success, required this.products});

  factory ProductListResponse.fromJson(Map<String, dynamic> json) {
    return ProductListResponse(
      success: json['success'] ?? false,
      products: (json['data'] as List? ?? [])
          .map((e) => ProductItem.fromJson(e))
          .toList(),
    );
  }
}