import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_app/core/theme/app_theme.dart';
import 'package:real_estate_app/features/notifications/domain/entities/notification_entity.dart';
import 'package:real_estate_app/features/notifications/domain/entities/notification_type.dart';
import 'package:real_estate_app/features/notifications/presentation/widgets/notification_tile.dart';
import 'package:real_estate_app/l10n/generated/app_localizations.dart';

void main() {
  testWidgets('notification tile stays readable in compact Arabic dark mode', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        locale: const Locale('ar'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: Scaffold(
          body: ListView(
            children: [
              NotificationTile(
                notification: NotificationEntity(
                  id: 'notification-1',
                  recipientId: 'user-1',
                  type: NotificationType.bookingStatusChanged,
                  title: 'تم تأكيد موعد زيارة العقار الخاص بك',
                  body: 'تم تأكيد موعد الزيارة. افتح تفاصيل الحجز لمعرفة الوقت والموقع.',
                  createdAt: DateTime.now(),
                  isRead: false,
                ),
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('تم تأكيد موعد زيارة العقار الخاص بك'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
