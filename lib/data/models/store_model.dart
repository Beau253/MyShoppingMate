import 'package:equatable/equatable.dart';

class Store extends Equatable {
  final String id;
  final String name;
  final String logoUrl;

  const Store({required this.id, required this.name, required this.logoUrl});

  @override
  List<Object> get props => [id, name, logoUrl];
}