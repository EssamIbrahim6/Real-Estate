import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/user_profile_entity.dart';

class LocationDataModel extends LocationData {
  const LocationDataModel({
    required super.latitude,
    required super.longitude,
    required super.address,
  });

  factory LocationDataModel.fromMap(Map<String, dynamic> map) {
    return LocationDataModel(
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      address: map['address'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
    'latitude': latitude,
    'longitude': longitude,
    'address': address,
  };
}

class UserProfileModel extends UserProfileEntity {
  const UserProfileModel({
    required super.userId,
    required super.name,
    required super.email,
    required super.phone,
    super.profileImageUrl,
    super.location,
    super.preferredRealEstateTypes,
    super.paymentMethod,
    super.accountSetupCompleted,
  });

  factory UserProfileModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return UserProfileModel(
      userId: doc.id,
      name: data['name'] as String? ?? '',
      email: data['email'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      profileImageUrl: data['profileImageUrl'] as String?,
      location: data['location'] != null
          ? LocationDataModel.fromMap(data['location'] as Map<String, dynamic>)
          : null,
      preferredRealEstateTypes:
          ((data['preferredRealEstateTypes'] as List<dynamic>?) ?? [])
              .map(
                (e) => RealEstateType.values.firstWhere(
                  (t) => t.name == e,
                  orElse: () => RealEstateType.apartment,
                ),
              )
              .toList(),
      paymentMethod: data['paymentMethod'] != null
          ? PaymentPreference.values.firstWhere(
              (p) => p.name == data['paymentMethod'],
              orElse: () => PaymentPreference.cash,
            )
          : null,
      accountSetupCompleted: data['accountSetupCompleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toFirestore() => {
    'userId': userId,
    'name': name,
    'email': email,
    'phone': phone,
    'profileImageUrl': profileImageUrl,
    'location': location != null
        ? LocationDataModel(
            latitude: location!.latitude,
            longitude: location!.longitude,
            address: location!.address,
          ).toMap()
        : null,
    'preferredRealEstateTypes': preferredRealEstateTypes
        .map((e) => e.name)
        .toList(),
    'paymentMethod': paymentMethod?.name,
    'accountSetupCompleted': accountSetupCompleted,
    'updatedAt': FieldValue.serverTimestamp(),
  };

  static UserProfileModel fromEntity(UserProfileEntity entity) {
    return UserProfileModel(
      userId: entity.userId,
      name: entity.name,
      email: entity.email,
      phone: entity.phone,
      profileImageUrl: entity.profileImageUrl,
      location: entity.location,
      preferredRealEstateTypes: entity.preferredRealEstateTypes,
      paymentMethod: entity.paymentMethod,
      accountSetupCompleted: entity.accountSetupCompleted,
    );
  }
}
