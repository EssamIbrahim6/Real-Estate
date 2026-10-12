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

  factory AgentModel.fromFirestore(
    DocumentSnapshot doc, {
    Map<String, dynamic>? userProfile,
  }) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return AgentModel.fromMap(data, doc.id, userProfile: userProfile);
  }

  factory AgentModel.fromMap(
    Map<String, dynamic> map,
    String id, {
    Map<String, dynamic>? userProfile,
  }) {
    final rawName =
        _firstNonEmptyString(map, ['name', 'displayName', 'fullName']) ??
        _firstNonEmptyString(userProfile ?? const {}, [
          'name',
          'displayName',
          'fullName',
        ]) ??
        '';
    final rawAgencyName = _firstNonEmptyString(map, ['agencyName']) ?? '';
    final rawPhoto =
        _firstNonEmptyString(map, [
          'photoUrl',
          'profileImageUrl',
          'primaryPhotoUrl',
          'photo',
        ]) ??
        _firstNonEmptyString(userProfile ?? const {}, [
          'photoUrl',
          'profileImageUrl',
          'primaryPhotoUrl',
          'photo',
        ]) ??
        '';
    final rawBio =
        (map['bio'] as String?) ?? (map['description'] as String?) ?? '';

    return AgentModel(
      id: id,
      userId:
          (map['userId'] as String?) ??
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
      estatesCount:
          (map['estatesCount'] as num?)?.toInt() ??
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

  static String? _firstNonEmptyString(
    Map<String, dynamic> map,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = map[key];
      if (value is String && value.trim().isNotEmpty) return value;
    }
    return null;
  }
}
