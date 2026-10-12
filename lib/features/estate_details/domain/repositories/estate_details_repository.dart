import '../../../../core/utils/typedefs.dart';
import '../entities/review_entity.dart';

abstract class EstateDetailsRepository {
  ResultFuture<List<ReviewEntity>> getReviews(
    String estateId, {
    int limit = 20,
  });
  ResultFuture<ReviewEntity?> getUserReview(String estateId, String userId);
  ResultVoid submitReview({
    required String estateId,
    required String userId,
    required String userName,
    String? userProfileImage,
    required int rating,
    required String comment,
    String? existingReviewId,
  });
}
