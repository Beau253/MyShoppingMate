import 'package:equatable/equatable.dart';

class Product extends Equatable {
  final String id;
  final String name;
  final String brand;
  final String img;
  final double price;
  final String store;

  const Product({
    required this.id,
    required this.name,
    required this.brand,
    required this.img,
    required this.price,
    required this.store,
  });

  @override
  List<Object> get props => [id, name, brand, img, price, store];
}
