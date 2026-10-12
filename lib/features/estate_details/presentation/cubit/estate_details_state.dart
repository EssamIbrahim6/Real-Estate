import 'package:equatable/equatable.dart';

import '../../../../features/agent/domain/entities/agent_entity.dart';
import '../../../../features/estate/domain/entities/estate_entity.dart';
import '../../domain/entities/review_entity.dart';

enum EstateLoadingStatus { initial, loading, success, error }

enum ReviewsLoadingStatus { initial, loading, success, error }

enum ReviewSubmitStatus { initial, loading, success, error }

enum ContactAgentStatus { initial, loading, success, error }

class EstateDetailsState extends Equatable {
  final EstateLoadingStatus estateStatus;
  final EstateEntity? estate;
  final String? estateError;

  final AgentEntity? agent;
  final bool isAgentLoading;

  final ReviewsLoadingStatus reviewsStatus;
  final List<ReviewEntity> reviews;
  final ReviewEntity? currentUserReview;
  final String? reviewsError;

  final ReviewSubmitStatus submitStatus;
  final String? submitError;

  final ContactAgentStatus contactAgentStatus;
  final String? contactAgentError;
  final String? conversationId;

  final double calculatedRating;
  final int calculatedReviewCount;
  final Map<int, int> ratingDistribution; // 5 -> count, 4 -> count, etc.

  const EstateDetailsState({
    this.estateStatus = EstateLoadingStatus.initial,
    this.estate,
    this.estateError,
    this.agent,
    this.isAgentLoading = false,
    this.reviewsStatus = ReviewsLoadingStatus.initial,
    this.reviews = const [],
    this.currentUserReview,
    this.reviewsError,
    this.submitStatus = ReviewSubmitStatus.initial,
    this.submitError,
    this.contactAgentStatus = ContactAgentStatus.initial,
    this.contactAgentError,
    this.conversationId,
    this.calculatedRating = 0.0,
    this.calculatedReviewCount = 0,
    this.ratingDistribution = const {5: 0, 4: 0, 3: 0, 2: 0, 1: 0},
  });

  EstateDetailsState copyWith({
    EstateLoadingStatus? estateStatus,
    EstateEntity? estate,
    String? estateError,
    AgentEntity? agent,
    bool? isAgentLoading,
    ReviewsLoadingStatus? reviewsStatus,
    List<ReviewEntity>? reviews,
    ReviewEntity? currentUserReview,
    String? reviewsError,
    ReviewSubmitStatus? submitStatus,
    String? submitError,
    ContactAgentStatus? contactAgentStatus,
    String? contactAgentError,
    String? conversationId,
    bool clearConversationId = false,
    double? calculatedRating,
    int? calculatedReviewCount,
    Map<int, int>? ratingDistribution,
  }) {
    return EstateDetailsState(
      estateStatus: estateStatus ?? this.estateStatus,
      estate: estate ?? this.estate,
      estateError: estateError,
      agent: agent ?? this.agent,
      isAgentLoading: isAgentLoading ?? this.isAgentLoading,
      reviewsStatus: reviewsStatus ?? this.reviewsStatus,
      reviews: reviews ?? this.reviews,
      currentUserReview: currentUserReview ?? this.currentUserReview,
      reviewsError: reviewsError,
      submitStatus: submitStatus ?? this.submitStatus,
      submitError: submitError,
      contactAgentStatus: contactAgentStatus ?? this.contactAgentStatus,
      contactAgentError: contactAgentError,
      conversationId: clearConversationId
          ? null
          : conversationId ?? this.conversationId,
      calculatedRating: calculatedRating ?? this.calculatedRating,
      calculatedReviewCount:
          calculatedReviewCount ?? this.calculatedReviewCount,
      ratingDistribution: ratingDistribution ?? this.ratingDistribution,
    );
  }

  @override
  List<Object?> get props => [
    estateStatus,
    estate,
    estateError,
    agent,
    isAgentLoading,
    reviewsStatus,
    reviews,
    currentUserReview,
    reviewsError,
    submitStatus,
    submitError,
    contactAgentStatus,
    contactAgentError,
    conversationId,
    calculatedRating,
    calculatedReviewCount,
    ratingDistribution,
  ];
}
