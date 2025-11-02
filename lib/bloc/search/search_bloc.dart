import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_shopping_mate/bloc/search/search_event.dart';
import 'package:my_shopping_mate/bloc/search/search_state.dart';
import 'package:my_shopping_mate/data/repositories/product_repository.dart';

// Import this to use the debounce operator
import 'package:stream_transform/stream_transform.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final ProductRepository _productRepository;

  SearchBloc({required ProductRepository productRepository})
      : _productRepository = productRepository,
        super(const SearchState()) {
    on<SearchQueryChanged>(_onSearchQueryChanged,
        // Apply the debounce transformer here.
        transformer: (events, mapper) {
      return events
          .debounce(const Duration(milliseconds: 500))
          .switchMap(mapper);
    });
  }

  Future<void> _onSearchQueryChanged(
      SearchQueryChanged event, Emitter<SearchState> emit) async {
    final query = event.query;
    if (query.isEmpty) {
      // If the query is empty, reset to the initial state.
      return emit(const SearchState());
    }

    emit(state.copyWith(status: SearchStatus.loading, query: query));

    try {
      final results = await _productRepository.searchProducts(query);
      emit(state.copyWith(status: SearchStatus.success, results: results));
    } catch (error) {
      emit(state.copyWith(status: SearchStatus.failure));
    }
  }
}
