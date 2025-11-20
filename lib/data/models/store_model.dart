import 'package:equatable/equatable.dart';

class Store extends Equatable {
  final String id;
  final String name;
  final String? logoUrl;
  final String? chain;

  const Store({
    required this.id,
    required this.name,
    this.logoUrl,
    this.chain,
  });

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      id: json['id'].toString(),
      name: json['name'],
      chain: json['chain'],
      logoUrl: null, // Backend doesn't provide logo URL yet
    );
  }

  @override
  List<Object?> get props => [id, name, logoUrl, chain];
}
