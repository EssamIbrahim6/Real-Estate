import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_app/core/theme/app_theme.dart';
import 'package:real_estate_app/features/estate_details/presentation/widgets/submit_review_bottom_sheet.dart';
import 'package:real_estate_app/l10n/generated/app_localizations.dart';

void main() {
  for (final (name, theme) in [
    ('light', AppTheme.lightTheme),
    ('dark', AppTheme.darkTheme),
  ]) {
    testWidgets('review form is readable in $name theme', (tester) async {
      tester.view.physicalSize = const Size(420, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, child) => MaterialApp(
            theme: theme,
            home: Scaffold(
              body: Builder(
                builder: (context) => TextButton(
                  onPressed: () => showModalBottomSheet<void>(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) =>
                        SubmitReviewBottomSheet(onSubmit: (_, _) async => true),
                  ),
                  child: const Text('Open review'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open review'));
      await tester.pumpAndSettle();

      final colors = theme.colorScheme;
      final title = tester.widget<Text>(find.text('How was your experience?'));
      final comment = tester.widget<TextField>(find.byType(TextField));
      final firstStar = tester.widget<IconButton>(
        find.byKey(const ValueKey<String>('review-star-1')),
      );

      expect(title.style?.color, colors.onSurface);
      expect(comment.style?.color, colors.onSurface);
      expect(firstStar.icon is Icon, isTrue);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('review form labels and rating semantics localize in Arabic', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(420, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (context, child) => MaterialApp(
          locale: const Locale('ar'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) =>
                      SubmitReviewBottomSheet(onSubmit: (_, _) async => true),
                ),
                child: const Text('Open review'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open review'));
    await tester.pumpAndSettle();

    expect(find.text('كيف كانت تجربتك؟'), findsOneWidget);
    expect(find.text('إرسال التقييم'), findsOneWidget);
    expect(find.bySemanticsLabel('التقييم: 5 من 5'), findsOneWidget);
    expect(find.byTooltip('اختر تقييمًا بدرجة 1 من 5'), findsOneWidget);
  });
}
