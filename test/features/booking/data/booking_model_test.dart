import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_app/features/booking/data/models/booking_model.dart';
import 'package:real_estate_app/features/booking/domain/entities/booking_status.dart';

void main() {
  final testDate = DateTime(2026, 12, 1, 10, 0);

  final testModel = BookingModel(
    id: 'test-booking-id',
    estateId: 'estate-123',
    estateTitle: 'Modern Villa',
    estateTitleEn: 'Modern Villa En',
    estateTitleAr: 'فيلا حديثة',
    estateCoverImage: 'https://example.com/cover.jpg',
    estateAddress: '123 Nile St, Cairo',
    estatePrice: 5000000,
    estatePricePeriod: 'total',
    listingType: 'sale',
    customerId: 'user-456',
    customerName: 'Ahmed Ali',
    customerEmail: 'ahmed@example.com',
    customerPhone: '+201001234567',
    agentId: 'agent-789',
    agentUserId: 'agent-user-001',
    bookingDate: testDate,
    timeSlot: '10:00 AM – 11:00 AM',
    notes: 'Please call before arrival.',
    status: BookingStatus.pending,
  );

  group('BookingStatus', () {
    test('fromString parses all known statuses correctly', () {
      expect(BookingStatus.fromString('pending'), BookingStatus.pending);
      expect(BookingStatus.fromString('confirmed'), BookingStatus.confirmed);
      expect(BookingStatus.fromString('cancelled'), BookingStatus.cancelled);
      expect(BookingStatus.fromString('completed'), BookingStatus.completed);
      expect(BookingStatus.fromString('unknown'), BookingStatus.pending);
      expect(BookingStatus.fromString(null), BookingStatus.pending);
    });

    test('toJson converts statuses to strings correctly', () {
      expect(BookingStatus.pending.toJson(), 'pending');
      expect(BookingStatus.confirmed.toJson(), 'confirmed');
      expect(BookingStatus.cancelled.toJson(), 'cancelled');
      expect(BookingStatus.completed.toJson(), 'completed');
    });

    test('isCancellable returns true only for pending and confirmed', () {
      expect(BookingStatus.pending.isCancellable, isTrue);
      expect(BookingStatus.confirmed.isCancellable, isTrue);
      expect(BookingStatus.cancelled.isCancellable, isFalse);
      expect(BookingStatus.completed.isCancellable, isFalse);
    });
  });

  group('BookingModel', () {
    test('toFirestore serializes fields properly', () {
      final map = testModel.toFirestore();

      expect(map['estateId'], 'estate-123');
      expect(map['estateTitle'], 'Modern Villa');
      expect(map['estateTitleEn'], 'Modern Villa En');
      expect(map['estateTitleAr'], 'فيلا حديثة');
      expect(map['estateCoverImage'], 'https://example.com/cover.jpg');
      expect(map['estateAddress'], '123 Nile St, Cairo');
      expect(map['estatePrice'], 5000000.0);
      expect(map['estatePricePeriod'], 'total');
      expect(map['listingType'], 'sale');
      expect(map['customerId'], 'user-456');
      expect(map['customerName'], 'Ahmed Ali');
      expect(map['customerEmail'], 'ahmed@example.com');
      expect(map['customerPhone'], '+201001234567');
      expect(map['agentId'], 'agent-789');
      expect(map['agentUserId'], 'agent-user-001');
      expect(map['bookingDate'], isA<Timestamp>());
      expect(map['timeSlot'], '10:00 AM – 11:00 AM');
      expect(map['notes'], 'Please call before arrival.');
      expect(map['status'], 'pending');
      expect(map['createdAt'], isA<FieldValue>());
      expect(map['updatedAt'], isA<FieldValue>());
    });

    test('statusUpdatePayload creates correct status update map', () {
      final payload = BookingModel.statusUpdatePayload(BookingStatus.cancelled);
      expect(payload['status'], 'cancelled');
      expect(payload['updatedAt'], isA<FieldValue>());
    });

    test('buildDeterministicId constructs expected unique key', () {
      final docId = BookingModel.buildDeterministicId(
        estateId: 'estate-123',
        customerId: 'user-456',
        bookingDate: DateTime(2026, 10, 25),
        timeSlot: '10:00 AM - 11:00 AM',
      );
      expect(docId, 'estate-123_user-456_20261025_1000AM1100AM');
    });

    test('localizedEstateTitle resolves localized titles with fallback', () {
      expect(testModel.localizedEstateTitle('ar'), 'فيلا حديثة');
      expect(testModel.localizedEstateTitle('en'), 'Modern Villa En');
      expect(testModel.localizedEstateTitle('fr'), 'Modern Villa');
    });
  });
}

