import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_shopping_mate/bloc/my_stores/my_stores_bloc.dart';
import 'package:my_shopping_mate/data/repositories/store_repository.dart';
import 'package:my_shopping_mate/presentation/widgets/atoms/text_input_field.dart';
import 'package:my_shopping_mate/presentation/widgets/atoms/primary_button.dart';

class MyStoresScreen extends StatelessWidget {
  const MyStoresScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MyStoresBloc(
        storeRepository: context.read<StoreRepository>(),
      )..add(MyStoresLoaded()),
      child: const MyStoresView(),
    );
  }
}

class MyStoresView extends StatelessWidget {
  const MyStoresView({super.key});

  void _showAddStoreDialog(BuildContext context) {
    final nameController = TextEditingController();
    final chainController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add New Store'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextInputField(
                controller: nameController,
                labelText: 'Store Name',
                hintText: 'e.g. Coles Bondi Junction',
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextInputField(
                controller: chainController,
                labelText: 'Chain',
                hintText: 'e.g. Coles',
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Required' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          PrimaryButton(
            text: 'Add',
            onPressed: () {
              if (formKey.currentState!.validate()) {
                context.read<MyStoresBloc>().add(
                      MyStoreAdded(nameController.text, chainController.text),
                    );
                Navigator.pop(dialogContext);
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Stores'),
      ),
      body: BlocBuilder<MyStoresBloc, MyStoresState>(
        builder: (context, state) {
          if (state.status == MyStoresStatus.loading && state.stores.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == MyStoresStatus.failure) {
            return const Center(child: Text('Failed to load stores.'));
          }
          if (state.stores.isEmpty) {
            return _buildEmptyState(context);
          }

          return ReorderableListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            itemCount: state.stores.length,
            itemBuilder: (context, index) {
              final store = state.stores[index];
              return _StoreTile(
                key: ValueKey(store.id),
                storeName: store.name,
                chainName: store.chain,
                onDelete: () {
                  context.read<MyStoresBloc>().add(MyStoreRemoved(store));
                },
              );
            },
            onReorder: (oldIndex, newIndex) {
              context
                  .read<MyStoresBloc>()
                  .add(MyStoresReordered(oldIndex, newIndex));
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddStoreDialog(context),
        tooltip: 'Add a new store',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.store_mall_directory_outlined,
              size: 80, color: Colors.grey[400]),
          const SizedBox(height: 24),
          Text(
            'No Preferred Stores',
            style: Theme.of(context).textTheme.displayMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the "+" button to add stores.\nYour search results will be prioritized for these locations.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _StoreTile extends StatelessWidget {
  const _StoreTile({
    super.key,
    required this.storeName,
    this.chainName,
    required this.onDelete,
  });

  final String storeName;
  final String? chainName;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      child: ListTile(
        leading: const Icon(Icons.store, size: 40),
        title: Text(storeName, style: Theme.of(context).textTheme.bodyLarge),
        subtitle: chainName != null ? Text(chainName!) : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: onDelete,
              tooltip: 'Remove Store',
            ),
            const Icon(Icons.drag_handle),
          ],
        ),
      ),
    );
  }
}
