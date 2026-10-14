import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_app/features/estate_details/presentation/widgets/estate_favorite_button.dart';

void main() {
  testWidgets('shows outlined and filled hearts for each favorite state', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: EstateFavoriteButton(
            isFavorite: false,
            isLoading: false,
            onPressed: null,
          ),
        ),
      ),
    );
    var button = tester.widget<IconButton>(
      find.byKey(const Key('estate-favorite-button')),
    );
    expect((button.icon as Icon).icon, Icons.favorite_border);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: EstateFavoriteButton(
            isFavorite: true,
            isLoading: false,
            onPressed: null,
          ),
        ),
      ),
    );
    button = tester.widget<IconButton>(
      find.byKey(const Key('estate-favorite-button')),
    );
    expect((button.icon as Icon).icon, Icons.favorite);
  });

  testWidgets('disables the heart and shows progress while updating', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: EstateFavoriteButton(
            isFavorite: false,
            isLoading: true,
            onPressed: null,
          ),
        ),
      ),
    );

    final button = tester.widget<IconButton>(
      find.byKey(const Key('estate-favorite-button')),
    );
    expect(button.onPressed, isNull);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
