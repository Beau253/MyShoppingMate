import 'package:flutter/material.dart';

/// A reusable and styled text input field for the application.
///
/// This widget wraps TextFormField and provides consistent styling and behavior,
/// including support for password fields with a visibility toggle.
class TextInputField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final String? hintText;
  final IconData? prefixIcon;
  final TextInputType keyboardType;
  final bool isPassword;
  final FormFieldValidator<String>? validator;

  const TextInputField({
    super.key,
    required this.controller,
    required this.labelText,
    this.hintText,
    this.prefixIcon,
    this.keyboardType = TextInputType.text,
    this.isPassword = false,
    this.validator,
  });

  @override
  State<TextInputField> createState() => _TextInputFieldState();
}

class _TextInputFieldState extends State<TextInputField> {
  // Internal state to manage password visibility.
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  void _toggleVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get the current theme's input decoration theme for styling.
    final inputDecorationTheme = Theme.of(context).inputDecorationTheme;

    return TextFormField(
      controller: widget.controller,
      keyboardType: widget.keyboardType,
      obscureText: _obscureText,
      validator: widget.validator,
      decoration: InputDecoration(
        // The main label for the field.
        labelText: widget.labelText,
        // The hint text shown when the field is empty.
        hintText: widget.hintText,
        // Apply the border styles from our theme.
        border: inputDecorationTheme.border,
        focusedBorder: inputDecorationTheme.focusedBorder,
        // Add a prefix icon if one is provided.
        prefixIcon: widget.prefixIcon != null
            ? Icon(widget.prefixIcon)
            : null,
        // If this is a password field, add the visibility toggle icon.
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                  color: Theme.of(context).primaryColor.withAlpha((255 * 0.7).round()),
                ),
                onPressed: _toggleVisibility,
              )
            : null,
      ),
    );
  }
}