import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_shopping_mate/bloc/theme/theme_bloc.dart';
import 'package:my_shopping_mate/presentation/theme/app_colors.dart';

class AppearanceScreen extends StatelessWidget {
  const AppearanceScreen({super.key});

  // A curated list of accessible accent colors.
  final List<Color> _accentColors = const [
    AppColors.primary,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.pink,
  ];

  @override
  Widget build(BuildContext context) {
    // The entire screen is wrapped in a BlocBuilder to get the current theme state.
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Appearance'),
          ),
          body: ListView(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            children: [
              // --- THEME MODE SECTION ---
              const _SectionHeader('Theme'),
              RadioGroup<ThemeMode>(
                groupValue: state.themeMode,
                onChanged: (value) {
                  if (value != null) {
                    context.read<ThemeBloc>().add(ThemeModeChanged(value));
                  }
                },
                child: const Column(
                  children: [
                    RadioListTile<ThemeMode>(
                      title: Text('System Default'),
                      subtitle: Text('Automatically adapt to device theme'),
                      value: ThemeMode.system,
                    ),
                    RadioListTile<ThemeMode>(
                      title: Text('Light'),
                      value: ThemeMode.light,
                    ),
                    RadioListTile<ThemeMode>(
                      title: Text('Dark'),
                      value: ThemeMode.dark,
                    ),
                  ],
                ),
              ),

              // --- ACCENT COLOR SECTION ---
              const _SectionHeader('Accent Color'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Wrap(
                  spacing: 16.0,
                  runSpacing: 16.0,
                  children: _accentColors.map((color) {
                    return _ColorCircle(
                      color: color,
                      isSelected: state.accentColor.toARGB32() == color.toARGB32(),
                      onTap: () {
                        context.read<ThemeBloc>().add(AccentColorChanged(color));
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Helper widgets remain the same
class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }
}

class _ColorCircle extends StatelessWidget {
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _ColorCircle({
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: 24,
        backgroundColor: color,
        child: isSelected ? const Icon(Icons.check, color: Colors.white) : null,
      ),
    );
  }
}