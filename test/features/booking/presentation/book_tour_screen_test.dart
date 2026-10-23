import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_app/core/utils/typedefs.dart';
import 'package:real_estate_app/features/booking/domain/entities/booking_entity.dart';
import 'package:real_estate_app/features/booking/domain/entities/booking_status.dart';
import 'package:real_estate_app/features/booking/domain/repositories/booking_repository.dart';
import 'package:real_estate_app/features/booking/presentation/cubit/booking_cubit.dart';
import 'package:real_estate_app/features/booking/presentation/pages/book_tour_screen.dart';
import 'package:real_estate_app/features/estate/domain/entities/estate_entity.dart';
import 'package:real_estate_app/l10n/generated/app_localizations.dart';

class _FakeBookingRepository implements BookingRepository {
  bool checkDuplicateCalled = false;
  bool createBookingCalled = false;

  @override
  ResultFuture<bool> checkDuplicateBooking({
    required String estateId,
    required String customerId,
    required DateTime bookingDate,
    required String timeSlot,
  }) async {
    checkDuplicateCalled = true;
    return (failure: null, data: false);
  }

  @override
  ResultFuture<BookingEntity> createBooking({
    required String estateId,
    required String estateTitle,
    required String? estateTitleEn,
    required String? estateTitleAr,
    required String estateCoverImage,
    required String estateAddress,
    required double estatePrice,
    required String? estatePricePeriod,
    required String listingType,
    required String customerId,
    required String customerName,
    required String customerEmail,
    required String customerPhone,
    required String agentId,
    required String? agentUserId,
    required DateTime bookingDate,
    required String timeSlot,
    String? notes,
  }) async {
    createBookingCalled = true;
    return (
      failure: null,
      data: BookingEntity(
        id: 'new-b-1',
        estateId: estateId,
        estateTitle: estateTitle,
        estateCoverImage: estateCoverImage,
        estateAddress: estateAddress,
        estatePrice: estatePrice,
        listingType: listingType,
        customerId: customerId,
        customerName: customerName,
        customerEmail: customerEmail,
        customerPhone: customerPhone,
        agentId: agentId,
        bookingDate: bookingDate,
        timeSlot: timeSlot,
        status: BookingStatus.pending,
      ),
    );
  }

  @override
  ResultVoid cancelBooking({
    required String bookingId,
    required String requesterId,
  }) async => (failure: null, isSuccess: true);

  @override
  ResultFuture<BookingEntity> getBooking(String bookingId) async =>
      throw UnimplementedError();

  @override
  Stream<List<BookingEntity>> watchCustomerBookings(String customerId) =>
      throw UnimplementedError();
}

void main() {
  const testEstate = EstateEntity(
    id: 'estate-100',
    title: 'Palm Hills Villa',
    description: 'Beautiful villa with garden',
    price: 12000000,
    listingType: 'sale',
    categoryId: 'villas',
    agentId: 'agent-10',
    location: EstateLocationEntity(
      address: '6th of October City',
      city: 'Giza',
      latitude: 29.98,
      longitude: 30.95,
    ),
    coverImage: '',
    images: [],
    bedrooms: 4,
    bathrooms: 3,
    area: 350,
    isFurnished: false,
    amenities: ['Garden', 'Pool'],
    rating: 4.8,
    reviewCount: 15,
    isFeatured: true,
    isAvailable: true,
    status: 'active',
  );

  const testArgs = BookTourArgs(
    estate: testEstate,
    customerId: 'cust-10',
    customerName: 'Sara Mostafa',
    customerEmail: 'sara@example.com',
    customerPhone: '+201098765432',
  );

  Widget createWidget({required BookingCubit cubit}) {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: BlocProvider<BookingCubit>.value(
        value: cubit,
        child: const BookTourScreen(args: testArgs),
      ),
    );
  }

  testWidgets('renders property snapshot and pre-filled customer details', (
    tester,
  ) async {
    final repo = _FakeBookingRepository();
    final cubit = BookingCubit(repository: repo);
    addTearDown(cubit.close);

    await tester.pumpWidget(createWidget(cubit: cubit));
    await tester.pumpAndSettle();

    expect(find.text('Palm Hills Villa'), findsOneWidget);
    expect(find.text('Sara Mostafa'), findsOneWidget);
    expect(find.text('sara@example.com'), findsOneWidget);
    expect(find.text('+201098765432'), findsOneWidget);
    expect(find.text('Confirm Booking'), findsOneWidget);
  });

  testWidgets('shows warning when submitting without selecting date', (
    tester,
  ) async {
    final repo = _FakeBookingRepository();
    final cubit = BookingCubit(repository: repo);
    addTearDown(cubit.close);

    await tester.pumpWidget(createWidget(cubit: cubit));
    await tester.pumpAndSettle();

    // Tap confirm booking
    await tester.tap(find.text('Confirm Booking'));
    await tester.pump();

    // Date was not picked, so repo createBooking should not be called
    expect(repo.createBookingCalled, isFalse);

    // Let the feedback timer elapse
    await tester.pump(const Duration(seconds: 5));
  });
}
