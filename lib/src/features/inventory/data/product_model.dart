class ProductItem {
  final int id;
  final String name;
  final String category;
  final String imageUrl;
  final double price;
  final int stock; // Changed from 'quantity' to 'stock'
  final String unit; // Added based on your API

  ProductItem({
    required this.id,
    required this.name,
    required this.category,
    required this.imageUrl,
    required this.price,
    required this.stock,
    required this.unit,
  });

  factory ProductItem.fromJson(Map<String, dynamic> json) {
    return ProductItem(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unknown',
      category: json['category'] ?? 'General',
      unit: json['unit'] ?? '',
      // Map 'stock' from API to our variable
      stock: json['stock'] ?? 0,
      price: (json['price'] ?? 0).toDouble(),
      imageUrl: json['imageUrl'] ?? 'https://via.placeholder.com/150',
    );
  }
}

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