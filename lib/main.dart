import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_shopping_mate/bloc/auth/auth_bloc.dart';
import 'package:my_shopping_mate/bloc/theme/theme_bloc.dart';
import 'package:my_shopping_mate/data/repositories/auth_repository.dart';
import 'package:my_shopping_mate/data/repositories/theme_repository.dart';
import 'package:my_shopping_mate/presentation/screens/auth/login_screen.dart';
import 'package:my_shopping_mate/presentation/theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Provide all repositories at the top level.
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (context) => AuthRepository()),
        RepositoryProvider(create: (context) => ThemeRepository()),
      ],
      // Provide all BLoCs that have a global scope.
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AuthBloc(
              authRepository: context.read<AuthRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) => ThemeBloc(
              themeRepository: context.read<ThemeRepository>(),
            )..add(ThemeLoaded()), // Load the theme on app start.
          ),
        ],
        child: const AppView(),
      ),
    );
  }
}

// The AppView widget listens to the ThemeBloc to build the MaterialApp
class AppView extends StatelessWidget {
  const AppView({super.key});

  @override
  Widget build(BuildContext context) {
    // BlocBuilder rebuilds the MaterialApp whenever the ThemeState changes.
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        return MaterialApp(
          title: 'My Shopping Mate',
          // The theme is now dynamically generated based on the BLoC state.
          theme: AppTheme.getTheme(
            brightness: Brightness.light,
            accentColor: state.accentColor,
          ),
          darkTheme: AppTheme.getTheme(
            brightness: Brightness.dark,
            accentColor: state.accentColor,
          ),
          themeMode: state.themeMode,
          debugShowCheckedModeBanner: false,
          home: const LoginScreen(),
        );
      },
    );
  }
}