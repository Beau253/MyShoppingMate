import 'package.flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_shopping_mate/bloc/auth/auth_bloc.dart';
import 'package:my_shopping_mate/bloc/auth/auth_event.dart';
import 'package:my_shopping_mate/bloc/auth/auth_state.dart';
import 'package:my_shopping_mate/presentation/screens/auth/login_screen.dart';
import 'package:my_shopping_mate/presentation/screens/settings/appearance_screen.dart';
import 'package:my_shopping_mate/presentation/screens/settings/change_password_screen.dart';
import 'package:my_shopping_mate/presentation/screens/settings/edit_profile_screen.dart';
import 'package:my_shopping_mate/presentation/screens/settings/manage_pin_screen.dart';
import 'package:my_shopping_mate/presentation/screens/settings/my_stores_screen.dart';
import 'package:my_shopping_mate/presentation/theme/app_colors.dart';
import 'package:my_shopping_mate/presentation/widgets/molecules/settings_tile.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              // We use the root context to ensure we find the AuthBloc.
              context.read<AuthBloc>().add(LogoutRequested());
              Navigator.of(dialogContext).pop(); // Close the dialog
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Wrap the Scaffold in a BlocListener to handle the navigation side-effect
    // of the authentication state changing.
    return BlocListener<AuthBloc, AuthenticationState>(
      listener: (context, state) {
        // When the state becomes unauthenticated, navigate to the login screen.
        if (state.status == AuthenticationStatus.unauthenticated) {
          // This method of navigation removes all previous screens from the stack,
          // preventing the user from pressing the back button to return to a
          // screen that requires authentication.
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
        ),
        body: ListView(
          children: [
            _buildAccountSection(context),
            _buildAppearanceSection(context),
            _buildSecuritySection(context),
            _buildAboutSection(context),
            const Divider(),
            // The Logout Tile, which triggers the dialog.
            ListTile(
              leading: const Icon(Icons.logout, color: AppColors.error),
              title: const Text('Logout', style: TextStyle(color: AppColors.error)),
              onTap: () => _showLogoutDialog(context),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET BUILDER HELPERS ---
  // These remain unchanged but are included for completeness as requested.

  Widget _buildAccountSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader('Account'),
        SettingsTile(
          leadingIcon: Icons.person_outline,
          title: 'Edit Profile',
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const EditProfileScreen()),
            );
          },
        ),
        SettingsTile(
          leadingIcon: Icons.store_outlined,
          title: 'My Stores',
          subtitle: 'Manage your preferred shopping locations',
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const MyStoresScreen()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAppearanceSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader('Appearance'),
        SettingsTile(
          leadingIcon: Icons.color_lens_outlined,
          title: 'Theme & Appearance',
          subtitle: 'Customize dark mode and accent colors',
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const AppearanceScreen()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSecuritySection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader('Security'),
        SettingsTile(
          leadingIcon: Icons.lock_outline,
          title: 'Change Password',
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const ChangePasswordScreen()),
            );
          },
        ),
        SettingsTile(
          leadingIcon: Icons.pin_outlined,
          title: 'Manage PIN',
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const ManagePINScreen()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader('About'),
        SettingsTile(
          leadingIcon: Icons.privacy_tip_outlined,
          title: 'Privacy Policy',
          onTap: () { /* Placeholder for launching URL */ },
        ),
        SettingsTile(
          leadingIcon: Icons.description_outlined,
          title: 'Terms of Service',
          onTap: () { /* Placeholder for launching URL */ },
        ),
        const SettingsTile(
          leadingIcon: Icons.info_outline,
          title: 'App Version',
          subtitle: '1.0.0', // This would be fetched dynamically
        ),
      ],
    );
  }
}

// A simple helper widget for section headers.
class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 8.0),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.caption?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }
}