import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemePreference { system, light, dark }

class ThemeState extends Equatable {
  final AppThemePreference preference;
  final bool isLoaded;
  final String? error;

  const ThemeState({
    this.preference = AppThemePreference.system,
    this.isLoaded = false,
    this.error,
  });

  ThemeMode get themeMode => switch (preference) {
    AppThemePreference.system => ThemeMode.system,
    AppThemePreference.light => ThemeMode.light,
    AppThemePreference.dark => ThemeMode.dark,
  };

  @override
  List<Object?> get props => [preference, isLoaded, error];
}

class ThemeCubit extends Cubit<ThemeState> {
  static const _preferenceKey = 'app_theme_preference';
  final SharedPreferences _preferences;

  ThemeCubit({required SharedPreferences preferences})
    : _preferences = preferences,
      super(const ThemeState());

  Future<void> loadPreference() async {
    try {
      final stored = _preferences.getString(_preferenceKey);
      final preference = AppThemePreference.values.firstWhere(
        (value) => value.name == stored,
        orElse: () => AppThemePreference.system,
      );
      emit(ThemeState(preference: preference, isLoaded: true));
    } catch (error) {
      emit(
        ThemeState(
          preference: AppThemePreference.system,
          isLoaded: true,
          error: 'Your saved appearance preference could not be loaded: $error',
        ),
      );
    }
  }

  Future<bool> setPreference(AppThemePreference preference) async {
    try {
      final saved = await _preferences.setString(
        _preferenceKey,
        preference.name,
      );
      if (!saved) {
        emit(
          state.copyWith(
            error: 'Your appearance preference could not be saved.',
          ),
        );
        return false;
      }
      emit(ThemeState(preference: preference, isLoaded: true));
      return true;
    } catch (error) {
      emit(
        state.copyWith(
          error: 'Your appearance preference could not be saved: $error',
        ),
      );
      return false;
    }
  }
}

extension on ThemeState {
  ThemeState copyWith({String? error}) =>
      ThemeState(preference: preference, isLoaded: isLoaded, error: error);
}
