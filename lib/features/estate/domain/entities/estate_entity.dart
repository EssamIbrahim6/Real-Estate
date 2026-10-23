import 'package:equatable/equatable.dart';

class EstateLocationEntity extends Equatable {
  final String address;
  final String city;
  final String? addressEn;
  final String? addressAr;
  final String? cityEn;
  final String? cityAr;
  final double latitude;
  final double longitude;
  final String? geohash;

  const EstateLocationEntity({
    required this.address,
    required this.city,
    this.addressEn,
    this.addressAr,
    this.cityEn,
    this.cityAr,
    required this.latitude,
    required this.longitude,
    this.geohash,
  });

  /// Returns localized address based on language code ('ar' or 'en'),
  /// falling back gracefully to English or base address.
  String localizedAddress([String? langCode]) {
    if (langCode == 'ar') {
      if (addressAr != null && addressAr!.trim().isNotEmpty) {
        return addressAr!.trim();
      }
    } else if (langCode == 'en') {
      if (addressEn != null && addressEn!.trim().isNotEmpty) {
        return addressEn!.trim();
      }
    }
    if (address.isNotEmpty) return address;
    return addressEn ?? addressAr ?? '';
  }

  /// Returns localized city based on language code ('ar' or 'en'),
  /// falling back gracefully to English or base city.
  String localizedCity([String? langCode]) {
    if (langCode == 'ar') {
      if (cityAr != null && cityAr!.trim().isNotEmpty) {
        return cityAr!.trim();
      }
    } else if (langCode == 'en') {
      if (cityEn != null && cityEn!.trim().isNotEmpty) {
        return cityEn!.trim();
      }
    }
    if (city.isNotEmpty) return city;
    return cityEn ?? cityAr ?? '';
  }

  @override
  List<Object?> get props => [
    address,
    city,
    addressEn,
    addressAr,
    cityEn,
    cityAr,
    latitude,
    longitude,
    geohash,
  ];
}

class EstateEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final String? titleEn;
  final String? titleAr;
  final String? descriptionEn;
  final String? descriptionAr;
  final double price;
  final String? pricePeriod;
  final String listingType;
  final String categoryId;
  final String agentId;
  final String? ownerId;
  final String? userId;
  final String? createdBy;
  final String? publisherId;
  final String? agentUserId;
  final EstateLocationEntity location;
  final String coverImage;
  final List<String> images;
  final String? virtualTourUrl;
  final int bedrooms;
  final int bathrooms;
  final double area;
  final bool isFurnished;
  final List<String> amenities;
  final double rating;
  final int reviewCount;
  final bool isFeatured;
  final bool isAvailable;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const EstateEntity({
    required this.id,
    required this.title,
    required this.description,
    this.titleEn,
    this.titleAr,
    this.descriptionEn,
    this.descriptionAr,
    required this.price,
    this.pricePeriod,
    required this.listingType,
    required this.categoryId,
    required this.agentId,
    this.ownerId,
    this.userId,
    this.createdBy,
    this.publisherId,
    this.agentUserId,
    required this.location,
    required this.coverImage,
    required this.images,
    this.virtualTourUrl,
    required this.bedrooms,
    required this.bathrooms,
    required this.area,
    required this.isFurnished,
    required this.amenities,
    required this.rating,
    required this.reviewCount,
    required this.isFeatured,
    required this.isAvailable,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  /// Returns localized title according to [langCode] ('ar' or 'en'),
  /// falling back gracefully to English or base title.
  String localizedTitle([String? langCode]) {
    if (langCode == 'ar') {
      if (titleAr != null && titleAr!.trim().isNotEmpty) {
        return titleAr!.trim();
      }
    } else if (langCode == 'en') {
      if (titleEn != null && titleEn!.trim().isNotEmpty) {
        return titleEn!.trim();
      }
    }
    if (title.isNotEmpty) return title;
    return titleEn ?? titleAr ?? '';
  }

  /// Returns localized description according to [langCode] ('ar' or 'en'),
  /// falling back gracefully to English or base description.
  String localizedDescription([String? langCode]) {
    if (langCode == 'ar') {
      if (descriptionAr != null && descriptionAr!.trim().isNotEmpty) {
        return descriptionAr!.trim();
      }
    } else if (langCode == 'en') {
      if (descriptionEn != null && descriptionEn!.trim().isNotEmpty) {
        return descriptionEn!.trim();
      }
    }
    if (description.isNotEmpty) return description;
    return descriptionEn ?? descriptionAr ?? '';
  }

  String? get primaryOwnerUid {
    final values = [ownerId, userId, createdBy, publisherId, agentUserId];
    for (final value in values) {
      final trimmed = value?.trim();
      if (trimmed != null && trimmed.isNotEmpty) return trimmed;
    }
    return null;
  }

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    titleEn,
    titleAr,
    descriptionEn,
    descriptionAr,
    price,
    pricePeriod,
    listingType,
    categoryId,
    agentId,
    ownerId,
    userId,
    createdBy,
    publisherId,
    agentUserId,
    location,
    coverImage,
    images,
    virtualTourUrl,
    bedrooms,
    bathrooms,
    area,
    isFurnished,
    amenities,
    rating,
    reviewCount,
    isFeatured,
    isAvailable,
    status,
    createdAt,
    updatedAt,
  ];
}
