import 'package:equatable/equatable.dart';
import 'package:my_shopping_mate/data/models/list_item_model.dart';

class TripItem extends Equatable {
  final ListItem item;
  final String currentStoreId;
  final String alternativeStoreId;
  final double alternativePrice;

  const TripItem({
    required this.item,
    required this.currentStoreId,
    required this.alternativeStoreId,
    required this.alternativePrice,
  });

  @override
  List<Object> get props => [item, currentStoreId, alternativeStoreId, alternativePrice];
}

class TripStore extends Equatable {
  final String storeId;
  final String storeName;
  final List<TripItem> items;

  const TripStore({
    required this.storeId,
    required this.storeName,
    required this.items,
  });

  @override
  List<Object> get props => [storeId, storeName, items];
}

class TripPlan extends Equatable {
  final List<TripStore> stores;

  const TripPlan({required this.stores});

  @override
  List<Object> get props => [stores];
}