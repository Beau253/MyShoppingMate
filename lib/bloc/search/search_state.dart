import 'package:equatable/equatable.dart';
import 'package:my_shopping_mate/data/repositories/product_repository.dart';

enum SearchStatus { initial, loading, success, failure }

class SearchState extends Equatable {
  final SearchStatus status;
  final List<Product> results;
  final String query;

  const SearchState({
    this.status = SearchStatus.initial,
    this.results = const <Product>[],
    this.query = '',
  });

  SearchState copyWith({
    SearchStatus? status,
    List<Product>? results,
    String? query,
  }) {
    return SearchState(
      status: status ?? this.status,
      results: results ?? this.results,
      query: query ?? this.query,
    );
  }

  @override
  List<Object> get props => [status, results, query];
}