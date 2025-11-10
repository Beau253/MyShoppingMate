import 'package:my_shopping_mate/data/models/list_item_model.dart';
import 'package:my_shopping_mate/data/models/trip_plan_model.dart';

abstract class TripPlanRepository {
  Future<TripPlan> getTripPlan(String listId);
}

class FakeTripPlanRepository implements TripPlanRepository {
  @override
  Future<TripPlan> getTripPlan(String listId) async {
    // Simulate a complex backend process that fetches prices and optimizes the trip.
    await Future.delayed(const Duration(seconds: 2));

    // --- FAKE DATA representing the optimized plan for listId '1' ---
    const walmartItems = [
      TripItem(
        item: ListItem(id: '101', productName: 'Organic Whole Milk', quantity: 1, price: 3.99, isChecked: false),
        currentStoreId: '1',
        alternativeStoreId: '2',
        alternativePrice: 4.19,
      ),
      TripItem(
        item: ListItem(id: '102', productName: 'Free-Range Eggs', quantity: 2, price: 4.50, isChecked: false),
        currentStoreId: '1',
        alternativeStoreId: '2',
        alternativePrice: 4.50,
      ),
      TripItem(
        item: ListItem(id: '103', productName: 'Sourdough Bread', quantity: 1, price: 5.25, isChecked: true),
        currentStoreId: '1',
        alternativeStoreId: '2',
        alternativePrice: 5.49,
      ),
    ];

    const targetItems = [
      TripItem(
        item: ListItem(id: '105', productName: 'Ground Coffee Beans', quantity: 1, price: 12.99, isChecked: false),
        currentStoreId: '2',
        alternativeStoreId: '1',
        alternativePrice: 13.15,
      ),
      TripItem(
        item: ListItem(id: '104', productName: 'Avocados', quantity: 4, price: 1.70, isChecked: false),
        currentStoreId: '2',
        alternativeStoreId: '1',
        alternativePrice: 1.75,
      ),
    ];

    return const TripPlan(stores: [
      TripStore(storeId: '1', storeName: 'Walmart', items: walmartItems),
      TripStore(storeId: '2', storeName: 'Target', items: targetItems),
    ]);
  }
}