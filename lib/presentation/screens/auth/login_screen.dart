import 'package:flutter/material.dart';
import 'package:my_shopping_mate/presentation/widgets/atoms/text_input_field.dart';
import 'package:my_shopping_mate/presentation/widgets/atoms/primary_button.dart';
import 'package:my_shopping_mate/presentation/screens/main_navigation_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // A GlobalKey for the Form widget to handle validation.
  final _formKey = GlobalKey<FormState>();

  // Controllers to manage the text in the input fields.
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // State variable to manage the loading state of the login button.
  bool _isLoading = false;

  @override
  void dispose() {
    // Dispose of controllers to free up resources and prevent memory leaks.
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Handles the login logic when the button is pressed.
  Future<void> _login() async {
    // First, validate the form. If it's not valid, do nothing.
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Set the loading state to true to show the progress indicator on the button.
    setState(() {
      _isLoading = true;
    });

    // --- Simulate a network call to the backend ---
    // In a real app, this is where you would call your authentication service.
    await Future.delayed(const Duration(seconds: 2));
    // ---------------------------------------------

    // After the network call is complete, set the loading state back to false.
    // In a real app, you would navigate to the home screen on success.
    if (mounted) {
    // THIS IS THE CHANGE: Navigate to the main app screen after login.
    // We use pushReplacement so the user cannot press the back button
    // to return to the login screen.
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const MainNavigationScreen(),
      ),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Use SingleChildScrollView to prevent overflow when the keyboard appears.
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Add some space at the top.
                const SizedBox(height: 80),

                // --- App Logo/Title ---
                Text(
                  'Welcome Back',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displayLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Sign in to your account',
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
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // --- Password Input Field ---
                TextInputField(
                  controller: _passwordController,
                  labelText: 'Password',
                  isPassword: true,
                  prefixIcon: Icons.lock_outline,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 8) {
                      return 'Password must be at least 8 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                // --- Forgot Password Link ---
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // Placeholder for forgot password navigation
                    },
                    child: const Text('Forgot Password?'),
                  ),
                ),
                const SizedBox(height: 24),

                // --- Login Button ---
                PrimaryButton(
                  text: 'Login',
                  onPressed: _login,
                  isLoading: _isLoading,
                ),
                const SizedBox(height: 32),
                
                // --- Sign Up Link ---
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                        Text(
                            "Don't have an account?",
                            style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        TextButton(
                            onPressed: () {
                                // Placeholder for sign up navigation
                            },
                            child: const Text('Sign Up'),
                        ),
                    ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}