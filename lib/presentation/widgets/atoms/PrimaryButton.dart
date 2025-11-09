import 'package:flutter/material.dart';
import 'package:my_shopping_mate/presentation/theme/app_colors.dart';

/// A reusable primary button for the application.
///
/// This button is the main call-to-action button and should be used for
/// primary actions like "Login", "Save", "Confirm", etc.
///
/// It handles its own loading and disabled states.
class PrimaryButton extends StatelessWidget {
  /// The text to be displayed on the button.
  final String text;

  /// The callback that is called when the button is tapped.
  /// If null, the button will be displayed in a disabled state.
  final VoidCallback? onPressed;

  /// A flag to indicate if the button is in a loading state.
  /// When true, a progress indicator is shown instead of the text.
  final bool isLoading;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    // Determine if the button should be interactable.
    // A button is disabled if onPressed is null OR if it's in a loading state.
    final bool isEnabled = onPressed != null && !isLoading;

    return ElevatedButton(
      // Pass the onPressed callback only if the button is enabled.
      onPressed: isEnabled ? onPressed : null,
      
      style: ElevatedButton.styleFrom(
        // Use the primary color from the current theme.
        backgroundColor: Theme.of(context).primaryColor,
        // Set a fixed vertical padding for a consistent button height.
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        // Define the disabled state's appearance.
        disabledBackgroundColor: Theme.of(context).primaryColor.withOpacity(0.5),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: isLoading
            // If loading, show a centered progress indicator.
            ? const SizedBox(
                height: 24.0,
                width: 24.0,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                ),
              )
            // If not loading, show the button text.
            : Text(
                text,
                // Use the button text style from the current theme.
                style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.white),
              ),
      ),
    );
  }
}