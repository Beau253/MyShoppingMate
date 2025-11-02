import 'package:flutter/material.dart';

enum PinEntryPurpose { setup, change, confirm }

class PinEntryScreen extends StatelessWidget {
  final PinEntryPurpose purpose;

  const PinEntryScreen({super.key, required this.purpose});

  String _getTitle() {
    switch (purpose) {
      case PinEntryPurpose.setup:
        return 'Set Up a New PIN';
      case PinEntryPurpose.change:
        return 'Enter Your New PIN';
      case PinEntryPurpose.confirm:
        return 'Enter Your Current PIN';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle()),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'This is a placeholder for the PIN entry UI.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyText1,
              ),
              const SizedBox(height: 20),
              // In a real implementation, this would be a custom UI with
              // dots and a number pad.
              const CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}