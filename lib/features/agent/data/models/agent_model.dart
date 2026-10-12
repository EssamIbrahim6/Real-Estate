import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/agent_entity.dart';

class AgentModel extends AgentEntity {
  const AgentModel({
    required super.id,
    required super.userId,
    required super.agencyName,
    super.name,
    super.phone,
    super.email,
    super.photoUrl,
    required super.bio,
    required super.yearsOfExperience,
    required super.rating,
    required super.reviewCount,
    super.estatesCount,
    required super.isVerified,
    super.createdAt,
    super.updatedAt,
  });

  factory AgentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return AgentModel.fromMap(data, doc.id);
  }

  factory AgentModel.fromMap(Map<String, dynamic> map, String id) {
    final rawName = (map['name'] as String?) ??
        (map['fullName'] as String?) ??
        (map['agencyName'] as String?) ??
        'Real Estate Agent';
    final rawAgencyName = (map['agencyName'] as String?) ?? rawName;
    final rawPhoto = (map['photoUrl'] as String?) ??
        (map['photo'] as String?) ??
        (map['profileImageUrl'] as String?) ??
        '';
    final rawBio = (map['bio'] as String?) ??
        (map['description'] as String?) ??
        '';

    return AgentModel(
      id: id,
      userId: (map['userId'] as String?) ??
          (map['firebaseUserId'] as String?) ??
          '',
      agencyName: rawAgencyName,
      name: rawName,
      phone: (map['phone'] as String?) ?? '',
      email: (map['email'] as String?) ?? '',
      photoUrl: rawPhoto,
      bio: rawBio,
      yearsOfExperience: (map['yearsOfExperience'] as num?)?.toInt() ?? 0,
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: (map['reviewCount'] as num?)?.toInt() ?? 0,
      estatesCount: (map['estatesCount'] as num?)?.toInt() ??
          (map['publishedEstatesCount'] as num?)?.toInt() ??
          0,
      isVerified: map['isVerified'] as bool? ?? false,
      createdAt: _parseDateTime(map['createdAt']),
      updatedAt: _parseDateTime(map['updatedAt']),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'userId': userId,
    'agencyName': agencyName,
    'name': name,
    'phone': phone,
    'email': email,
    'photoUrl': photoUrl,
    'bio': bio,
    'yearsOfExperience': yearsOfExperience,
    'rating': rating,
    'reviewCount': reviewCount,
    'estatesCount': estatesCount,
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
