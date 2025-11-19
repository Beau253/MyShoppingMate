// ignore_for_file: prefer_const_constructors

import 'package:my_shopping_mate/data/models/product_model.dart';
import 'package:my_shopping_mate/data/services/api_service.dart';

class ProductRepository {
  final ApiService _apiService;

  ProductRepository({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  /// Fetches search results from the backend API.
  Future<List<Product>> searchProducts(String query) async {
    if (query.isEmpty) {
      return [];
    }

    try {
      // The backend endpoint is /products/search?q=query
      final response = await _apiService.get('/products/search?q=$query');
      
      if (response is List) {
        return response.map((json) => Product.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      // In a real app, we should log this error or rethrow it.
      // For now, we return an empty list to avoid crashing the UI.
      print('Error searching products: $e');
      return [];
    }
  }
}