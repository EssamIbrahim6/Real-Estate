import '../../../../core/utils/typedefs.dart';
import '../entities/booking_entity.dart';

abstract class BookingRepository {
  /// Submits a new booking. Returns the created [BookingEntity] on success.
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
  });

  /// Returns a stream of bookings for the given customer UID.
  Stream<List<BookingEntity>> watchCustomerBookings(String customerId);

  /// Returns a single booking by ID.
  ResultFuture<BookingEntity> getBooking(String bookingId);

  /// Cancels an existing booking (status → cancelled).
  ResultVoid cancelBooking({
    required String bookingId,
    required String requesterId,
  });

  /// Checks whether a duplicate booking already exists for the deterministic
  /// document ID `{estateId}_{customerId}_{date}`. Returns true if already
  /// booked.
  ResultFuture<bool> checkDuplicateBooking({
    required String estateId,
    required String customerId,
    required DateTime bookingDate,
    required String timeSlot,
  });
}

