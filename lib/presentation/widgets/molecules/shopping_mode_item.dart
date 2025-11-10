import 'package:flutter/material.dart';

class ShoppingModeItem extends StatelessWidget {
  final String productName;
  final int quantity;
  final bool isChecked;
  final VoidCallback onTap;

  const ShoppingModeItem({
    super.key,
    required this.productName,
    required this.quantity,
    required this.isChecked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
      leading: Checkbox(
        value: isChecked,
        onChanged: (_) => onTap(), // The onTap callback handles the logic
        // Make the checkbox larger for easier tapping
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.comfortable,
      ),
      title: Text(
        productName,
        style: textTheme.bodyText1?.copyWith(
          fontSize: 18, // Slightly larger font for readability
          decoration: isChecked ? TextDecoration.lineThrough : TextDecoration.none,
          color: isChecked ? textTheme.caption?.color : textTheme.bodyText1?.color,
        ),
      ),
      trailing: Text(
        'x$quantity',
        style: textTheme.headline2?.copyWith(
          color: isChecked ? theme.disabledColor : theme.primaryColor,
        ),
      ),
    );
  }
}