import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/booking_entity.dart';
import '../../domain/entities/booking_status.dart';

class BookingModel extends BookingEntity {
  const BookingModel({
    required super.id,
    required super.estateId,
    super.estateTitleEn,
    super.estateTitleAr,
    required super.estateTitle,
    required super.estateCoverImage,
    required super.estateAddress,
    required super.estatePrice,
    super.estatePricePeriod,
    required super.listingType,
    required super.customerId,
    required super.customerName,
    required super.customerEmail,
    required super.customerPhone,
    required super.agentId,
    super.agentUserId,
    required super.bookingDate,
    required super.timeSlot,
    super.notes,
    required super.status,
    super.createdAt,
    super.updatedAt,
  });

  /// Deserializes a Firestore document into a [BookingModel].
  factory BookingModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    DateTime parseTimestamp(dynamic value) {
      if (value is Timestamp) return value.toDate();
      return DateTime.now();
    }

    return BookingModel(
      id: doc.id,
      estateId: (data['estateId'] as String?) ?? '',
      estateTitleEn: data['estateTitleEn'] as String?,
      estateTitleAr: data['estateTitleAr'] as String?,
      estateTitle: (data['estateTitle'] as String?) ?? '',
      estateCoverImage: (data['estateCoverImage'] as String?) ?? '',
      estateAddress: (data['estateAddress'] as String?) ?? '',
      estatePrice: ((data['estatePrice'] as num?) ?? 0).toDouble(),
      estatePricePeriod: data['estatePricePeriod'] as String?,
      listingType: (data['listingType'] as String?) ?? 'sale',
      customerId: (data['customerId'] as String?) ?? '',
      customerName: (data['customerName'] as String?) ?? '',
      customerEmail: (data['customerEmail'] as String?) ?? '',
      customerPhone: (data['customerPhone'] as String?) ?? '',
      agentId: (data['agentId'] as String?) ?? '',
      agentUserId: data['agentUserId'] as String?,
      bookingDate: parseTimestamp(data['bookingDate']),
      timeSlot: (data['timeSlot'] as String?) ?? '',
      notes: data['notes'] as String?,
      status: BookingStatus.fromString(data['status'] as String?),
      createdAt: data['createdAt'] is Timestamp
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
      updatedAt: data['updatedAt'] is Timestamp
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  /// Serializes to a Firestore-compatible map for document creation.
  Map<String, dynamic> toFirestore() {
    return {
      'estateId': estateId,
      'estateTitleEn': estateTitleEn,
      'estateTitleAr': estateTitleAr,
      'estateTitle': estateTitle,
      'estateCoverImage': estateCoverImage,
      'estateAddress': estateAddress,
      'estatePrice': estatePrice,
      'estatePricePeriod': estatePricePeriod,
      'listingType': listingType,
      'customerId': customerId,
      'customerName': customerName,
      'customerEmail': customerEmail,
      'customerPhone': customerPhone,
      'agentId': agentId,
      'agentUserId': agentUserId,
      'bookingDate': Timestamp.fromDate(bookingDate),
      'timeSlot': timeSlot,
      'notes': notes,
      'status': status.toJson(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  /// Serializes to a Firestore-compatible map for status updates only.
  static Map<String, dynamic> statusUpdatePayload(BookingStatus newStatus) {
    return {
      'status': newStatus.toJson(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  /// Builds the deterministic booking document ID used for duplicate prevention.
  ///
  /// Format: `{estateId}_{customerId}_{yyyyMMdd}_{slotKey}`
  ///
  /// **Limitation:** This client-side deterministic ID + Firestore `setDoc`
  /// strategy reduces but does not eliminate race conditions. Two simultaneous
  /// requests with the same key may both pass; Cloud Functions transactions
  /// would be required for a strict guarantee.
  static String buildDeterministicId({
    required String estateId,
    required String customerId,
    required DateTime bookingDate,
    required String timeSlot,
  }) {
    final dateKey =
        '${bookingDate.year}${bookingDate.month.toString().padLeft(2, '0')}${bookingDate.day.toString().padLeft(2, '0')}';
    final slotKey = timeSlot.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
    return '${estateId}_${customerId}_${dateKey}_$slotKey';
  }
}

