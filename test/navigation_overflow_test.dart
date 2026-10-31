import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_app/core/navigation/main_navigation_shell.dart';
import 'package:real_estate_app/core/theme/app_theme.dart';
import 'package:real_estate_app/l10n/generated/app_localizations.dart';

void main() {
  group('MainNavigationShell overflow & layout regression tests', () {
    final testSizes = [
      const Size(320, 568), // iPhone SE 1st gen
      const Size(360, 640), // Standard Android small
      const Size(360, 800), // Android modern small
      const Size(375, 667), // iPhone 8
      const Size(375, 812), // iPhone X/11/12/13 mini
      const Size(390, 844), // iPhone 12/13/14
      const Size(412, 915), // Pixel 7
      const Size(414, 896), // iPhone 11 Pro Max
    ];

    final locales = [
      const Locale('en'),
      const Locale('ar'),
    ];

    final themes = [
      AppTheme.lightTheme,
      AppTheme.darkTheme,
    ];

    for (final theme in themes) {
      final themeName = theme.brightness == Brightness.dark ? 'Dark' : 'Light';
      for (final locale in locales) {
        testWidgets('No layout overflow on $themeName / ${locale.languageCode}', (tester) async {
          FlutterErrorDetails? error;
          final originalOnError = FlutterError.onError;
          FlutterError.onError = (details) {
            error = details;
            originalOnError?.call(details);
          };

          for (final size in testSizes) {
            tester.view.physicalSize = Size(size.width * 2, size.height * 2);
            tester.view.devicePixelRatio = 2.0;
            addTearDown(tester.view.resetPhysicalSize);
            addTearDown(tester.view.resetDevicePixelRatio);

            for (int tab = 0; tab < 4; tab++) {
              error = null;
              final router = GoRouter(
                initialLocation: '/tab$tab',
                routes: [
                  StatefulShellRoute.indexedStack(
                    builder: (context, state, navigationShell) =>
                        MainNavigationShell(navigationShell: navigationShell),
                    branches: [
                      StatefulShellBranch(routes: [GoRoute(path: '/tab0', builder: (_, _) => const Scaffold(body: Text('Home')))]),
                      StatefulShellBranch(routes: [GoRoute(path: '/tab1', builder: (_, _) => const Scaffold(body: Text('Search')))]),
                      StatefulShellBranch(routes: [GoRoute(path: '/tab2', builder: (_, _) => const Scaffold(body: Text('Chat')))]),
                      StatefulShellBranch(routes: [GoRoute(path: '/tab3', builder: (_, _) => const Scaffold(body: Text('Profile')))]),
                    ],
                  ),
                ],
              );

              await tester.pumpWidget(
                MaterialApp.router(
                  theme: theme,
                  locale: locale,
                  localizationsDelegates: AppLocalizations.localizationsDelegates,
                  supportedLocales: AppLocalizations.supportedLocales,
                  routerConfig: router,
                ),
              );

              // Animate through tab switch
              for (int i = 0; i < 10; i++) {
                await tester.pump(const Duration(milliseconds: 25));
                expect(error, isNull, reason: 'Overflow during animation tab $tab on $size ($locale, $themeName)');
              }

              await tester.pumpAndSettle();
              expect(error, isNull, reason: 'Overflow settled tab $tab on $size ($locale, $themeName)');

              router.dispose();
            }
          }

          FlutterError.onError = originalOnError;
        });
      }
    }
  });
}
