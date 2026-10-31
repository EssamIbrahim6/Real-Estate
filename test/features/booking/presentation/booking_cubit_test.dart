import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_app/core/errors/failures.dart';
import 'package:real_estate_app/core/services/notification_service.dart';
import 'package:real_estate_app/core/utils/typedefs.dart';
import 'package:real_estate_app/features/booking/domain/entities/booking_entity.dart';
import 'package:real_estate_app/features/booking/domain/entities/booking_status.dart';
import 'package:real_estate_app/features/booking/domain/repositories/booking_repository.dart';
import 'package:real_estate_app/features/booking/presentation/cubit/booking_cubit.dart';
import 'package:real_estate_app/features/notifications/domain/entities/notification_entity.dart';
import 'package:real_estate_app/features/notifications/domain/entities/notification_type.dart';
import 'package:real_estate_app/features/notifications/domain/repositories/notification_repository.dart';

class _FakeNotificationRepository implements NotificationRepository {
  final List<NotificationEntity> created = [];

  @override
  ResultVoid createNotification(NotificationEntity notification) async {
    created.add(notification);
    return (failure: null, isSuccess: true);
  }

  @override
  Stream<List<NotificationEntity>> watchForUser(String uid) {
    return const Stream.empty();
  }

  @override
  ResultVoid markAsRead(String notificationId) async {
    return (failure: null, isSuccess: true);
  }

  @override
  ResultVoid markAllAsRead(String uid) async {
    return (failure: null, isSuccess: true);
  }

  @override
  Future<int> getUnreadCount(String uid) async {
    return 0;
  }
}

class _FakeBookingRepository implements BookingRepository {
    bool isDuplicate = false;
    Failure? duplicateFailure;
    BookingEntity? createdBooking;
    Failure? createFailure;
    bool cancelSuccess = true;
    Failure? cancelFailure;
    BookingEntity? fetchedBooking;

  @override
  ResultFuture<bool> checkDuplicateBooking({
    required String estateId,
    required String customerId,
    required DateTime bookingDate,
    required String timeSlot,
  }) async {
    if (duplicateFailure != null) {
      return (failure: duplicateFailure, data: null);
    }
    return (failure: null, data: isDuplicate);
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
    if (createFailure != null) {
      return (failure: createFailure, data: null);
    }
    return (failure: null, data: createdBooking);
  }

  @override
  ResultVoid cancelBooking({
    required String bookingId,
    required String requesterId,
  }) async {
    if (cancelFailure != null) {
      return (failure: cancelFailure, isSuccess: false);
    }
    return (failure: null, isSuccess: cancelSuccess);
  }

  @override
  ResultFuture<BookingEntity> getBooking(String bookingId) async {
    if (fetchedBooking != null) {
      return (failure: null, data: fetchedBooking);
    }
    throw UnimplementedError();
  }

  @override
  Stream<List<BookingEntity>> watchCustomerBookings(String customerId) {
    throw UnimplementedError();
  }
}

void main() {
  late _FakeBookingRepository repository;
  late BookingCubit cubit;

  final sampleBooking = BookingEntity(
    id: 'booking-1',
    estateId: 'estate-1',
    estateTitle: 'Cozy Flat',
    estateCoverImage: 'cover.jpg',
    estateAddress: '123 St',
    estatePrice: 1000,
    listingType: 'rent',
    customerId: 'cust-1',
    customerName: 'Customer',
    customerEmail: 'cust@test.com',
    customerPhone: '1234567890',
    agentId: 'agent-1',
    bookingDate: DateTime(2026, 11, 1),
    timeSlot: '10:00 AM - 11:00 AM',
    status: BookingStatus.pending,
  );

  setUp(() {
    repository = _FakeBookingRepository();
    cubit = BookingCubit(repository: repository);
  });

  tearDown(() {
    cubit.close();
  });

  group('BookingCubit - submission', () {
    test('emits [loading, success] when submission is valid', () async {
      repository.createdBooking = sampleBooking;

      final future = cubit.submitBooking(
        estateId: 'estate-1',
        estateTitle: 'Cozy Flat',
        estateTitleEn: null,
        estateTitleAr: null,
        estateCoverImage: 'cover.jpg',
        estateAddress: '123 St',
        estatePrice: 1000,
        estatePricePeriod: null,
        listingType: 'rent',
        customerId: 'cust-1',
        customerName: 'Customer',
        customerEmail: 'cust@test.com',
        customerPhone: '1234567890',
        agentId: 'agent-1',
        agentUserId: null,
        bookingDate: DateTime(2026, 11, 1),
        timeSlot: '10:00 AM - 11:00 AM',
      );

      await future;

      expect(cubit.state.submitStatus, BookingSubmitStatus.success);
      expect(cubit.state.createdBooking, sampleBooking);
      expect(cubit.state.submitError, isNull);
    });

    test('emits [duplicate] when duplicate booking exists', () async {
      repository.isDuplicate = true;

      await cubit.submitBooking(
        estateId: 'estate-1',
        estateTitle: 'Cozy Flat',
        estateTitleEn: null,
        estateTitleAr: null,
        estateCoverImage: 'cover.jpg',
        estateAddress: '123 St',
        estatePrice: 1000,
        estatePricePeriod: null,
        listingType: 'rent',
        customerId: 'cust-1',
        customerName: 'Customer',
        customerEmail: 'cust@test.com',
        customerPhone: '1234567890',
        agentId: 'agent-1',
        agentUserId: null,
        bookingDate: DateTime(2026, 11, 1),
        timeSlot: '10:00 AM - 11:00 AM',
      );

      expect(cubit.state.submitStatus, BookingSubmitStatus.duplicate);
      expect(cubit.state.submitError, isNotNull);
      expect(cubit.state.createdBooking, isNull);
    });

    test('emits [failure] when repository returns a failure', () async {
      repository.createFailure = const ServerFailure(message: 'Server error');

      await cubit.submitBooking(
        estateId: 'estate-1',
        estateTitle: 'Cozy Flat',
        estateTitleEn: null,
        estateTitleAr: null,
        estateCoverImage: 'cover.jpg',
        estateAddress: '123 St',
        estatePrice: 1000,
        estatePricePeriod: null,
        listingType: 'rent',
        customerId: 'cust-1',
        customerName: 'Customer',
        customerEmail: 'cust@test.com',
        customerPhone: '1234567890',
        agentId: 'agent-1',
        agentUserId: null,
        bookingDate: DateTime(2026, 11, 1),
        timeSlot: '10:00 AM - 11:00 AM',
      );

      expect(cubit.state.submitStatus, BookingSubmitStatus.failure);
      expect(cubit.state.submitError, 'Server error');
    });
  });

  group('BookingCubit - cancellation', () {
    test('emits [isCancelling: false, cancelSuccess: true] on successful cancellation', () async {
      await cubit.cancelBooking(
        bookingId: 'b-1',
        requesterId: 'user-1',
        agentUserId: 'agent-1',
        estateTitle: 'Cozy Flat',
      );

      expect(cubit.state.isCancelling, isFalse);
      expect(cubit.state.cancelSuccess, isTrue);
      expect(cubit.state.cancelError, isNull);
    });

    test('emits [cancelError] when cancellation fails', () async {
      repository.cancelFailure = const ServerFailure(message: 'Not permitted');

      await cubit.cancelBooking(bookingId: 'b-1', requesterId: 'user-1');

      expect(cubit.state.isCancelling, isFalse);
      expect(cubit.state.cancelSuccess, isFalse);
      expect(cubit.state.cancelError, 'Not permitted');
    });
  });

  group('BookingCubit - notifications', () {
    late _FakeNotificationRepository notificationRepo;
    late BookingCubit cubitWithNotifications;

    setUp(() {
      notificationRepo = _FakeNotificationRepository();
      cubitWithNotifications = BookingCubit(
        repository: repository,
        notificationService: NotificationService(notificationRepo),
      );
    });

    tearDown(() {
      cubitWithNotifications.close();
    });

    test('submitBooking notifies the agent but NOT the customer', () async {
      final agentBooking = BookingEntity(
        id: 'booking-agent',
        estateId: 'estate-1',
        estateTitle: 'Cozy Flat',
        estateCoverImage: 'cover.jpg',
        estateAddress: '123 St',
        estatePrice: 1000,
        listingType: 'rent',
        customerId: 'cust-1',
        customerName: 'Customer',
        customerEmail: 'cust@test.com',
        customerPhone: '1234567890',
        agentId: 'agent-1',
        agentUserId: 'agent_uid_5',
        bookingDate: DateTime(2026, 11, 1),
        timeSlot: '10:00 AM - 11:00 AM',
        status: BookingStatus.pending,
      );
      repository.createdBooking = agentBooking;

      await cubitWithNotifications.submitBooking(
        estateId: 'estate-1',
        estateTitle: 'Cozy Flat',
        estateTitleEn: null,
        estateTitleAr: null,
        estateCoverImage: 'cover.jpg',
        estateAddress: '123 St',
        estatePrice: 1000,
        estatePricePeriod: null,
        listingType: 'rent',
        customerId: 'cust-1',
        customerName: 'Customer',
        customerEmail: 'cust@test.com',
        customerPhone: '1234567890',
        agentId: 'agent-1',
        agentUserId: 'agent_uid_5',
        bookingDate: DateTime(2026, 11, 1),
        timeSlot: '10:00 AM - 11:00 AM',
      );

      expect(notificationRepo.created.length, 1);
      final item = notificationRepo.created.first;
      expect(item.recipientId, 'agent_uid_5');
      expect(item.type, NotificationType.bookingReceived);
      expect(item.deduplicationKey, 'booking_new_booking-agent');
    });

    test('submitBooking does not notify when agentUserId is empty', () async {
      repository.createdBooking = sampleBooking;

      await cubitWithNotifications.submitBooking(
        estateId: 'estate-1',
        estateTitle: 'Cozy Flat',
        estateTitleEn: null,
        estateTitleAr: null,
        estateCoverImage: 'cover.jpg',
        estateAddress: '123 St',
        estatePrice: 1000,
        estatePricePeriod: null,
        listingType: 'rent',
        customerId: 'cust-1',
        customerName: 'Customer',
        customerEmail: 'cust@test.com',
        customerPhone: '1234567890',
        agentId: 'agent-1',
        agentUserId: null,
        bookingDate: DateTime(2026, 11, 1),
        timeSlot: '10:00 AM - 11:00 AM',
      );

      expect(notificationRepo.created, isEmpty);
    });

    test('cancelBooking notifies the agent, not the cancelling customer', () async {
      await cubitWithNotifications.cancelBooking(
        bookingId: 'b-1',
        requesterId: 'cust-1',
        agentUserId: 'agent_uid_5',
        estateTitle: 'Cozy Flat',
      );

      expect(notificationRepo.created.length, 1);
      final item = notificationRepo.created.first;
      expect(item.recipientId, 'agent_uid_5');
      expect(item.type, NotificationType.bookingStatusChanged);
      expect(item.deduplicationKey, 'booking_status_b-1_cancelled');
    });

    test('cancelBooking suppresses notification when actor is the agent', () async {
      await cubitWithNotifications.cancelBooking(
        bookingId: 'b-1',
        requesterId: 'agent_uid_5',
        agentUserId: 'agent_uid_5',
        estateTitle: 'Cozy Flat',
      );

      expect(notificationRepo.created, isEmpty);
    });

    test('cancelBooking falls back to getBooking when no context is passed', () async {
      final fetched = BookingEntity(
        id: 'b-1',
        estateId: 'estate-1',
        estateTitle: 'Cozy Flat',
        estateCoverImage: 'cover.jpg',
        estateAddress: '123 St',
        estatePrice: 1000,
        listingType: 'rent',
        customerId: 'cust-1',
        customerName: 'Customer',
        customerEmail: 'cust@test.com',
        customerPhone: '1234567890',
        agentId: 'agent-1',
        agentUserId: 'agent_uid_5',
        bookingDate: DateTime(2026, 11, 1),
        timeSlot: '10:00 AM - 11:00 AM',
        status: BookingStatus.pending,
      );
      repository.fetchedBooking = fetched;

      await cubitWithNotifications.cancelBooking(
        bookingId: 'b-1',
        requesterId: 'cust-1',
      );

      expect(notificationRepo.created.length, 1);
      expect(notificationRepo.created.first.recipientId, 'agent_uid_5');
    });
  });
}

