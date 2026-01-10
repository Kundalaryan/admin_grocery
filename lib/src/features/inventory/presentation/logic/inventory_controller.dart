import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/product_model.dart';

class InventoryState {
  final bool isLoading;
  final bool isUploading; // Specific loading state for CSV
  final List<ProductItem> allProducts; // Keeps the master list
  final List<ProductItem> filteredProducts; // The list we show
  final String activeFilter; // "All", "Low Stock", "Out of Stock"
  final String? errorMessage;

  InventoryState({
    this.isLoading = false,
    this.isUploading = false,
    this.allProducts = const [],
    this.filteredProducts = const [],
    this.activeFilter = "All",
    this.errorMessage,
  });

  InventoryState copyWith({
    bool? isLoading,
    bool? isUploading,
    List<ProductItem>? allProducts,
    List<ProductItem>? filteredProducts,
    String? activeFilter,
    String? errorMessage,
  }) {
    return InventoryState(
      isLoading: isLoading ?? this.isLoading,
      isUploading: isUploading ?? this.isUploading,
      allProducts: allProducts ?? this.allProducts,
      filteredProducts: filteredProducts ?? this.filteredProducts,
      activeFilter: activeFilter ?? this.activeFilter,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class InventoryController extends StateNotifier<InventoryState> {
  final Dio _dio = DioClient().dio;

  InventoryController() : super(InventoryState(isLoading: true)) {
    fetchProducts();
  }

  // 1. Fetch Products
  Future<void> fetchProducts() async {
    try {
      state = state.copyWith(isLoading: true);
      final response = await _dio.get('/admin/products');
      final result = ProductListResponse.fromJson(response.data);

      if (result.success) {
        state = state.copyWith(
          isLoading: false,
          allProducts: result.products,
          filteredProducts: result.products, // Show all by default
          activeFilter: "All",
        );
      } else {
        state = state.copyWith(isLoading: false, errorMessage: "Failed to load");
      }
    } on DioException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: "Connection Error");
    }
  }

  // 2. Filter Logic
  void setFilter(String filter) {
    List<ProductItem> temp = [];

    if (filter == "All Items") {
      temp = state.allProducts;
    } else if (filter == "Low Stock") {
      // FIX: Use .stock
      temp = state.allProducts.where((p) => p.stock < 20 && p.stock > 0).toList();
    } else if (filter == "Out of Stock") {
      // FIX: Use .stock
      temp = state.allProducts.where((p) => p.stock == 0).toList();
    }

    state = state.copyWith(activeFilter: filter, filteredProducts: temp);
  }

  // 3. Upload CSV Logic
  Future<bool> uploadCsv(File file) async {
    try {
      state = state.copyWith(isUploading: true);

      String fileName = file.path.split('/').last;

      FormData formData = FormData.fromMap({
        // CRITICAL FIX: Changed "file" to "File" to match Spring Boot error
        "File": await MultipartFile.fromFile(
          file.path,
          filename: fileName,
        ),
      });

      final response = await _dio.post(
        '/admin/products/upload-csv',
        data: formData,
      );

      state = state.copyWith(isUploading: false);

      if (response.data['success'] == true) {
        fetchProducts();
        return true;
      }
      return false;
    } on DioException catch (e) {
      // Print error to see what happens in debug console
      print("CSV Upload Error: ${e.response?.data}");
      state = state.copyWith(isUploading: false);
      return false;
    }
  }  Future<bool> addProduct({
    required String name,
    required String category,
    required String unit,
    required double price,
    required int stock,
    required String description,
  }) async {
    try {
      state = state.copyWith(isLoading: true);

      // 1. Send JSON Data
      final response = await _dio.post(
        '/admin/products',
        data: {
          "name": name,
          "category": category,
          "unit": unit, // e.g. "kg", "pc"
          "price": price,
          "stock": stock,
          "description": description
        },
      );

      // 2. Refresh the list on success
      if (response.data['success'] == true) {
        await fetchProducts(); // <--- Reloads the Inventory Screen list
        return true;
      } else {
        state = state.copyWith(isLoading: false, errorMessage: "Failed to add product");
        return false;
      }
    } on DioException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: "Connection Error");
      return false;
    }
  }
  Future<bool> updateProductDetails(int id, Map<String, dynamic> changes) async {
    try {
      state = state.copyWith(isLoading: true);

      final response = await _dio.patch(
        '/admin/products/$id',
        data: changes, // <--- Send only the changed fields
      );

      if (response.data['success'] == true) {
        await fetchProducts(); // Refresh list to see changes
        return true;
      }
      state = state.copyWith(isLoading: false);
      return false;
    } on DioException {
      state = state.copyWith(isLoading: false);
      return false;
    }
  }

  // 2. UPDATE IMAGE
  Future<bool> updateProductImage(int id, File imageFile) async {
    try {
      state = state.copyWith(isUploading: true);

      String fileName = imageFile.path.split('/').last;

      FormData formData = FormData.fromMap({
        // Ensure this matches your backend logic (usually "image" or "file")
        // Based on your previous prompt you said request param "image"
        "image": await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
        ),
      });

      final response = await _dio.post(
        '/admin/products/$id/image',
        data: formData,
      );

      state = state.copyWith(isUploading: false);

      if (response.data['success'] == true) {
        return true;
      }
      return false;
    } on DioException catch (e) {
      print("Image Upload Error: ${e.response?.data}");
      state = state.copyWith(isUploading: false);
      return false;
    }
  }
  Future<bool> toggleProductStatus(int id, bool shouldEnable) async {
    try {
      // Choose endpoint based on boolean
      final String path = shouldEnable
          ? '/admin/products/$id/enable'
          : '/admin/products/$id/disable';

      final response = await _dio.patch(path); // Using PATCH as per your description

      if (response.data['success'] == true) {
        // We don't fetchProducts here because the main update function will do it
        return true;
      }
      return false;
    } on DioException {
      return false;
    }
  }
}

final inventoryProvider = StateNotifierProvider<InventoryController, InventoryState>((ref) {
  return InventoryController();
});