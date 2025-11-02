import 'package:my_shopping_mate/data/models/list_item_model.dart';
import 'package:my_shopping_mate/data/models/shopping_list_model.dart';
import 'package:uuid/uuid.dart';

/// The abstract interface for the shopping list repository.
abstract class ShoppingListRepository {
  Future<List<ShoppingList>> getShoppingLists();
  Future<ShoppingList> createShoppingList(String name);
  Future<List<ListItem>> getListItems(String listId);
  Future<ListItem> updateListItem(String listId, ListItem item);
  
  // --- NEW METHOD ---
  Future<ListItem> addListItem({
    required String listId,
    required String productName,
    required int quantity,
    required double price,
  });
}

/// The placeholder implementation of the repository.
class FakeShoppingListRepository implements ShoppingListRepository {
  final _uuid = const Uuid();

  // --- FAKE DATABASE (remains the same) ---
  List<ShoppingList> _shoppingLists = [
    const ShoppingList(id: '1', name: 'Weekly Groceries', itemCount: 6, totalCost: 145.78),
    const ShoppingList(id: '2', name: 'Hardware Store Run', itemCount: 2, totalCost: 89.50),
    const ShoppingList(id: '3', name: 'Birthday Party Supplies', itemCount: 15, totalCost: 72.25),
    const ShoppingList(id: '4', name: 'Farmers Market', itemCount: 10, totalCost: 35.00),
  ];

  final Map<String, List<ListItem>> _listItems = {
    '1': [
      const ListItem(id: '101', productName: 'Organic Whole Milk', quantity: 1, price: 3.99, isChecked: false),
      const ListItem(id: '102', productName: 'Free-Range Eggs', quantity: 2, price: 4.50, isChecked: false),
      const ListItem(id: '103', productName: 'Sourdough Bread', quantity: 1, price: 5.25, isChecked: true),
      const ListItem(id: '104', productName: 'Avocados', quantity: 4, price: 1.75, isChecked: false),
      const ListItem(id: '105', productName: 'Ground Coffee Beans', quantity: 1, price: 12.99, isChecked: false),
      const ListItem(id: '106', productName: 'Chicken Breast (lb)', quantity: 3, price: 6.99, isChecked: false),
    ],
    '2': [
      const ListItem(id: '201', productName: 'Hammer', quantity: 1, price: 25.00, isChecked: false),
      const ListItem(id: '202', productName: 'Nails (box)', quantity: 2, price: 12.00, isChecked: false),
    ],
  };
  // --- END FAKE DATABASE ---

  @override
  Future<List<ShoppingList>> getShoppingLists() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return List.from(_shoppingLists);
  }

  @override
  Future<ShoppingList> createShoppingList(String name) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final newList = ShoppingList(
      id: _uuid.v4(),
      name: name,
      itemCount: 0,
      totalCost: 0.0,
    );
    _shoppingLists.insert(0, newList);
    _listItems[newList.id] = [];
    return newList;
  }
  
  @override
  Future<List<ListItem>> getListItems(String listId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _listItems[listId] ?? [];
  }

  @override
  Future<ListItem> updateListItem(String listId, ListItem item) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final list = _listItems[listId];
    if (list != null) {
      final index = list.indexWhere((i) => i.id == item.id);
      if (index != -1) {
        list[index] = item;
      }
    }
    return item;
  }

  // --- NEW METHOD IMPLEMENTATION ---
  @override
  Future<ListItem> addListItem({
    required String listId,
    required String productName,
    required int quantity,
    required double price,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final newItem = ListItem(
      id: _uuid.v4(),
      productName: productName,
      quantity: quantity,
      price: price,
      isChecked: false,
    );

    if (_listItems.containsKey(listId)) {
      _listItems[listId]!.add(newItem);
    } else {
      // This case should ideally not happen if the list exists
      _listItems[listId] = [newItem];
    }
    return newItem;
  }
}