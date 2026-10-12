import 'package:equatable/equatable.dart';

enum RealEstateType { apartment, villa, house, cottage, studio, chalet, office }

enum PaymentPreference { cash, visa, mastercard, paypal }

class LocationData extends Equatable {
  final double latitude;
  final double longitude;
  final String address;

  const LocationData({
    required this.latitude,
    required this.longitude,
    required this.address,
  });

  @override
  List<Object?> get props => [latitude, longitude, address];
}

class UserProfileEntity extends Equatable {
  final String userId;
  final String name;
  final String email;
  final String phone;
  final String? profileImageUrl;
  final LocationData? location;
  final List<RealEstateType> preferredRealEstateTypes;
  final PaymentPreference? paymentMethod;
  final bool accountSetupCompleted;

  const UserProfileEntity({
    required this.userId,
    required this.name,
    required this.email,
    required this.phone,
    this.profileImageUrl,
    this.location,
    this.preferredRealEstateTypes = const [],
    this.paymentMethod,
    this.accountSetupCompleted = false,
  });

  @override
  List<Object?> get props => [
    userId,
    name,
    email,
    phone,
    profileImageUrl,
    location,
    preferredRealEstateTypes,
    paymentMethod,
    accountSetupCompleted,
  ];
}
