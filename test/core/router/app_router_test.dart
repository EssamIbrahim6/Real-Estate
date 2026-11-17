import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_app/core/router/app_router.dart';
import 'package:real_estate_app/features/splash/screens/splash_screen.dart';

void main() {
  testWidgets('the root route opens the startup splash screen', (tester) async {
    await tester.pumpWidget(MaterialApp.router(routerConfig: AppRouter.router));
    await tester.pump();

    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.text('Page Not Found'), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
    AppRouter.router.dispose();
  });
}
