import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/review_entity.dart';

class ReviewModel extends ReviewEntity {
  const ReviewModel({
    required super.id,
    required super.estateId,
    required super.userId,
    required super.userName,
    super.userProfileImage,
    required super.rating,
    required super.comment,
    required super.createdAt,
    super.updatedAt,
  });

  factory ReviewModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return ReviewModel.fromMap(data, doc.id);
  }

  factory ReviewModel.fromMap(Map<String, dynamic> map, String id) {
    return ReviewModel(
      id: id,
      estateId: map['estateId'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      userName: map['userName'] as String? ?? 'Verified Resident',
      userProfileImage: map['userProfileImage'] as String?,
      rating: (map['rating'] as num?)?.toInt() ?? 5,
      comment: map['comment'] as String? ?? '',
      createdAt: _parseDateTime(map['createdAt']) ?? DateTime.now(),
      updatedAt: _parseDateTime(map['updatedAt']),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'estateId': estateId,
    'userId': userId,
    'userName': userName,
    'userProfileImage': userProfileImage,
    'rating': rating,
    'comment': comment,
    'createdAt': Timestamp.fromDate(createdAt),
    if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
  };

  static DateTime? _parseDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}
