import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_shopping_mate/bloc/search/search_bloc.dart';
import 'package:my_shopping_mate/bloc/search/search_event.dart';
import 'package:my_shopping_mate/bloc/search/search_state.dart';
import 'package:my_shopping_mate/data/models/product_model.dart';
import 'package:my_shopping_mate/data/repositories/product_repository.dart';
import 'package:my_shopping_mate/presentation/widgets/molecules/product_card.dart';

// The actual UI, which listens to the BLoC.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    // Add the event to the BLoC. The BLoC's debouncing will handle the rest.
    context.read<SearchBloc>().add(SearchQueryChanged(query));
  }

  @override
  Widget build(BuildContext context) {
    // Provide the BLoC to the widget tree.
    return BlocProvider(
      create: (context) => SearchBloc(
        // In a real app, this repository would be provided by a dependency
        // injection framework instead of being instantiated here.
        productRepository: ProductRepository(),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: TextField(
            controller: _searchController,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Search products...',
              border: InputBorder.none,
              hintStyle: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color),
            ),
            style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 18),
            onChanged: _onSearchChanged,
          ),
          actions: [
            IconButton(icon: const Icon(Icons.qr_code_scanner), onPressed: () {}),
            // We can listen to the BLoC state to decide when to show the clear button
            BlocBuilder<SearchBloc, SearchState>(
              builder: (context, state) {
                if (state.query.isNotEmpty) {
                  return IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      // Reading context here is safe because BlocBuilder provides it.
                      context.read<SearchBloc>().add(const SearchQueryChanged(''));
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            )
          ],
        ),
        // Use BlocBuilder to rebuild the body based on the SearchState.
        body: BlocBuilder<SearchBloc, SearchState>(
          builder: (context, state) {
            switch (state.status) {
              case SearchStatus.loading:
                return const Center(child: CircularProgressIndicator());
              case SearchStatus.failure:
                return const Center(child: Text('Failed to fetch results.'));
              case SearchStatus.initial:
                return _buildInitialState();
              case SearchStatus.success:
                if (state.results.isEmpty) {
                  return _buildNoResultsState(state.query);
                }
                return _buildResultsList(state.results);
            }
          },
        ),
      ),
    );
  }

  Widget _buildInitialState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text('Search for products by name or brand.'),
        ],
      ),
    );
  }

  Widget _buildNoResultsState(String query) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.sentiment_dissatisfied_outlined, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          Text('No results found for "$query".'),
        ],
      ),
    );
  }

  Widget _buildResultsList(List<Product> results) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final product = results[index];
        return ProductCard(
          imageUrl: product.img,
          productName: product.name,
          brand: product.brand,
          bestPrice: product.price,
          storeName: product.store,
          onAddToList: () { // This context is safe because it's from the builder.
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${product.name} added to list.')),
            );
          },
        );
      },
    );
  }
}