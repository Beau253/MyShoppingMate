import 'package:flutter/material.dart';
import 'package:my_shopping_mate/presentation/screens/settings/pin_entry_screen.dart';
import 'package:my_shopping_mate/presentation/widgets/atoms/PrimaryButton.dart';
import 'package:my_shopping_mate/presentation/widgets/molecules/settings_tile.dart';

class ManagePINScreen extends StatefulWidget {
  const ManagePINScreen({super.key});

  @override
  State<ManagePINScreen> createState() => _ManagePINScreenState();
}

class _ManagePINScreenState extends State<ManagePINScreen> {
  bool _isPinEnabled = true;

  void _enablePin() {
    // Navigate to the setup screen. The logic inside that screen
    // would handle setting the state. For now, we just navigate.
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const PinEntryScreen(purpose: PinEntryPurpose.setup)),
    );
  }

  void _changePin() {
    // A full flow would confirm the old PIN first, then set the new one.
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const PinEntryScreen(purpose: PinEntryPurpose.confirm)),
    );
  }
  
  void _disablePin() {
    // The logic inside this screen would handle disabling.
     Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const PinEntryScreen(purpose: PinEntryPurpose.confirm)),
    );
  }

  void _showDisablePinDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Disable PIN Lock?'),
        content: const Text('You will be asked to confirm your current PIN.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
              _disablePin();
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage PIN'),
      ),
      body: _isPinEnabled ? _buildPinEnabledView() : _buildPinDisabledView(),
    );
  }

  Widget _buildPinEnabledView() {
    return ListView(
      children: [
        const SizedBox(height: 20),
        const Center(
          child: Icon(Icons.phonelink_lock, size: 60, color: Colors.green),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            'PIN Lock is Active',
            style: Theme.of(context).textTheme.headline2,
          ),
        ),
        const SizedBox(height: 32),
        SettingsTile(
          leadingIcon: Icons.password,
          title: 'Change PIN',
          subtitle: 'Set a new PIN for app entry',
          onTap: _changePin,
        ),
        SettingsTile(
          leadingIcon: Icons.lock_open,
          title: 'Disable PIN Lock',
          subtitle: 'App will no longer require a PIN to open',
          onTap: _showDisablePinDialog,
        ),
      ],
    );
  }

  Widget _buildPinDisabledView() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Center(
            child: Icon(Icons.phonelink_off, size: 60, color: Colors.red),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'PIN Lock is Inactive',
              style: Theme.of(context).textTheme.headline2,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'For enhanced security, we recommend enabling a PIN lock. You will be asked for this PIN each time you open the app.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyText2,
          ),
          const SizedBox(height: 32),
          PrimaryButton(
            text: 'Enable PIN Lock',
            onPressed: _enablePin,
          ),
        ],
      ),
    );
  }
}