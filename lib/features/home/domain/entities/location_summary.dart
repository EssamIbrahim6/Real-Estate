import 'package:equatable/equatable.dart';

class LocationSummary extends Equatable {
  final String city;
  final int estateCount;
  final String? representativeImageUrl;

  const LocationSummary({
    required this.city,
    required this.estateCount,
    this.representativeImageUrl,
  });

  @override
  List<Object?> get props => [city, estateCount, representativeImageUrl];
}
