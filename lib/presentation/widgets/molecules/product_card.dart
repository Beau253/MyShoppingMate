import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ProductCard extends StatelessWidget {
  final String imageUrl;
  final String productName;
  final String brand;
  final double bestPrice;
  final String storeName;
  final VoidCallback onAddToList;

  const ProductCard({
    super.key,
    required this.imageUrl,
    required this.productName,
    required this.brand,
    required this.bestPrice,
    required this.storeName,
    required this.onAddToList,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'en_US', symbol: '\$');
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Product Image ---
            SizedBox(
              width: 80,
              height: 80,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  // Show a placeholder on error
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.image_not_supported_outlined, color: Colors.grey),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 12),

            // --- Product Details ---
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    productName,
                    style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(brand, style: theme.textTheme.bodySmall),
                  const SizedBox(height: 8),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '${currencyFormatter.format(bestPrice)} ',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.primaryColor,
                          ),
                        ),
                        TextSpan(
                          text: 'at $storeName',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // --- Add to List Button ---
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              color: theme.primaryColor,
              onPressed: onAddToList,
              tooltip: 'Add to List',
            ),
          ],
        ),
      ),
    );
  }
}