import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_shopping_mate/data/repositories/theme_repository.dart';

// --- BLoC Events ---
abstract class ThemeEvent extends Equatable {
  const ThemeEvent();
  @override
  List<Object> get props => [];
}

/// Event to load the saved theme from storage.
class ThemeLoaded extends ThemeEvent {}

/// Event when the user changes the theme mode (Light/Dark/System).
class ThemeModeChanged extends ThemeEvent {
  final ThemeMode themeMode;
  const ThemeModeChanged(this.themeMode);
  @override
  List<Object> get props => [themeMode];
}

/// Event when the user changes the accent color.
class AccentColorChanged extends ThemeEvent {
  final Color accentColor;
  const AccentColorChanged(this.accentColor);
  @override
  List<Object> get props => [accentColor];
}

// --- BLoC State ---
class ThemeState extends Equatable {
  final ThemeMode themeMode;
  final Color accentColor;

  const ThemeState({
    required this.themeMode,
    required this.accentColor,
  });

  // Initial state of the theme.
  factory ThemeState.initial() {
    return const ThemeState(
      themeMode: ThemeMode.system,
      accentColor: Color(0xFF357AF6), // Default blue
    );
  }

  ThemeState copyWith({
    ThemeMode? themeMode,
    Color? accentColor,
  }) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      accentColor: accentColor ?? this.accentColor,
    );
  }

  @override
  List<Object> get props => [themeMode, accentColor];
}

// --- The BLoC ---
class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final ThemeRepository _themeRepository;

  ThemeBloc({required ThemeRepository themeRepository})
      : _themeRepository = themeRepository,
        super(ThemeState.initial()) {
    on<ThemeLoaded>(_onThemeLoaded);
    on<ThemeModeChanged>(_onThemeModeChanged);
    on<AccentColorChanged>(_onAccentColorChanged);
  }

  Future<void> _onThemeLoaded(ThemeLoaded event, Emitter<ThemeState> emit) async {
    final (themeMode, accentColor) = await _themeRepository.loadTheme();
    emit(state.copyWith(themeMode: themeMode, accentColor: accentColor));
  }

  Future<void> _onThemeModeChanged(
      ThemeModeChanged event, Emitter<ThemeState> emit) async {
    await _themeRepository.saveTheme(event.themeMode, state.accentColor);
    emit(state.copyWith(themeMode: event.themeMode));
  }

  Future<void> _onAccentColorChanged(
      AccentColorChanged event, Emitter<ThemeState> emit) async {
    await _themeRepository.saveTheme(state.themeMode, event.accentColor);
    emit(state.copyWith(accentColor: event.accentColor));
  }
}