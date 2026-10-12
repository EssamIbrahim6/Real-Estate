import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_app/core/navigation/main_navigation_shell.dart';

void main() {
  testWidgets('main navigation shell shows Home and switches to Search', (
    WidgetTester tester,
  ) async {
    final router = _createNavigationRouter();
    addTearDown(router.dispose);

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    expect(find.text('Home tab'), findsOneWidget);
    expect(find.byIcon(Icons.home_rounded), findsWidgets);
    expect(find.byIcon(Icons.search_rounded), findsWidgets);
    expect(find.byIcon(Icons.chat_bubble_rounded), findsWidgets);
    expect(find.byIcon(Icons.person_rounded), findsWidgets);

    await tester.tap(find.byIcon(Icons.search_rounded).first);
    await tester.pumpAndSettle();

    expect(find.text('Search tab'), findsOneWidget);
    expect(find.text('Home tab'), findsNothing);
  });
}

GoRouter _createNavigationRouter() => GoRouter(
  initialLocation: '/home',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          MainNavigationShell(navigationShell: navigationShell),
      branches: [
        _branch('/home', 'Home tab'),
        _branch('/search', 'Search tab'),
        _branch('/chat', 'Chat tab'),
        _branch('/profile', 'Profile tab'),
      ],
    ),
  ],
);

StatefulShellBranch _branch(String path, String label) => StatefulShellBranch(
  routes: [
    GoRoute(
      path: path,
      builder: (context, state) => Center(child: Text(label)),
    ),
  ],
);
