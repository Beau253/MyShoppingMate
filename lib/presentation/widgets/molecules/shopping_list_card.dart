import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// A card widget to display a summary of a shopping list.
///
/// Used on the Dashboard and the Lists Overview screen.
class ShoppingListCard extends StatelessWidget {
  final String listName;
  final int itemCount;
  final double totalCost;
  final VoidCallback onTap;

  const ShoppingListCard({
    super.key,
    required this.listName,
    required this.itemCount,
    required this.totalCost,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Use the intl package for proper currency formatting.
    final currencyFormatter = NumberFormat.currency(locale: 'en_US', symbol: '\$');

    return Card(
      // The Card widget automatically uses the cardTheme from our AppTheme.
      margin: const EdgeInsets.only(bottom: 16.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.0), // Match the card's border radius
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // List Name
              Text(
                listName,
                style: Theme.of(context).textTheme.displayMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              // Item Count and Total Cost
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$itemCount Items',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    currencyFormatter.format(totalCost),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}