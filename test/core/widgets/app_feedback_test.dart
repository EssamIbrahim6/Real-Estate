import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_app/core/widgets/app_feedback.dart';

void main() {
  testWidgets('shows one themed live notification and replaces duplicates', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Column(
              children: [
                ElevatedButton(
                  onPressed: () => AppFeedback.error(
                    context,
                    'Could not save your changes.',
                  ),
                  child: const Text('Show error'),
                ),
                ElevatedButton(
                  onPressed: () => AppFeedback.success(context, 'Saved'),
                  child: const Text('Show success'),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Show error'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('Could not save your changes.'), findsOneWidget);
    expect(
      find.bySemanticsLabel('Could not save your changes.'),
      findsOneWidget,
    );
    expect(find.byType(Semantics), findsWidgets);

    await tester.tap(find.text('Show success'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('Could not save your changes.'), findsNothing);
    expect(find.text('Saved'), findsOneWidget);

    await tester.pump(const Duration(seconds: 4));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('Saved'), findsNothing);
  });
}
