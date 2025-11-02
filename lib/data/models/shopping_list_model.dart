import 'package:equatable/equatable.dart';

class ShoppingList extends Equatable {
  final String id;
  final String name;
  final int itemCount;
  final double totalCost;

  const ShoppingList({
    required this.id,
    required this.name,
    required this.itemCount,
    required this.totalCost,
  });

  @override
  List<Object> get props => [id, name, itemCount, totalCost];
}