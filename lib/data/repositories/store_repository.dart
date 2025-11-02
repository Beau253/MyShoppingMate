import 'package:my_shopping_mate/data/models/store_model.dart';

/// The abstract interface for the store repository.
abstract class StoreRepository {
  Future<List<Store>> getMyStores();
  Future<void> removeStore(String storeId);
  Future<void> reorderStores(List<Store> stores);
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