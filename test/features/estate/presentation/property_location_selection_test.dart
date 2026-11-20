import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:real_estate_app/features/estate/domain/entities/property_location_selection.dart';
import 'package:real_estate_app/features/estate/presentation/pages/property_location_picker_screen.dart';

void main() {
  test('accepts finite coordinates within latitude and longitude bounds', () {
    expect(
      const PropertyLocationSelection(
        latitude: 30.0444,
        longitude: 31.2357,
      ).isValid,
      isTrue,
    );
    expect(
      const PropertyLocationSelection(latitude: 90, longitude: 180).isValid,
      isTrue,
    );
  });

  test(
    'rejects invalid bounds, non-finite values, and the empty map origin',
    () {
      expect(
        const PropertyLocationSelection(latitude: 91, longitude: 0).isValid,
        isFalse,
      );
      expect(
        const PropertyLocationSelection(
          latitude: 30,
          longitude: double.infinity,
        ).isValid,
        isFalse,
      );
      expect(
        const PropertyLocationSelection(latitude: 0, longitude: 0).isValid,
        isFalse,
      );
    },
  );

  testWidgets('map selection is explicit and returns selected coordinates', (
    tester,
  ) async {
    PropertyLocationSelection? result;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              key: const ValueKey('open-location-picker'),
              onPressed: () async {
                result = await Navigator.of(context).push(
                  MaterialPageRoute<PropertyLocationSelection>(
                    builder: (_) => PropertyLocationPickerScreen(
                      resolveSelection: (point) async =>
                          PropertyLocationSelection(
                            latitude: point.latitude,
                            longitude: point.longitude,
                          ),
                    ),
                  ),
                );
              },
              child: const Text('Open picker'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('open-location-picker')));
    await tester.pumpAndSettle();
    final confirmButton = tester.widget<FilledButton>(
      find.byKey(const ValueKey('confirm-property-location')),
    );
    expect(confirmButton.onPressed, isNull);

    await tester.drag(find.byType(FlutterMap), const Offset(100, 80));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Select map center'));
    await tester.pumpAndSettle();
    final selectedConfirmButton = tester.widget<FilledButton>(
      find.byKey(const ValueKey('confirm-property-location')),
    );
    expect(selectedConfirmButton.onPressed, isNotNull);

    await tester.tap(find.byKey(const ValueKey('confirm-property-location')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump();
    expect(find.byType(PropertyLocationPickerScreen), findsNothing);
    expect(result, isNotNull);
    expect(result!.isValid, isTrue);
    expect(result!.latitude, isNot(0));
    expect(result!.longitude, isNot(0));
  });
}
