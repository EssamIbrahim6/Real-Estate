import 'package:equatable/equatable.dart';

class AgentEntity extends Equatable {
  final String id;
  final String userId;
  final String agencyName;
  final String name;
  final String phone;
  final String email;
  final String photoUrl;
  final String bio;
  final int yearsOfExperience;
  final double rating;
  final int reviewCount;
  final int estatesCount;
  final bool isVerified;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const AgentEntity({
    required this.id,
    required this.userId,
    required this.agencyName,
    this.name = '',
    this.phone = '',
    this.email = '',
    this.photoUrl = '',
    required this.bio,
    required this.yearsOfExperience,
    required this.rating,
    required this.reviewCount,
    this.estatesCount = 0,
    required this.isVerified,
    this.createdAt,
    this.updatedAt,
  });

  String get displayName {
    final candidate = name.trim();
    if (candidate.isNotEmpty) return candidate;
    final agencyCandidate = agencyName.trim();
    if (agencyCandidate.isNotEmpty) return agencyCandidate;
    return 'Real Estate Agent';
  }

  String get primaryPhotoUrl => photoUrl.trim();

  @override
  List<Object?> get props => [
    id,
    userId,
    agencyName,
    name,
    phone,
    email,
    photoUrl,
    bio,
    yearsOfExperience,
    rating,
    reviewCount,
    estatesCount,
    isVerified,
    createdAt,
    updatedAt,
  ];
}
