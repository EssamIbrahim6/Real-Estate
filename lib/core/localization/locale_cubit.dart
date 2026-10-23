import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'locale_state.dart';

class LocaleCubit extends Cubit<LocaleState> {
  static const String preferenceKey = 'app_locale_code';
  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('ar'),
  ];

  final SharedPreferences _preferences;

  LocaleCubit({required SharedPreferences preferences})
    : _preferences = preferences,
      super(const LocaleState());

  /// Loads saved locale from SharedPreferences or defaults to English.
  Future<void> loadPreference() async {
    try {
      final storedCode = _preferences.getString(preferenceKey);
      if (storedCode != null &&
          supportedLocales.any((l) => l.languageCode == storedCode)) {
        emit(LocaleState(locale: Locale(storedCode), isLoaded: true));
        return;
      }

      // Default to English if no stored preference
      emit(const LocaleState(locale: Locale('en'), isLoaded: true));
    } catch (error) {
      emit(
        LocaleState(
          locale: const Locale('en'),
          isLoaded: true,
          error: 'Could not load language preference: $error',
        ),
      );
    }
  }

  /// Sets and persists the selected locale.
  Future<bool> setLocale(Locale locale) async {
    final languageCode = locale.languageCode;
    if (!supportedLocales.any((l) => l.languageCode == languageCode)) {
      emit(state.copyWith(error: 'Unsupported language: $languageCode'));
      return false;
    }

    try {
      final saved = await _preferences.setString(preferenceKey, languageCode);
      if (!saved) {
        emit(state.copyWith(error: 'Failed to persist language preference.'));
        return false;
      }
      emit(LocaleState(locale: Locale(languageCode), isLoaded: true));
      return true;
    } catch (error) {
      emit(state.copyWith(error: 'Failed to persist language preference: $error'));
      return false;
    }
  }

  /// Toggles between English and Arabic.
  Future<bool> toggleLocale() async {
    final newLocale = state.isArabic ? const Locale('en') : const Locale('ar');
    return setLocale(newLocale);
  }
}

