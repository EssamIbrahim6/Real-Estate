import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_app/core/utils/typedefs.dart';
import 'package:real_estate_app/features/booking/domain/entities/booking_entity.dart';
import 'package:real_estate_app/features/booking/domain/entities/booking_status.dart';
import 'package:real_estate_app/features/booking/domain/repositories/booking_repository.dart';
import 'package:real_estate_app/features/booking/presentation/cubit/booking_history_cubit.dart';

class _FakeBookingStreamRepository implements BookingRepository {
  final StreamController<List<BookingEntity>> _controller =
      StreamController<List<BookingEntity>>.broadcast();

  void emitBookings(List<BookingEntity> bookings) {
    _controller.add(bookings);
  }

  void emitError(Object error) {
    _controller.addError(error);
  }

  @override
  Stream<List<BookingEntity>> watchCustomerBookings(String customerId) {
    return _controller.stream;
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
  }) => throw UnimplementedError();

  @override
  ResultVoid cancelBooking({
    required String bookingId,
    required String requesterId,
  }) => throw UnimplementedError();

  @override
  ResultFuture<bool> checkDuplicateBooking({
    required String estateId,
    required String customerId,
    required DateTime bookingDate,
    required String timeSlot,
  }) => throw UnimplementedError();

  @override
  ResultFuture<BookingEntity> getBooking(String bookingId) =>
      throw UnimplementedError();
}

void main() {
  late _FakeBookingStreamRepository repository;
  late BookingHistoryCubit cubit;

  final sampleBooking = BookingEntity(
    id: 'b-1',
    estateId: 'estate-1',
    estateTitle: 'Luxury Villa',
    estateCoverImage: 'https://example.com/cover.jpg',
    estateAddress: 'Sheikh Zayed, Giza',
    estatePrice: 8500000,
    listingType: 'sale',
    customerId: 'cust-1',
    customerName: 'Karim',
    customerEmail: 'karim@example.com',
    customerPhone: '+201012345678',
    agentId: 'agent-1',
    bookingDate: DateTime(2026, 12, 1),
    timeSlot: '01:00 PM – 02:00 PM',
    status: BookingStatus.confirmed,
  );

  setUp(() {
    repository = _FakeBookingStreamRepository();
    cubit = BookingHistoryCubit(repository: repository);
  });

  tearDown(() {
    cubit.close();
  });

  test('loadBookings starts with loading status and emits loaded on stream event', () async {
    cubit.loadBookings('cust-1');
    expect(cubit.state.status, BookingHistoryStatus.loading);

    repository.emitBookings([sampleBooking]);
    await Future<void>.delayed(Duration.zero);

    expect(cubit.state.status, BookingHistoryStatus.loaded);
    expect(cubit.state.bookings, [sampleBooking]);
  });

  test('loadBookings emits error status on stream error', () async {
    cubit.loadBookings('cust-1');

    repository.emitError('Firestore permission denied');
    await Future<void>.delayed(Duration.zero);

    expect(cubit.state.status, BookingHistoryStatus.error);
    expect(cubit.state.error, contains('Firestore permission denied'));
  });
}

