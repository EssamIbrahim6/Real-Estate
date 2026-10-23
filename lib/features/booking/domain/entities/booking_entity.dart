import 'package:equatable/equatable.dart';
import 'booking_status.dart';

class BookingEntity extends Equatable {
  final String id;
  final String estateId;
  final String? estateTitleEn;
  final String? estateTitleAr;
  final String estateTitle;
  final String estateCoverImage;
  final String estateAddress;
  final double estatePrice;
  final String? estatePricePeriod;
  final String listingType;

  final String customerId;
  final String customerName;
  final String customerEmail;
  final String customerPhone;

  final String agentId;
  final String? agentUserId;

  final DateTime bookingDate;
  final String timeSlot;
  final String? notes;

  final BookingStatus status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const BookingEntity({
    required this.id,
    required this.estateId,
    this.estateTitleEn,
    this.estateTitleAr,
    required this.estateTitle,
    required this.estateCoverImage,
    required this.estateAddress,
    required this.estatePrice,
    this.estatePricePeriod,
    required this.listingType,
    required this.customerId,
    required this.customerName,
    required this.customerEmail,
    required this.customerPhone,
    required this.agentId,
    this.agentUserId,
    required this.bookingDate,
    required this.timeSlot,
    this.notes,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  /// Returns the best localized estate title for the given [langCode].
  String localizedEstateTitle([String? langCode]) {
    if (langCode == 'ar' && estateTitleAr != null && estateTitleAr!.isNotEmpty) {
      return estateTitleAr!;
    }
    if (langCode == 'en' && estateTitleEn != null && estateTitleEn!.isNotEmpty) {
      return estateTitleEn!;
    }
    if (estateTitle.isNotEmpty) return estateTitle;
    return estateTitleEn ?? estateTitleAr ?? '';
  }

  @override
  List<Object?> get props => [
    id,
    estateId,
    estateTitleEn,
    estateTitleAr,
    estateTitle,
    estateCoverImage,
    estateAddress,
    estatePrice,
    estatePricePeriod,
    listingType,
    customerId,
    customerName,
    customerEmail,
    customerPhone,
    agentId,
    agentUserId,
    bookingDate,
    timeSlot,
    notes,
    status,
    createdAt,
    updatedAt,
  ];
}

