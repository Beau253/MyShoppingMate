import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_shopping_mate/bloc/shopping_list/shopping_list_bloc.dart';
import 'package:my_shopping_mate/presentation/screens/lists/list_detail_screen.dart';
import 'package:my_shopping_mate/presentation/widgets/molecules/shopping_list_card.dart';

class DashboardScreen extends StatelessWidget {
  final VoidCallback onSeeAllListsTapped;
  final VoidCallback onSearchBarTapped;

  const DashboardScreen({
    super.key,
    required this.onSeeAllListsTapped,
    required this.onSearchBarTapped,
  });

  @override
  Widget build(BuildContext context) {
    return const DashboardView();
  }
}

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    // We access the callbacks via context.findAncestorWidgetOfExactType()
    // This is slightly more complex but keeps the view pure.
    final parent = context.findAncestorWidgetOfExactType<DashboardScreen>()!;
    
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildGreeting(context),
                const SizedBox(height: 24),
                _buildSearchBar(context, onSearchBarTapped: parent.onSearchBarTapped),
                const SizedBox(height: 32),
                _buildActiveListsSection(context, onSeeAllListsTapped: parent.onSeeAllListsTapped),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGreeting(BuildContext context) {
    return Text(
      'Good morning, User!',
      style: Theme.of(context).textTheme.headline1,
    );
  }

  Widget _buildSearchBar(BuildContext context, {required VoidCallback onSearchBarTapped}) {
    return GestureDetector(
      onTap: onSearchBarTapped,
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            children: [
              Icon(Icons.search, color: Theme.of(context).textTheme.bodyText2?.color),
              const SizedBox(width: 12),
              Text('Search for products...', style: Theme.of(context).textTheme.bodyText2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveListsSection(BuildContext context, {required VoidCallback onSeeAllListsTapped}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Active Lists', style: Theme.of(context).textTheme.headline2),
            TextButton(
              onPressed: onSeeAllListsTapped,
              child: const Text('See All'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        BlocBuilder<ShoppingListBloc, ShoppingListState>(
          builder: (context, state) {
            // The dashboard only shows the first 2 lists as a preview.
            final previewLists = state.shoppingLists.take(2).toList();

            if (state.status == ShoppingListStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (previewLists.isEmpty) {
              return _buildEmptyState(context);
            }
            return Column(
              children: previewLists.map((list) {
                return ShoppingListCard(
                  listName: list.name,
                  itemCount: list.itemCount,
                  totalCost: list.totalCost,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ListDetailScreen(
                          listId: list.id, // PASS THE ID
                          listName: list.name,
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48.0, horizontal: 24.0),
      decoration: BoxDecoration(
        color: Theme.of(context).backgroundColor,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        children: [
          Icon(Icons.list_alt_outlined, size: 60, color: Theme.of(context).primaryColor),
          const SizedBox(height: 16),
          Text(
            'No Active Lists',
            style: Theme.of(context).textTheme.headline2,
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the "Lists" tab below to create your first shopping list.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyText2,
          ),
        ],
      ),
    );
  }
}