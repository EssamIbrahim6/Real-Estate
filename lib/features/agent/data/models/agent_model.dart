import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/agent_entity.dart';

class AgentModel extends AgentEntity {
  const AgentModel({
    required super.id,
    required super.userId,
    required super.agencyName,
    required super.bio,
    required super.yearsOfExperience,
    required super.rating,
    required super.reviewCount,
    required super.isVerified,
    super.createdAt,
    super.updatedAt,
  });

  factory AgentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return AgentModel.fromMap(data, doc.id);
  }

  factory AgentModel.fromMap(Map<String, dynamic> map, String id) {
    return AgentModel(
      id: id,
      userId: map['userId'] as String? ?? '',
      agencyName: map['agencyName'] as String? ?? 'Real Estate Agent',
      bio: map['bio'] as String? ?? '',
      yearsOfExperience: (map['yearsOfExperience'] as num?)?.toInt() ?? 0,
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: (map['reviewCount'] as num?)?.toInt() ?? 0,
      isVerified: map['isVerified'] as bool? ?? false,
      createdAt: _parseDateTime(map['createdAt']),
      updatedAt: _parseDateTime(map['updatedAt']),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'userId': userId,
    'agencyName': agencyName,
    'bio': bio,
    'yearsOfExperience': yearsOfExperience,
    'rating': rating,
    'reviewCount': reviewCount,
    'isVerified': isVerified,
    if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
    if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
  };

  static DateTime? _parseDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}
