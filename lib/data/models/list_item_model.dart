import 'package:equatable/equatable.dart';

class ListItem extends Equatable {
  final String id;
  final String productName;
  final int quantity;
  final double price;
  final bool isChecked;

  const ListItem({
    required this.id,
    required this.productName,
    required this.quantity,
    required this.price,
    required this.isChecked,
  });

  ListItem copyWith({bool? isChecked}) {
    return ListItem(
      id: id,
      productName: productName,
      quantity: quantity,
      price: price,
      isChecked: isChecked ?? this.isChecked,
    );
  }

  factory ListItem.fromJson(Map<String, dynamic> json) {
    return ListItem(
      id: json['id']?.toString() ?? '',
      productName: json['productName'] as String? ?? json['product_name'] as String? ?? '',
      quantity: json['quantity'] as int? ?? 1,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      isChecked: json['isChecked'] as bool? ?? json['is_checked'] as bool? ?? false,
    );
  }

  @override
  List<Object> get props => [id, productName, quantity, price, isChecked];
}