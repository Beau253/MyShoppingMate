import 'package.flutter/material.dart';
import 'package.intl/intl.dart';

// A simple data class to hold alternative price info.
class AlternativePrice {
  final String storeName;
  final double price;
  AlternativePrice({required this.storeName, required this.price});
}

class TripItemCard extends StatelessWidget {
  final String productName;
  final double currentPrice;
  final int quantity;
  final AlternativePrice? alternative; // Can be null if no alternative exists
  final Function(String toStoreName)? onMove;

  const TripItemCard({
    super.key,
    required this.productName,
    required this.currentPrice,
    required this.quantity,
    this.alternative,
    this.onMove,
  });

  Widget _buildMoveAction(BuildContext context) {
    if (alternative == null || onMove == null) {
      // If there are no alternatives or no move action, return an empty container.
      return const SizedBox.shrink();
    }

    final priceDifference = alternative!.price - currentPrice;
    final currencyFormatter = NumberFormat.currency(locale: 'en_US', symbol: '');
    final differenceString = priceDifference >= 0
        ? '+${currencyFormatter.format(priceDifference)}'
        : '-${currencyFormatter.format(priceDifference.abs())}';

    return TextButton(
      onPressed: () => onMove!(alternative!.storeName),
      child: Text(
        'Move to ${alternative!.storeName} for $differenceString',
        textAlign: TextAlign.center,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'en_US', symbol: '\$');
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(productName, style: textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold)),
                      Text('Quantity: $quantity', style: textTheme.caption),
                    ],
                  ),
                ),
                Text(currencyFormatter.format(currentPrice * quantity), style: textTheme.bodyText1),
              ],
            ),
            if (alternative != null) ...[
              const Divider(height: 16),
              _buildMoveAction(context),
            ]
          ],
        ),
      ),
    );
  }
}