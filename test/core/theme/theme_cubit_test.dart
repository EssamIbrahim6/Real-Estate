import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_app/core/theme/theme_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('defaults to system and persists a selected theme', () async {
    final preferences = await SharedPreferences.getInstance();
    final cubit = ThemeCubit(preferences: preferences);

    await cubit.loadPreference();
    expect(cubit.state.preference, AppThemePreference.system);
    expect(cubit.state.themeMode, ThemeMode.system);

    expect(await cubit.setPreference(AppThemePreference.dark), isTrue);
    expect(cubit.state.themeMode, ThemeMode.dark);
    await cubit.close();

    final restored = ThemeCubit(preferences: preferences);
    await restored.loadPreference();
    expect(restored.state.preference, AppThemePreference.dark);
    expect(restored.state.themeMode, ThemeMode.dark);
    await restored.close();
  });

  test('ignores unknown stored preference and safely selects system', () async {
    SharedPreferences.setMockInitialValues({'app_theme_preference': 'unknown'});
    final cubit = ThemeCubit(
      preferences: await SharedPreferences.getInstance(),
    );

    await cubit.loadPreference();

    expect(cubit.state.preference, AppThemePreference.system);
    expect(cubit.state.isLoaded, isTrue);
    await cubit.close();
  });
}
