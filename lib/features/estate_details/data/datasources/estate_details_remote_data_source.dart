import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/errors/exceptions.dart';
import '../models/review_model.dart';

abstract class EstateDetailsRemoteDataSource {
  Stream<List<String>> watchFavoriteEstateIds(String userId);
  Future<void> addFavorite(String userId, String estateId);
  Future<void> removeFavorite(String userId, String estateId);

  Future<List<ReviewModel>> getReviews(String estateId, {int limit = 20});
  Future<ReviewModel?> getUserReview(String estateId, String userId);
  Future<void> submitReview({
    required String estateId,
    required String userId,
    required String userName,
    String? userProfileImage,
    required int rating,
    required String comment,
    String? existingReviewId,
  });
}

class EstateDetailsRemoteDataSourceImpl
    implements EstateDetailsRemoteDataSource {
  final FirebaseFirestore _firestore;

  const EstateDetailsRemoteDataSourceImpl(this._firestore);

  CollectionReference<Map<String, dynamic>> _favoritesCollection(
    String userId,
  ) => _firestore.collection('users').doc(userId).collection('favorites');

  @override
  Stream<List<String>> watchFavoriteEstateIds(String userId) {
    final normalizedUserId = userId.trim();
    if (normalizedUserId.isEmpty) {
      throw ArgumentError.value(userId, 'userId', 'Must not be empty.');
    }

    return _favoritesCollection(normalizedUserId).snapshots().map(
      (snapshot) => snapshot.docs
          .map((doc) => doc.data()['estateId'] as String? ?? doc.id)
          .where((estateId) => estateId.trim().isNotEmpty)
          .toList(growable: false),
    );
  }

  @override
  Future<void> addFavorite(String userId, String estateId) async {
    final normalizedUserId = userId.trim();
    final normalizedEstateId = estateId.trim();
    if (normalizedUserId.isEmpty || normalizedEstateId.isEmpty) {
      throw ArgumentError('User ID and estate ID must not be empty.');
    }

    try {
      await _favoritesCollection(normalizedUserId).doc(normalizedEstateId).set({
        'estateId': normalizedEstateId,
        'addedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? 'Failed to save favorite');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> removeFavorite(String userId, String estateId) async {
    final normalizedUserId = userId.trim();
    final normalizedEstateId = estateId.trim();
    if (normalizedUserId.isEmpty || normalizedEstateId.isEmpty) {
      throw ArgumentError('User ID and estate ID must not be empty.');
    }

    try {
      await _favoritesCollection(normalizedUserId)
          .doc(normalizedEstateId)
          .delete();
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? 'Failed to remove favorite');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<ReviewModel>> getReviews(
    String estateId, {
    int limit = 20,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('estates')
          .doc(estateId)
          .collection('reviews')
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => ReviewModel.fromFirestore(doc))
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? 'Failed to load reviews');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<ReviewModel?> getUserReview(String estateId, String userId) async {
    try {
      final snapshot = await _firestore
          .collection('estates')
          .doc(estateId)
          .collection('reviews')
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;
      return ReviewModel.fromFirestore(snapshot.docs.first);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> submitReview({
    required String estateId,
    required String userId,
    required String userName,
    String? userProfileImage,
    required int rating,
    required String comment,
    String? existingReviewId,
  }) async {
    try {
      final reviewsRef = _firestore
          .collection('estates')
          .doc(estateId)
          .collection('reviews');
      final now = DateTime.now();

      final docRef = existingReviewId != null
          ? reviewsRef.doc(existingReviewId)
          : reviewsRef.doc();

      final reviewModel = ReviewModel(
        id: docRef.id,
        estateId: estateId,
        userId: userId,
        userName: userName,
        userProfileImage: userProfileImage,
        rating: rating,
        comment: comment,
        createdAt: now,
        updatedAt: existingReviewId != null ? now : null,
      );

      await docRef.set(reviewModel.toFirestore(), SetOptions(merge: true));

      // Maintain consistency: Recalculate average and update Estate document
      final allReviews = await reviewsRef.get();
      if (allReviews.docs.isNotEmpty) {
        final totalRating = allReviews.docs.fold<num>(
          0,
          (sum, doc) => sum + ((doc.data()['rating'] as num?) ?? 5),
        );
        final count = allReviews.docs.length;
        final avgRating = double.parse(
          (totalRating / count).toStringAsFixed(1),
        );

        await _firestore.collection('estates').doc(estateId).update({
          'rating': avgRating,
          'reviewCount': count,
        });
      }
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? 'Failed to submit review');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
