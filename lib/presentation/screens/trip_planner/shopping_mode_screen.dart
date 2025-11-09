import 'package:flutter/material.dart';
import 'package:my_shopping_mate/data/models/list_item_model.dart';
import 'package:my_shopping_mate/presentation/widgets/atoms/PrimaryButton.dart';
import 'package:my_shopping_mate/presentation/widgets/molecules/shopping_mode_item.dart';

class ShoppingModeScreen extends StatefulWidget {
  final String storeName;
  final List<ListItem> items; // CHANGED from Map to ListItem

  const ShoppingModeScreen({
    super.key,
    required this.storeName,
    required this.items,
  });

  @override
  State<ShoppingModeScreen> createState() => _ShoppingModeScreenState();
}

class _ShoppingModeScreenState extends State<ShoppingModeScreen> {
  late List<ListItem> _checklistItems;

  @override
  void initState() {
    super.initState();
    _checklistItems = List.from(widget.items);
  }

  double get _progress {
    if (_checklistItems.isEmpty) return 1.0;
    final checkedCount = _checklistItems.where((item) => item.isChecked).length;
    return checkedCount / _checklistItems.length;
  }

  void _onItemTapped(int index) {
    setState(() {
      final currentItem = _checklistItems[index];
      // Create a new item with the toggled checked state.
      _checklistItems[index] = currentItem.copyWith(isChecked: !currentItem.isChecked);
    });
  }

  Widget _buildCompletionWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline_rounded, size: 100, color: Theme.of(context).primaryColor),
            const SizedBox(height: 24),
            Text('All Done!', style: Theme.of(context).textTheme.displayLarge),
            const SizedBox(height: 8),
            Text(
              'You have checked off all items for ${widget.storeName}.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 48),
            PrimaryButton(
              text: 'Back to Trip Plan',
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.storeName),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: LinearProgressIndicator(
            value: _progress,
            backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
          ),
        ),
      ),
      body: _progress == 1.0
          ? _buildCompletionWidget()
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              itemCount: _checklistItems.length,
              itemBuilder: (context, index) {
                final item = _checklistItems[index];
                return ShoppingModeItem(
                  productName: item.productName,
                  quantity: item.quantity,
                  isChecked: item.isChecked,
                  onTap: () => _onItemTapped(index),
                );
              },
              separatorBuilder: (context, index) => const Divider(indent: 16, endIndent: 16),
            ),
    );
  }
}