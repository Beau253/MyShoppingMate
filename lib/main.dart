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
}```

#### **Step 1.5: Update `app_theme.dart` to Accept a Dynamic Color**

Our theme needs to be a function that accepts the accent color.

**File: `lib/presentation/theme/app_theme.dart`** (Updated)

```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  // THEME IS NOW A DYNAMIC FUNCTION
  static ThemeData getTheme({
    required Brightness brightness,
    required Color accentColor,
  }) {
    final isLight = brightness == Brightness.light;
    final backgroundColor = isLight ? AppColors.lightBackground : AppColors.darkBackground;
    final surfaceColor = isLight ? AppColors.lightSurface : AppColors.darkSurface;
    final onBackgroundColor = isLight ? AppColors.lightOnBackground : AppColors.darkOnBackground;
    final onSurfaceColor = isLight ? AppColors.lightOnSurface : AppColors.darkOnSurface;

    return ThemeData(
      brightness: brightness,
      primaryColor: accentColor,
      scaffoldBackgroundColor: backgroundColor,
      
      textTheme: GoogleFonts.interTextTheme(ThemeData(brightness: brightness).textTheme).copyWith(
        displayLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: onBackgroundColor),
        displayMedium: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: onBackgroundColor),
        bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: onBackgroundColor),
        bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: onSurfaceColor),
        labelLarge: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.white),
        bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: onSurfaceColor),
      ),

      cardTheme: CardTheme(
        elevation: isLight ? 2 : 4,
        color: surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: onSurfaceColor, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: accentColor, width: 1.5),
        ),
      ), colorScheme: ColorScheme.fromSeed(
        seedColor: accentColor,
        brightness: brightness,
        primary: accentColor,
        surface: surfaceColor
      ).copyWith(background: surfaceColor),
    );
  }
}