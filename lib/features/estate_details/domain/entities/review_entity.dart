import 'package:equatable/equatable.dart';

class ReviewEntity extends Equatable {
  final String id;
  final String estateId;
  final String userId;
  final String userName;
  final String? userProfileImage;
  final int rating;
  final String comment;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const ReviewEntity({
    required this.id,
    required this.estateId,
    required this.userId,
    required this.userName,
    this.userProfileImage,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    estateId,
    userId,
    userName,
    userProfileImage,
    rating,
    comment,
    createdAt,
    updatedAt,
  ];
}
