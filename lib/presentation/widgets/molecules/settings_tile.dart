import 'package:flutter/material.dart';

class SettingsTile extends StatelessWidget {
  final IconData leadingIcon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const SettingsTile({
    super.key,
    required this.leadingIcon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: ListTile(
          leading: Icon(leadingIcon, color: theme.primaryColor),
          title: Text(title, style: theme.textTheme.bodyLarge),
          subtitle: subtitle != null
              ? Text(subtitle!, style: theme.textTheme.bodySmall)
              : null,
          trailing: trailing,
        ),
      ),
    );
  }
}