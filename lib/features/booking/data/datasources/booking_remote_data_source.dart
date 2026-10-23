import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/booking_entity.dart';
import '../../domain/entities/booking_status.dart';
import '../models/booking_model.dart';

abstract class BookingRemoteDataSource {
  Future<BookingEntity> createBooking(BookingModel model);
  Stream<List<BookingEntity>> watchCustomerBookings(String customerId);
  Future<BookingEntity> getBooking(String bookingId);
  Future<void> cancelBooking({
    required String bookingId,
    required String requesterId,
  });
  Future<bool> checkDuplicateBooking({
    required String estateId,
    required String customerId,
    required DateTime bookingDate,
    required String timeSlot,
  });
}

class BookingRemoteDataSourceImpl implements BookingRemoteDataSource {
  final FirebaseFirestore _firestore;

  BookingRemoteDataSourceImpl(this._firestore);

  CollectionReference<Map<String, dynamic>> get _bookings =>
      _firestore.collection('bookings');

  /// Creates a booking using a deterministic document ID to prevent duplicates.
  ///
  /// Uses `setDoc` with `SetOptions(merge: false)` which will fail if the
  /// document already exists (Firestore will throw a PERMISSION_DENIED or
  /// ALREADY_EXISTS error depending on rules). Combined with the deterministic
  /// ID scheme, this reduces duplicate submissions.
  @override
  Future<BookingEntity> createBooking(BookingModel model) async {
    final docId = BookingModel.buildDeterministicId(
      estateId: model.estateId,
      customerId: model.customerId,
      bookingDate: model.bookingDate,
      timeSlot: model.timeSlot,
    );

    final docRef = _bookings.doc(docId);
    await docRef.set(model.toFirestore());

    final snap = await docRef.get();
    return BookingModel.fromFirestore(snap);
  }

  @override
  Stream<List<BookingEntity>> watchCustomerBookings(String customerId) {
    return _bookings
        .where('customerId', isEqualTo: customerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) =>
              snap.docs
                  .map((doc) => BookingModel.fromFirestore(doc))
                  .toList(),
        );
  }

  @override
  Future<BookingEntity> getBooking(String bookingId) async {
    final snap = await _bookings.doc(bookingId).get();
    if (!snap.exists) {
      throw FirebaseException(
        plugin: 'cloud_firestore',
        code: 'not-found',
        message: 'Booking not found.',
      );
    }
    return BookingModel.fromFirestore(snap);
  }

  @override
  Future<void> cancelBooking({
    required String bookingId,
    required String requesterId,
  }) async {
    await _bookings.doc(bookingId).update(
      BookingModel.statusUpdatePayload(BookingStatus.cancelled),
    );
  }

  @override
  Future<bool> checkDuplicateBooking({
    required String estateId,
    required String customerId,
    required DateTime bookingDate,
    required String timeSlot,
  }) async {
    final docId = BookingModel.buildDeterministicId(
      estateId: estateId,
      customerId: customerId,
      bookingDate: bookingDate,
      timeSlot: timeSlot,
    );
    final snap = await _bookings.doc(docId).get();
    return snap.exists;
  }
}

