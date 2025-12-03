import 'package:flutter/foundation.dart';
import 'package:my_shopping_mate/data/models/store_model.dart';
import 'package:my_shopping_mate/data/services/api_service.dart';

/// The abstract interface for the store repository.
abstract class StoreRepository {
  Future<List<Store>> getMyStores();
  Future<void> addStore(String name, String chain);
  Future<void> removeStore(String storeId);
  Future<void> reorderStores(List<Store> stores);
}

class ApiStoreRepository implements StoreRepository {
  final ApiService _apiService;

  ApiStoreRepository({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  @override
  Future<List<Store>> getMyStores() async {
    try {
      final response = await _apiService.get('/stores');
      if (response is List) {
        return response.map((json) => Store.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching stores: $e');
      throw Exception('Failed to fetch stores');
    }
  }

  @override
  Future<void> addStore(String name, String chain) async {
    try {
      await _apiService.post('/stores', body: {
        'name': name,
        'chain': chain,
      });
    } catch (e) {
      debugPrint('Error adding store: $e');
      throw Exception('Failed to add store');
    }
  }

  @override
  Future<void> removeStore(String storeId) async {
    // TODO: Implement remove store API
    // For now, we just simulate it locally or throw unimplemented
    // Since the backend doesn't have a DELETE endpoint yet, we'll skip this
    // or implement it in backend if needed.
    // But for "My Stores" which is a user preference, we might need a separate table
    // "user_stores". The current "stores" table is global.
    // The user request implies "My Stores" are the stores they shop at.
    // If "stores" table is global, then "My Stores" should be a user-specific list.
    // However, for now, I'll assume we are just listing all available stores or
    // adding to the global list.
    // Given the schema, `stores` is global.
    // So `getMyStores` is actually `getAllStores`.
    // And `addStore` adds a global store.
    // `removeStore` would delete a global store (admin only?).
    // I'll leave removeStore empty or throw for now.
  }

  @override
  Future<void> reorderStores(List<Store> stores) async {
    // Reordering is a local preference. We need to store this locally or in user prefs.
    // For now, do nothing.
  }
}

/// The placeholder implementation of the repository.
class FakeStoreRepository implements StoreRepository {
  List<Store> _myStores = [
    const Store(id: '1', name: 'Walmart', logoUrl: 'walmart_logo.png'),
    const Store(id: '2', name: 'Target', logoUrl: 'target_logo.png'),
    const Store(id: '3', name: 'Costco', logoUrl: 'costco_logo.png'),
  ];

  @override
  Future<List<Store>> getMyStores() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return List.from(_myStores); // Return a copy
  }

  @override
  Future<void> addStore(String name, String chain) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // For fake repository, we can just add a new store to the list
    _myStores.add(Store(
        id: (_myStores.length + 1).toString(),
        name: name,
        logoUrl: 'default_logo.png'));
  }

  @override
  Future<void> removeStore(String storeId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _myStores.removeWhere((store) => store.id == storeId);
  }

  @override
  Future<void> reorderStores(List<Store> stores) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _myStores = stores;
  }
}
