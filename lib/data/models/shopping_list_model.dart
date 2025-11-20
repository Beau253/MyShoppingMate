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

  factory ShoppingList.fromJson(Map<String, dynamic> json) {
    return ShoppingList(
      id: json['id'] as String? ?? json['public_id'] as String,
      name: json['name'] as String,
      itemCount: json['itemCount'] as int? ?? json['item_count'] as int? ?? 0,
      totalCost: (json['totalCost'] as num?)?.toDouble() ?? (json['total_cost'] as num?)?.toDouble() ?? 0.0,
    );
  }

  @override
  List<Object> get props => [id, name, itemCount, totalCost];
}