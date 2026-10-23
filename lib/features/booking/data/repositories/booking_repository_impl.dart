import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/typedefs.dart';
import '../../domain/entities/booking_entity.dart';
import '../../domain/entities/booking_status.dart';
import '../../domain/repositories/booking_repository.dart';
import '../datasources/booking_remote_data_source.dart';
import '../models/booking_model.dart';

class BookingRepositoryImpl implements BookingRepository {
  final BookingRemoteDataSource _dataSource;

  BookingRepositoryImpl(this._dataSource);

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
    try {
      final model = BookingModel(
        id: '',
        estateId: estateId,
        estateTitleEn: estateTitleEn,
        estateTitleAr: estateTitleAr,
        estateTitle: estateTitle,
        estateCoverImage: estateCoverImage,
        estateAddress: estateAddress,
        estatePrice: estatePrice,
        estatePricePeriod: estatePricePeriod,
        listingType: listingType,
        customerId: customerId,
        customerName: customerName,
        customerEmail: customerEmail,
        customerPhone: customerPhone,
        agentId: agentId,
        agentUserId: agentUserId,
        bookingDate: bookingDate,
        timeSlot: timeSlot,
        notes: notes,
        status: BookingStatus.pending,
      );
      final result = await _dataSource.createBooking(model);
      return (failure: null, data: result);
    } on FirebaseException catch (e) {
      return (failure: ServerFailure(message: e.message ?? 'Booking failed.'), data: null);
    } catch (e) {
      return (failure: ServerFailure(message: e.toString()), data: null);
    }
  }

  @override
  Stream<List<BookingEntity>> watchCustomerBookings(String customerId) {
    return _dataSource.watchCustomerBookings(customerId);
  }

  @override
  ResultFuture<BookingEntity> getBooking(String bookingId) async {
    try {
      final result = await _dataSource.getBooking(bookingId);
      return (failure: null, data: result);
    } on FirebaseException catch (e) {
      return (failure: ServerFailure(message: e.message ?? 'Could not load booking.'), data: null);
    } catch (e) {
      return (failure: ServerFailure(message: e.toString()), data: null);
    }
  }

  @override
  ResultVoid cancelBooking({
    required String bookingId,
    required String requesterId,
  }) async {
    try {
      await _dataSource.cancelBooking(
        bookingId: bookingId,
        requesterId: requesterId,
      );
      return (failure: null, isSuccess: true);
    } on FirebaseException catch (e) {
      return (failure: ServerFailure(message: e.message ?? 'Could not cancel booking.'), isSuccess: false);
    } catch (e) {
      return (failure: ServerFailure(message: e.toString()), isSuccess: false);
    }
  }

  @override
  ResultFuture<bool> checkDuplicateBooking({
    required String estateId,
    required String customerId,
    required DateTime bookingDate,
    required String timeSlot,
  }) async {
    try {
      final isDuplicate = await _dataSource.checkDuplicateBooking(
        estateId: estateId,
        customerId: customerId,
        bookingDate: bookingDate,
        timeSlot: timeSlot,
      );
      return (failure: null, data: isDuplicate);
    } on FirebaseException catch (e) {
      return (failure: ServerFailure(message: e.message ?? 'Duplicate check failed.'), data: null);
    } catch (e) {
      return (failure: ServerFailure(message: e.toString()), data: null);
    }
  }
}

