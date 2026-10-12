import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/typedefs.dart';
import '../../domain/entities/review_entity.dart';
import '../../domain/repositories/estate_details_repository.dart';
import '../datasources/estate_details_remote_data_source.dart';

class EstateDetailsRepositoryImpl implements EstateDetailsRepository {
  final EstateDetailsRemoteDataSource _remoteDataSource;

  const EstateDetailsRepositoryImpl(this._remoteDataSource);

  @override
  Stream<List<String>> watchFavoriteEstateIds(String userId) =>
      _remoteDataSource.watchFavoriteEstateIds(userId);

  @override
  ResultVoid addFavorite(String userId, String estateId) async {
    try {
      await _remoteDataSource.addFavorite(userId, estateId);
      return (failure: null, isSuccess: true);
    } on ServerException catch (e) {
      return (failure: ServerFailure(message: e.message), isSuccess: false);
    } catch (e) {
      return (failure: ServerFailure(message: e.toString()), isSuccess: false);
    }
  }

  @override
  ResultVoid removeFavorite(String userId, String estateId) async {
    try {
      await _remoteDataSource.removeFavorite(userId, estateId);
      return (failure: null, isSuccess: true);
    } on ServerException catch (e) {
      return (failure: ServerFailure(message: e.message), isSuccess: false);
    } catch (e) {
      return (failure: ServerFailure(message: e.toString()), isSuccess: false);
    }
  }

  @override
  ResultFuture<List<ReviewEntity>> getReviews(
    String estateId, {
    int limit = 20,
  }) async {
    try {
      final reviews = await _remoteDataSource.getReviews(
        estateId,
        limit: limit,
      );
      return (failure: null, data: reviews);
    } on ServerException catch (e) {
      return (failure: ServerFailure(message: e.message), data: null);
    } catch (e) {
      return (failure: ServerFailure(message: e.toString()), data: null);
    }
  }

  @override
  ResultFuture<ReviewEntity?> getUserReview(
    String estateId,
    String userId,
  ) async {
    try {
      final review = await _remoteDataSource.getUserReview(estateId, userId);
      return (failure: null, data: review);
    } catch (e) {
      return (failure: ServerFailure(message: e.toString()), data: null);
    }
  }

  @override
  ResultVoid submitReview({
    required String estateId,
    required String userId,
    required String userName,
    String? userProfileImage,
    required int rating,
    required String comment,
    String? existingReviewId,
  }) async {
    try {
      await _remoteDataSource.submitReview(
        estateId: estateId,
        userId: userId,
        userName: userName,
        userProfileImage: userProfileImage,
        rating: rating,
        comment: comment,
        existingReviewId: existingReviewId,
      );
      return (failure: null, isSuccess: true);
    } on ServerException catch (e) {
      return (failure: ServerFailure(message: e.message), isSuccess: false);
    } catch (e) {
      return (failure: ServerFailure(message: e.toString()), isSuccess: false);
    }
  }
}
