import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_app/core/widgets/person_avatar.dart';

void main() {
  testWidgets('renders a circular placeholder when no profile photo exists', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: PersonAvatar(photoUrl: null, radius: 28, iconSize: 24),
        ),
      ),
    );

    expect(find.byType(CircleAvatar), findsOneWidget);
    expect(find.byType(ClipOval), findsOneWidget);
    expect(find.byIcon(Icons.person), findsOneWidget);
    expect(find.byKey(const Key('person-profile-image')), findsNothing);
  });

  testWidgets('clips a profile photo inside the circular avatar', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: PersonAvatar(
            photoUrl: 'https://example.invalid/profile.png',
            radius: 28,
            iconSize: 24,
          ),
        ),
      ),
    );

    expect(find.byType(CircleAvatar), findsOneWidget);
    expect(find.byType(ClipOval), findsOneWidget);
    expect(find.byKey(const Key('person-profile-image')), findsOneWidget);
  });
}
