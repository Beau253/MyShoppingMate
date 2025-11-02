import 'package.equatable/equatable.dart';

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

  @override
  List<Object> get props => [id, productName, quantity, price, isChecked];
}