import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_shopping_mate/bloc/shopping_list/shopping_list_bloc.dart';
import 'package:my_shopping_mate/presentation/screens/lists/list_detail_screen.dart';
import 'package:my_shopping_mate/presentation/widgets/molecules/shopping_list_card.dart';

class ListsOverviewScreen extends StatelessWidget {
  const ListsOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ListsOverviewView();
  }
}

class ListsOverviewView extends StatelessWidget {
  const ListsOverviewView({super.key});

  /// Shows a dialog to create a new shopping list.
  Future<void> _showCreateListDialog(BuildContext context) async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();

    return showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Create New List'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: nameController,
              autofocus: true,
              decoration: const InputDecoration(hintText: 'e.g., "Weekend BBQ"'),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a list name.';
                }
                return null;
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Create'),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  // Dispatch the event to the BLoC.
                  context
                      .read<ShoppingListBloc>()
                      .add(ShoppingListCreated(nameController.text.trim()));
                  Navigator.of(dialogContext).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Lists'),
      ),
      body: BlocBuilder<ShoppingListBloc, ShoppingListState>(
        builder: (context, state) {
          if (state.status == ShoppingListStatus.loading || state.status == ShoppingListStatus.initial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == ShoppingListStatus.failure) {
            return const Center(child: Text('Failed to load lists.'));
          }
          if (state.shoppingLists.isEmpty) {
            return _buildEmptyState(context);
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: state.shoppingLists.length,
            itemBuilder: (context, index) {
              final list = state.shoppingLists[index];
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
                    );
                  },
                );
            },
          );
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateListDialog(context),
        tooltip: 'Create List',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_basket_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 24),
          Text(
            'No Shopping Lists Yet',
            style: Theme.of(context).textTheme.displayMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the "+" button to create your first list.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}