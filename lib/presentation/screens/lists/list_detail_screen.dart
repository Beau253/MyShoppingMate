import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:my_shopping_mate/bloc/list_detail/list_detail_bloc.dart';
import 'package:my_shopping_mate/data/repositories/shopping_list_repository.dart'; // Assuming FakeShoppingListRepository is here
import 'package:my_shopping_mate/presentation/screens/trip_planner/trip_optimization_screen.dart';
import 'package:my_shopping_mate/presentation/widgets/atoms/primary_button.dart';
import 'package:my_shopping_mate/presentation/widgets/molecules/list_item_widget.dart';

class ListDetailScreen extends StatelessWidget {
  final String listId;
  final String listName;

  const ListDetailScreen({
    super.key,
    required this.listId,
    required this.listName,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ListDetailBloc(
        shoppingListRepository: FakeShoppingListRepository(),
      )..add(ListDetailLoaded(listId)),
      child: ListDetailView(listName: listName),
    );
  }
}

class ListDetailView extends StatelessWidget {
  final String listName;
  const ListDetailView({super.key, required this.listName});

  // --- NEW METHOD: SHOW ADD ITEM DIALOG ---
  Future<void> _showAddItemDialog(BuildContext context) async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final quantityController = TextEditingController(text: '1');
    final priceController = TextEditingController();

    return showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Add New Item'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextFormField(
                    controller: nameController,
                    autofocus: true,
                    decoration: const InputDecoration(labelText: 'Product Name'),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a name.';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: quantityController,
                    decoration: const InputDecoration(labelText: 'Quantity'),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) {
                      if (value == null || value.isEmpty || int.tryParse(value) == null || int.parse(value) <= 0) {
                        return 'Enter a valid quantity.';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: priceController,
                    decoration: const InputDecoration(labelText: 'Price', prefixText: '\$'),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value == null || value.isEmpty || double.tryParse(value) == null || double.parse(value) < 0) {
                        return 'Enter a valid price.';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            ElevatedButton(
              child: const Text('Add Item'),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  context.read<ListDetailBloc>().add(
                    ListItemAdded(
                      productName: nameController.text.trim(),
                      quantity: int.parse(quantityController.text),
                      price: double.parse(priceController.text),
                    ),
                  );
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
    final totalCost = context.select((ListDetailBloc bloc) => bloc.state.totalCost);
    final currencyFormatter = NumberFormat.currency(locale: 'en_US', symbol: '\$');

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(listName),
            Text(
              'Total: ${currencyFormatter.format(totalCost)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70),
            )
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<ListDetailBloc, ListDetailState>(
              builder: (context, state) {
                if (state.status == ListDetailStatus.loading || state.status == ListDetailStatus.initial) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state.status == ListDetailStatus.failure) {
                  return const Center(child: Text('Failed to load list items.'));
                }
                if (state.items.isEmpty) {
                  return const Center(
                    child: Text('This list has no items yet.\nTap the + button to add one!'),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                  itemCount: state.items.length,
                  itemBuilder: (context, index) {
                    final item = state.items[index];
                    return ListItemWidget(
                      productName: item.productName,
                      quantity: item.quantity,
                      price: item.price,
                      isChecked: item.isChecked,
                      onChanged: (_) {
                        context.read<ListDetailBloc>().add(ListItemToggled(item));
                      },
                    );
                  },
                  separatorBuilder: (context, index) => const Divider(height: 1),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: PrimaryButton(
              text: 'Plan My Shopping Trip',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => TripOptimizationScreen(
                      listId: context.read<ListDetailBloc>().state.listId,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // --- CONNECT THE DIALOG ---
          _showAddItemDialog(context);
        },
        child: const Icon(Icons.add_shopping_cart),
      ),
    );
  }
}