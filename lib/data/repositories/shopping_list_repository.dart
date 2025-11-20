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
    try {
      final response = await _apiService.get('/lists/$listId/items');
      if (response is List) {
        return response.map((json) => ListItem.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching list items: $e');
      return [];
    }
  }

  @override
  Future<ListItem> updateListItem(String listId, ListItem item) async {
    try {
      final response = await _apiService.put(
        '/lists/$listId/items/${item.id}',
        body: {
          'isChecked': item.isChecked,
          'quantity': item.quantity,
          'price': item.price,
        },
      );
      return ListItem.fromJson(response);
    } catch (e) {
      print('Error updating list item: $e');
      rethrow;
    }
  }

  @override
  Future<ListItem> addListItem({
    required String listId,
    required String productName,
    required int quantity,
    required double price,
  }) async {
    try {
      final response = await _apiService.post(
        '/lists/$listId/items',
        body: {
          'productName': productName,
          'quantity': quantity,
          'price': price,
        },
      );
      return ListItem.fromJson(response);
    } catch (e) {
      print('Error adding list item: $e');
      rethrow;
    }
  }
}