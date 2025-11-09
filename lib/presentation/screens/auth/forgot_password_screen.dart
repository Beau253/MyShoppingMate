import 'package:flutter/material.dart';
import 'package:my_shopping_mate/presentation/widgets/atoms/TextInputField.dart';
import 'package:my_shopping_mate/presentation/widgets/atoms/PrimaryButton.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  /// Handles the password reset request logic.
  Future<void> _sendResetLink() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // --- Simulate a network call to the backend to trigger the email ---
    await Future.delayed(const Duration(seconds: 2));
    // -----------------------------------------------------------------

    if (mounted) {
      // **CORRECTION:** Reset the loading state *before* navigating.
      // This ensures the button is in the correct state if the user navigates back.
      setState(() {
        _isLoading = false;
      });

      // Navigate to the new confirmation screen, passing the email.
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => PasswordResetConfirmationScreen(
            email: _emailController.text,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Provides a standard back button.
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),

                // --- Screen Title & Description ---
                Text(
                  'Reset Password',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displayLarge,
                ),
                const SizedBox(height: 16),
                Text(
                  "Enter the email associated with your account and we'll send an email with instructions to reset your password.",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 48),

                // --- Email Input Field ---
                TextInputField(
                  controller: _emailController,
                  labelText: 'Email',
                  hintText: 'you@example.com',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.contains('@') || !value.contains('.')) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                // --- Send Link Button ---
                PrimaryButton(
                  text: 'Send Instructions',
                  onPressed: _sendResetLink,
                  isLoading: _isLoading,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}