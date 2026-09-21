import 'package:fitness_training/core/resources/themes/theme.dart';
import 'package:fitness_training/data/repositories/preferences_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

@immutable
class AppThemeState {
  const AppThemeState({
    this.mode = ThemeMode.system,
    this.accent = AppAccent.fallback,
  });

  final ThemeMode mode;
  final AppAccent accent;

  AppThemeState copyWith({ThemeMode? mode, AppAccent? accent}) =>
      AppThemeState(mode: mode ?? this.mode, accent: accent ?? this.accent);

  @override
  bool operator ==(Object other) =>
      other is AppThemeState && other.mode == mode && other.accent == accent;

  @override
  int get hashCode => Object.hash(mode, accent);
}

@singleton
class ThemeCubit extends Cubit<AppThemeState> {
  ThemeCubit() : super(const AppThemeState()) {
    _restore();
  }

  final _prefs = PreferencesRepository();

  Future<void> _restore() async {
    final mode = await _prefs.getThemeMode();
    final accent = await _prefs.getAccent();
    emit(AppThemeState(mode: mode, accent: accent));
  }

  Future<void> setMode(ThemeMode mode) async {
    if (mode == state.mode) return;
    emit(state.copyWith(mode: mode));
    await _prefs.saveThemeMode(mode);
  }

  Future<void> setAccent(AppAccent accent) async {
    if (accent == state.accent) return;
    emit(state.copyWith(accent: accent));
    await _prefs.saveAccent(accent);
  }
}
