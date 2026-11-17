import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_app/core/theme/app_theme.dart';
import 'package:real_estate_app/features/booking/domain/entities/booking_entity.dart';
import 'package:real_estate_app/features/booking/domain/entities/booking_status.dart';
import 'package:real_estate_app/features/booking/domain/repositories/booking_repository.dart';
import 'package:real_estate_app/features/booking/presentation/cubit/booking_cubit.dart';
import 'package:real_estate_app/features/booking/presentation/pages/booking_details_screen.dart';
import 'package:real_estate_app/l10n/generated/app_localizations.dart';

void main() {
  testWidgets('booking details fit a compact Arabic dark layout', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final cubit = BookingCubit(repository: _FakeBookingRepository());
    addTearDown(cubit.close);

    await tester.pumpWidget(
      BlocProvider.value(
        value: cubit,
        child: MaterialApp(
          theme: AppTheme.darkTheme,
          locale: const Locale('ar'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: BookingDetailsScreen(booking: _booking()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('منزل عائلي في القاهرة'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

BookingEntity _booking() => BookingEntity(
  id: 'booking-1',
  estateId: 'estate-1',
  estateTitle: 'Cairo family home',
  estateTitleEn: 'Cairo family home',
  estateTitleAr: 'منزل عائلي في القاهرة',
  estateCoverImage: '',
  estateAddress: 'شارع طويل، التجمع الخامس، القاهرة',
  estatePrice: 2500000,
  estatePricePeriod: null,
  listingType: 'sale',
  customerId: 'customer-1',
  customerName: 'Customer',
  customerEmail: 'customer@example.com',
  customerPhone: '+201000000000',
  agentId: 'agent-1',
  bookingDate: DateTime(2026, 11, 12),
  timeSlot: '10:00 AM - 12:00 PM',
  status: BookingStatus.pending,
);

class _FakeBookingRepository implements BookingRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
