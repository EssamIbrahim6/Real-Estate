import 'package:equatable/equatable.dart';

class PropertyLocationSelection extends Equatable {
  const PropertyLocationSelection({
    required this.latitude,
    required this.longitude,
    this.address,
    this.city,
    this.addressLookupUnavailable = false,
  });

  final double latitude;
  final double longitude;
  final String? address;
  final String? city;
  final bool addressLookupUnavailable;

  bool get isValid =>
      latitude.isFinite &&
      longitude.isFinite &&
      latitude >= -90 &&
      latitude <= 90 &&
      longitude >= -180 &&
      longitude <= 180 &&
      (latitude != 0 || longitude != 0);

  @override
  List<Object?> get props => [
    latitude,
    longitude,
    address,
    city,
    addressLookupUnavailable,
  ];
}
