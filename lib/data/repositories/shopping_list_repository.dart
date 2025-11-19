// ignore_for_file: prefer_final_fields

import 'package:my_shopping_mate/data/models/list_item_model.dart';
import 'package:my_shopping_mate/data/models/shopping_list_model.dart';
import 'package:my_shopping_mate/data/services/api_service.dart';

/// The abstract interface for the shopping list repository.
abstract class ShoppingListRepository {
  Future<List<ShoppingList>> getShoppingLists();
  Future<ShoppingList> createShoppingList(String name);
  Future<List<ListItem>> getListItems(String listId);
  Future<ListItem> updateListItem(String listId, ListItem item);
  
  Future<ListItem> addListItem({
    required String listId,
    required String productName,
    required int quantity,
    required double price,
  });
}

class ApiShoppingListRepository implements ShoppingListRepository {
  final ApiService _apiService;

  ApiShoppingListRepository({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  @override
  Future<List<ShoppingList>> getShoppingLists() async {
    try {
      final response = await _apiService.get('/lists');
      if (response is List) {
        return response.map((json) => ShoppingList.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching lists: $e');
      return [];
    }
  }

  @override
  Future<ShoppingList> createShoppingList(String name) async {
    try {
      final response = await _apiService.post('/lists', body: {'name': name});
      return ShoppingList.fromJson(response);
    } catch (e) {
      print('Error creating list: $e');
      rethrow;
    }
  }
  
  @override
  Future<List<ListItem>> getListItems(String listId) async {
    // TODO: Implement backend endpoint for items if separate
    // For now assuming lists endpoint might return items or we need a new endpoint
    // Based on typical REST, it might be /lists/:id/items
    // But let's check the backend routes again if needed.
    // For now, returning empty to compile, will fix in next step after checking backend.
    return []; 
  }

  @override
  Future<ListItem> updateListItem(String listId, ListItem item) async {
    // TODO: Implement backend
    return item;
  }

  @override
  Future<ListItem> addListItem({
    required String listId,
    required String productName,
    required int quantity,
    required double price,
  }) async {
    // TODO: Implement backend
    return ListItem(id: 'temp', productName: productName, quantity: quantity, price: price, isChecked: false);
  }
}