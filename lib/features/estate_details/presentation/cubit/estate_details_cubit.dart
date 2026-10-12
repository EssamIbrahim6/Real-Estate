import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../features/chat/domain/repositories/chat_repository.dart';
import '../../../../features/agent/domain/repositories/agent_repository.dart';
import '../../../../features/estate/domain/entities/estate_entity.dart';
import '../../../../features/estate/domain/repositories/estate_repository.dart';
import '../../domain/entities/review_entity.dart';
import '../../domain/repositories/estate_details_repository.dart';
import 'estate_details_state.dart';

class EstateDetailsCubit extends Cubit<EstateDetailsState> {
  final EstateRepository _estateRepository;
  final AgentRepository _agentRepository;
  final EstateDetailsRepository _estateDetailsRepository;
  final FirebaseAuth _firebaseAuth;
  final ChatRepository _chatRepository;
  StreamSubscription<List<String>>? _favoriteSubscription;

  EstateDetailsCubit({
    required EstateRepository estateRepository,
    required AgentRepository agentRepository,
    required EstateDetailsRepository estateDetailsRepository,
    required FirebaseAuth firebaseAuth,
    required this._chatRepository,
  }) : _estateRepository = estateRepository,
       _agentRepository = agentRepository,
       _estateDetailsRepository = estateDetailsRepository,
       _firebaseAuth = firebaseAuth,
       super(const EstateDetailsState());

  bool get isAuthenticated => _firebaseAuth.currentUser != null;

  Future<void> toggleFavorite(String estateId) async {
    if (state.favoriteActionStatus == FavoriteActionStatus.loading) return;

    final userId = _firebaseAuth.currentUser?.uid.trim();
    final normalizedEstateId = estateId.trim();
    if (userId == null || userId.isEmpty) {
      emit(
        state.copyWith(
          favoriteActionStatus: FavoriteActionStatus.error,
          favoriteError: 'Sign in to save properties to your favorites.',
        ),
      );
      return;
    }
    if (normalizedEstateId.isEmpty) {
      emit(
        state.copyWith(
          favoriteActionStatus: FavoriteActionStatus.error,
          favoriteError: 'This property could not be saved.',
        ),
      );
      return;
    }

    final shouldAdd = !state.isFavorite;
    emit(
      state.copyWith(
        favoriteActionStatus: FavoriteActionStatus.loading,
        favoriteError: null,
      ),
    );

    final result = shouldAdd
        ? await _estateDetailsRepository.addFavorite(userId, normalizedEstateId)
        : await _estateDetailsRepository.removeFavorite(
            userId,
            normalizedEstateId,
          );
    if (result.failure != null || !result.isSuccess) {
      emit(
        state.copyWith(
          favoriteActionStatus: FavoriteActionStatus.error,
          favoriteError:
              result.failure?.message ?? 'Could not update this favorite.',
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        isFavorite: shouldAdd,
        favoriteActionStatus: FavoriteActionStatus.success,
        favoriteError: null,
      ),
    );
  }

  void _watchFavoriteStatus(String estateId) {
    _favoriteSubscription?.cancel();
    final userId = _firebaseAuth.currentUser?.uid.trim();
    if (userId == null || userId.isEmpty) {
      emit(
        state.copyWith(
          isFavorite: false,
          isFavoriteLoading: false,
          favoriteError: null,
          favoriteActionStatus: FavoriteActionStatus.initial,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        isFavorite: false,
        isFavoriteLoading: true,
        favoriteError: null,
        favoriteActionStatus: FavoriteActionStatus.initial,
      ),
    );
    try {
      _favoriteSubscription = _estateDetailsRepository
          .watchFavoriteEstateIds(userId)
          .listen(
            (estateIds) => emit(
              state.copyWith(
                isFavorite: estateIds.contains(estateId),
                isFavoriteLoading: false,
                favoriteError: null,
              ),
            ),
            onError: (Object error) {
              emit(
                state.copyWith(
                  isFavoriteLoading: false,
                  favoriteError: 'Favorites could not be loaded.',
                ),
              );
            },
          );
    } catch (_) {
      emit(
        state.copyWith(
          isFavoriteLoading: false,
          favoriteError: 'Favorites could not be loaded.',
        ),
      );
    }
  }

  @override
  Future<void> close() async {
    await _favoriteSubscription?.cancel();
    return super.close();
  }

  Future<String?> startConversationWithAgent() async {
    if (state.contactAgentStatus == ContactAgentStatus.loading) return null;

    emit(
      state.copyWith(
        contactAgentStatus: ContactAgentStatus.loading,
        contactAgentError: null,
        clearConversationId: true,
      ),
    );

    try {
      final customerUid = _firebaseAuth.currentUser?.uid.trim();
      if (customerUid == null || customerUid.isEmpty) {
        return _failContactAgent(
          'Sign in to contact the agent for this property.',
        );
      }

      final estate = state.estate;
      if (estate == null) {
        return _failContactAgent(
          'Property details are unavailable. Please try again.',
        );
      }
      final estateId = estate.id.trim();
      if (estateId.isEmpty) {
        return _failContactAgent(
          'Property details are unavailable. Please try again.',
        );
      }

      final agentId = estate.agentId.trim();
      if (agentId.isEmpty) {
        return _failContactAgent(
          'An agent is not assigned to this property yet.',
        );
      }

      final agentResult = await _agentRepository.getAgentById(agentId);
      final agent = agentResult.data;
      if (agentResult.failure != null || agent == null) {
        return _failContactAgent(
          'We could not find the agent for this property.',
        );
      }
      if (agent.id.trim() != agentId) {
        return _failContactAgent(
          'We could not find the agent for this property.',
        );
      }

      final agentUserUid = agent.userId.trim();
      if (agentUserUid.isEmpty ||
          agentUserUid.length > 128 ||
          agentUserUid.contains(RegExp(r'\s'))) {
        return _failContactAgent(
          'This agent is not set up to receive messages yet.',
        );
      }
      if (customerUid == agentUserUid) {
        return _failContactAgent(
          'You cannot start a conversation with your own agent account.',
        );
      }

      final result = await _chatRepository.getOrCreateConversation(
        customerUid: customerUid,
        agentUserUid: agentUserUid,
        agentId: agentId,
        estateId: estateId,
      );
      if (result.failure != null || result.data == null) {
        return _failContactAgent(
          'We could not open this conversation. Please try again.',
        );
      }

      emit(
        state.copyWith(
          contactAgentStatus: ContactAgentStatus.success,
          conversationId: result.data!.id,
        ),
      );
      return result.data!.id;
    } catch (_) {
      return _failContactAgent(
        'We could not open this conversation. Please try again.',
      );
    }
  }

  String? _failContactAgent(String message) {
    emit(
      state.copyWith(
        contactAgentStatus: ContactAgentStatus.error,
        contactAgentError: message,
      ),
    );
    return null;
  }

  Future<void> loadEstateDetails(
    String estateId, {
    EstateEntity? initialEstate,
  }) async {
    if (initialEstate != null) {
      emit(
        state.copyWith(
          estateStatus: EstateLoadingStatus.success,
          estate: initialEstate,
          calculatedRating: initialEstate.rating,
          calculatedReviewCount: initialEstate.reviewCount,
        ),
      );

      _watchFavoriteStatus(initialEstate.id);
      // Parallel background loads for Agent and Reviews
      _loadAgent(initialEstate.agentId);
      loadReviews(estateId);
      return;
    }

    emit(
      state.copyWith(
        estateStatus: EstateLoadingStatus.loading,
        estateError: null,
      ),
    );

    final result = await _estateRepository.getEstateById(estateId);

    if (result.failure != null) {
      emit(
        state.copyWith(
          estateStatus: EstateLoadingStatus.error,
          estateError: result.failure!.message,
        ),
      );
      return;
    }

    final estate = result.data;
    if (estate == null) {
      emit(
        state.copyWith(
          estateStatus: EstateLoadingStatus.error,
          estateError: 'Estate details not found.',
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        estateStatus: EstateLoadingStatus.success,
        estate: estate,
        calculatedRating: estate.rating,
        calculatedReviewCount: estate.reviewCount,
      ),
    );

    _watchFavoriteStatus(estate.id);
    // Parallel background loads for Agent and Reviews
    _loadAgent(estate.agentId);
    loadReviews(estateId);
  }

  Future<void> _loadAgent(String agentId) async {
    final normalizedAgentId = agentId.trim();
    if (normalizedAgentId.isEmpty) return;
    emit(state.copyWith(isAgentLoading: true));
    final agentResult = await _agentRepository.getAgentById(normalizedAgentId);
    if (agentResult.data != null) {
      emit(state.copyWith(agent: agentResult.data, isAgentLoading: false));
    } else {
      emit(state.copyWith(isAgentLoading: false));
    }
  }

  Future<void> loadReviews(String estateId) async {
    emit(
      state.copyWith(
        reviewsStatus: ReviewsLoadingStatus.loading,
        reviewsError: null,
      ),
    );

    final reviewsResult = await _estateDetailsRepository.getReviews(estateId);

    if (reviewsResult.failure != null) {
      emit(
        state.copyWith(
          reviewsStatus: ReviewsLoadingStatus.error,
          reviewsError: reviewsResult.failure!.message,
        ),
      );
      return;
    }

    final reviews = reviewsResult.data ?? [];
    final currentUserId = _firebaseAuth.currentUser?.uid;

    ReviewEntity? userReview;
    if (currentUserId != null) {
      userReview = reviews.where((r) => r.userId == currentUserId).firstOrNull;
    }

    // Compute distribution and average
    final distribution = <int, int>{5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
    double total = 0;
    for (final r in reviews) {
      distribution[r.rating] = (distribution[r.rating] ?? 0) + 1;
      total += r.rating;
    }

    final count = reviews.length;
    final avg = count > 0 ? (total / count) : (state.estate?.rating ?? 0.0);

    emit(
      state.copyWith(
        reviewsStatus: ReviewsLoadingStatus.success,
        reviews: reviews,
        currentUserReview: userReview,
        calculatedRating: double.parse(avg.toStringAsFixed(1)),
        calculatedReviewCount: count > 0
            ? count
            : (state.estate?.reviewCount ?? 0),
        ratingDistribution: distribution,
      ),
    );
  }

  Future<bool> submitReview({
    required String estateId,
    required int rating,
    required String comment,
  }) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      emit(
        state.copyWith(
          submitStatus: ReviewSubmitStatus.error,
          submitError: 'You must be signed in to submit a review.',
        ),
      );
      return false;
    }

    emit(
      state.copyWith(
        submitStatus: ReviewSubmitStatus.loading,
        submitError: null,
      ),
    );

    final result = await _estateDetailsRepository.submitReview(
      estateId: estateId,
      userId: user.uid,
      userName:
          user.displayName ?? (user.email?.split('@').first ?? 'Resident'),
      userProfileImage: user.photoURL,
      rating: rating,
      comment: comment.trim(),
      existingReviewId: state.currentUserReview?.id,
    );

    if (result.failure != null || !result.isSuccess) {
      emit(
        state.copyWith(
          submitStatus: ReviewSubmitStatus.error,
          submitError: result.failure?.message ?? 'Failed to submit review',
        ),
      );
      return false;
    }

    emit(state.copyWith(submitStatus: ReviewSubmitStatus.success));
    // Refresh reviews to reflect updated values
    await loadReviews(estateId);
    return true;
  }
}
