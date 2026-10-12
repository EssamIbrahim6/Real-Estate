import 'package:equatable/equatable.dart';

class EstateLocationEntity extends Equatable {
  final String address;
  final String city;
  final double latitude;
  final double longitude;
  final String? geohash;

  const EstateLocationEntity({
    required this.address,
    required this.city,
    required this.latitude,
    required this.longitude,
    this.geohash,
  });

  @override
  List<Object?> get props => [address, city, latitude, longitude, geohash];
}

class EstateEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final double price;
  final String? pricePeriod;
  final String listingType;
  final String categoryId;
  final String agentId;
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
    required this.price,
    this.pricePeriod,
    required this.listingType,
    required this.categoryId,
    required this.agentId,
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

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    price,
    pricePeriod,
    listingType,
    categoryId,
    agentId,
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
