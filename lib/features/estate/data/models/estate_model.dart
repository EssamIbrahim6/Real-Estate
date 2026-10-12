import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/estate_entity.dart';

class EstateLocationModel extends EstateLocationEntity {
  const EstateLocationModel({
    required super.address,
    required super.city,
    required super.latitude,
    required super.longitude,
    super.geohash,
  });

  factory EstateLocationModel.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return const EstateLocationModel(
        address: '',
        city: '',
        latitude: 0.0,
        longitude: 0.0,
      );
    }
    return EstateLocationModel(
      address: map['address'] as String? ?? '',
      city: map['city'] as String? ?? '',
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
      geohash: map['geohash'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
    'address': address,
    'city': city,
    'latitude': latitude,
    'longitude': longitude,
    if (geohash != null) 'geohash': geohash,
  };
}

class EstateModel extends EstateEntity {
  const EstateModel({
    required super.id,
    required super.title,
    required super.description,
    required super.price,
    super.pricePeriod,
    required super.listingType,
    required super.categoryId,
    required super.agentId,
    required super.location,
    required super.coverImage,
    required super.images,
    super.virtualTourUrl,
    required super.bedrooms,
    required super.bathrooms,
    required super.area,
    required super.isFurnished,
    required super.amenities,
    required super.rating,
    required super.reviewCount,
    required super.isFeatured,
    required super.isAvailable,
    required super.status,
    super.createdAt,
    super.updatedAt,
  });

  factory EstateModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return EstateModel.fromMap(data, doc.id);
  }

  factory EstateModel.fromMap(Map<String, dynamic> map, String id) {
    return EstateModel(
      id: id,
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      pricePeriod: map['pricePeriod'] as String?,
      listingType: map['listingType'] as String? ?? 'sale',
      categoryId: map['categoryId'] as String? ?? '',
      agentId: map['agentId'] as String? ?? '',
      location: EstateLocationModel.fromMap(
        map['location'] as Map<String, dynamic>?,
      ),
      coverImage: map['coverImage'] as String? ?? '',
      images:
          (map['images'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      virtualTourUrl: map['virtualTourUrl'] as String?,
      bedrooms: (map['bedrooms'] as num?)?.toInt() ?? 0,
      bathrooms: (map['bathrooms'] as num?)?.toInt() ?? 0,
      area: (map['area'] as num?)?.toDouble() ?? 0.0,
      isFurnished: map['isFurnished'] as bool? ?? false,
      amenities:
          (map['amenities'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: (map['reviewCount'] as num?)?.toInt() ?? 0,
      isFeatured: map['isFeatured'] as bool? ?? false,
      isAvailable: map['isAvailable'] as bool? ?? true,
      status: map['status'] as String? ?? 'active',
      createdAt: _parseDateTime(map['createdAt']),
      updatedAt: _parseDateTime(map['updatedAt']),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'title': title,
    'description': description,
    'price': price,
    'pricePeriod': pricePeriod,
    'listingType': listingType,
    'categoryId': categoryId,
    'agentId': agentId,
    'location': (location is EstateLocationModel)
        ? (location as EstateLocationModel).toMap()
        : {
            'address': location.address,
            'city': location.city,
            'latitude': location.latitude,
            'longitude': location.longitude,
            'geohash': location.geohash,
          },
    'coverImage': coverImage,
    'images': images,
    'virtualTourUrl': virtualTourUrl,
    'bedrooms': bedrooms,
    'bathrooms': bathrooms,
    'area': area,
    'isFurnished': isFurnished,
    'amenities': amenities,
    'rating': rating,
    'reviewCount': reviewCount,
    'isFeatured': isFeatured,
    'isAvailable': isAvailable,
    'status': status,
    if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
    if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
  };

  static DateTime? _parseDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}
