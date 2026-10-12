import 'package:equatable/equatable.dart';

class AgentEntity extends Equatable {
  final String id;
  final String userId;
  final String agencyName;
  final String bio;
  final int yearsOfExperience;
  final double rating;
  final int reviewCount;
  final bool isVerified;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const AgentEntity({
    required this.id,
    required this.userId,
    required this.agencyName,
    required this.bio,
    required this.yearsOfExperience,
    required this.rating,
    required this.reviewCount,
    required this.isVerified,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    agencyName,
    bio,
    yearsOfExperience,
    rating,
    reviewCount,
    isVerified,
    createdAt,
    updatedAt,
  ];
}
