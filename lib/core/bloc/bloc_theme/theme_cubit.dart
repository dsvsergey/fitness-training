import 'package:fitness_training/data/repositories/preferences_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

@singleton
class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit() : super(ThemeMode.system) {
    _restore();
  }

  final _prefs = PreferencesRepository();

  Future<void> _restore() async {
    final mode = await _prefs.getThemeMode();
    emit(mode);
  }

  Future<void> setMode(ThemeMode mode) async {
    if (mode == state) return;
    emit(mode);
    await _prefs.saveThemeMode(mode);
  }
}
