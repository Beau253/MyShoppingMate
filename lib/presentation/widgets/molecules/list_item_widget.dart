import 'package:flutter/material.dart';
import 'package.intl/intl.dart';

class ListItemWidget extends StatelessWidget {
  final String productName;
  final int quantity;
  final double price;
  final bool isChecked;
  final ValueChanged<bool?> onChanged;

  const ListItemWidget({
    super.key,
    required this.productName,
    required this.quantity,
    required this.price,
    required this.isChecked,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'en_US', symbol: '\$');
    final textTheme = Theme.of(context).textTheme;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: isChecked ? 0.5 : 1.0,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 8.0),
        leading: Checkbox(
          value: isChecked,
          onChanged: onChanged,
        ),
        title: Text(
          productName,
          style: textTheme.bodyLarge?.copyWith(
            decoration: isChecked ? TextDecoration.lineThrough : TextDecoration.none,
          ),
        ),
        subtitle: Text(
          'Quantity: $quantity',
          style: textTheme.bodySmall?.copyWith(
            decoration: isChecked ? TextDecoration.lineThrough : TextDecoration.none,
          ),
        ),
        trailing: Text(
          currencyFormatter.format(price * quantity),
          style: textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
            decoration: isChecked ? TextDecoration.lineThrough : TextDecoration.none,
          ),
        ),
      ),
    );
  }
}