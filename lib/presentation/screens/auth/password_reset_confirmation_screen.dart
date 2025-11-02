import 'package.flutter/material.dart';
import 'package:my_shopping_mate/presentation/widgets/atoms/PrimaryButton.dart';

class PasswordResetConfirmationScreen extends StatelessWidget {
  final String email;

  const PasswordResetConfirmationScreen({
    super.key,
    required this.email,
  });

  /// Navigates back to the first screen in the navigation stack (the Login screen).
  void _backToLogin(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // The back button is automatically handled by the Navigator.
        backgroundColor: Colors.transparent,
        elevation: 0,
        // Hide the back button in the app bar to encourage using the main button.
        automaticallyImplyLeading: false, 
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- Icon ---
            Icon(
              Icons.mark_email_read_outlined,
              size: 80,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 32),

            // --- Title ---
            Text(
              'Check Your Email',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headline1,
            ),
            const SizedBox(height: 16),

            // --- Descriptive Text ---
            Text.rich(
              TextSpan(
                style: Theme.of(context).textTheme.bodyText2,
                children: [
                  const TextSpan(text: "We've sent password recovery instructions to "),
                  TextSpan(
                    text: email,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyText1?.color,
                    ),
                  ),
                  const TextSpan(text: ". Please check your inbox and spam folder."),
                ],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),

            // --- Back to Login Button ---
            PrimaryButton(
              text: 'Back to Login',
              onPressed: () => _backToLogin(context),
            ),
            
            // To push content up from the bottom of the screen
            const Spacer(),
          ],
        ),
      ),
    );
  }
}