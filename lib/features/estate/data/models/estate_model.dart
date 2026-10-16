import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/estate_entity.dart';

class EstateLocationModel extends EstateLocationEntity {
  const EstateLocationModel({
    required super.address,
    required super.city,
    super.addressEn,
    super.addressAr,
    super.cityEn,
    super.cityAr,
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
    final addressEn =
        map['address_en'] as String? ?? map['addressEn'] as String?;
    final addressAr =
        map['address_ar'] as String? ?? map['addressAr'] as String?;
    final cityEn = map['city_en'] as String? ?? map['cityEn'] as String?;
    final cityAr = map['city_ar'] as String? ?? map['cityAr'] as String?;
    final rawAddress = map['address'] as String? ?? '';
    final rawCity = map['city'] as String? ?? '';

    final address = rawAddress.isNotEmpty ? rawAddress : (addressEn ?? '');
    final city = rawCity.isNotEmpty ? rawCity : (cityEn ?? '');

    return EstateLocationModel(
      address: address,
      city: city,
      addressEn: addressEn ?? (rawAddress.isNotEmpty ? rawAddress : null),
      addressAr: addressAr,
      cityEn: cityEn ?? (rawCity.isNotEmpty ? rawCity : null),
      cityAr: cityAr,
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
      geohash: map['geohash'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
    'address': address,
    'city': city,
    if (addressEn != null) 'address_en': addressEn,
    if (addressAr != null) 'address_ar': addressAr,
    if (cityEn != null) 'city_en': cityEn,
    if (cityAr != null) 'city_ar': cityAr,
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
    super.titleEn,
    super.titleAr,
    super.descriptionEn,
    super.descriptionAr,
    required super.price,
    super.pricePeriod,
    required super.listingType,
    required super.categoryId,
    required super.agentId,
    super.ownerId,
    super.userId,
    super.createdBy,
    super.publisherId,
    super.agentUserId,
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
    final titleEn = map['title_en'] as String? ?? map['titleEn'] as String?;
    final titleAr = map['title_ar'] as String? ?? map['titleAr'] as String?;
    final descriptionEn =
        map['description_en'] as String? ?? map['descriptionEn'] as String?;
    final descriptionAr =
        map['description_ar'] as String? ?? map['descriptionAr'] as String?;
    final rawTitle = map['title'] as String? ?? '';
    final rawDescription = map['description'] as String? ?? '';

    final title = rawTitle.isNotEmpty ? rawTitle : (titleEn ?? '');
    final description =
        rawDescription.isNotEmpty ? rawDescription : (descriptionEn ?? '');

    return EstateModel(
      id: id,
      title: title,
      description: description,
      titleEn: titleEn ?? (rawTitle.isNotEmpty ? rawTitle : null),
      titleAr: titleAr,
      descriptionEn:
          descriptionEn ?? (rawDescription.isNotEmpty ? rawDescription : null),
      descriptionAr: descriptionAr,
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      pricePeriod: map['pricePeriod'] as String?,
      listingType: map['listingType'] as String? ?? 'sale',
      categoryId: map['categoryId'] as String? ?? '',
      agentId: map['agentId'] as String? ?? '',
      ownerId: map['ownerId'] as String? ??
          map['createdBy'] as String? ??
          map['publisherId'] as String? ??
          map['userId'] as String?,
      userId: map['userId'] as String? ??
          map['ownerId'] as String? ??
          map['createdBy'] as String? ??
          map['publisherId'] as String?,
      createdBy: map['createdBy'] as String? ??
          map['ownerId'] as String? ??
          map['publisherId'] as String? ??
          map['userId'] as String?,
      publisherId: map['publisherId'] as String? ??
          map['ownerId'] as String? ??
          map['createdBy'] as String? ??
          map['userId'] as String?,
      agentUserId: map['agentUserId'] as String? ?? map['agentUid'] as String?,
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
    if (titleEn != null || title.isNotEmpty) 'title_en': titleEn ?? title,
    if (titleAr != null) 'title_ar': titleAr,
    if (descriptionEn != null || description.isNotEmpty)
      'description_en': descriptionEn ?? description,
    if (descriptionAr != null) 'description_ar': descriptionAr,
    'price': price,
    'pricePeriod': pricePeriod,
    'listingType': listingType,
    'categoryId': categoryId,
    'agentId': agentId,
    if (ownerId != null) 'ownerId': ownerId,
    if (userId != null) 'userId': userId,
    if (createdBy != null) 'createdBy': createdBy,
    if (publisherId != null) 'publisherId': publisherId,
    if (agentUserId != null) 'agentUserId': agentUserId,
    'location': (location is EstateLocationModel)
        ? (location as EstateLocationModel).toMap()
        : {
            'address': location.address,
            'city': location.city,
            if (location.addressEn != null) 'address_en': location.addressEn,
            if (location.addressAr != null) 'address_ar': location.addressAr,
            if (location.cityEn != null) 'city_en': location.cityEn,
            if (location.cityAr != null) 'city_ar': location.cityAr,
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
