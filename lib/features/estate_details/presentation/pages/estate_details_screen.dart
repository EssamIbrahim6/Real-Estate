import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/helpers/spacing.dart';
import '../../../../core/router/route_names.dart';
import '../../../agent/domain/entities/agent_entity.dart';
import '../../../estate/domain/entities/estate_entity.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/app_skeleton.dart';
import '../../../../core/widgets/person_avatar.dart';
import '../cubit/estate_details_cubit.dart';
import '../cubit/estate_details_state.dart';
import 'fullscreen_gallery_screen.dart';
import '../widgets/estate_map_section.dart';
import '../widgets/estate_favorite_button.dart';
import '../widgets/image_gallery.dart';
import '../widgets/property_info_section.dart';
import '../widgets/submit_review_bottom_sheet.dart';
import '../../../map/domain/models/map_screen_args.dart';

class EstateDetailsScreen extends StatefulWidget {
  final String estateId;

  const EstateDetailsScreen({super.key, required this.estateId});

  @override
  State<EstateDetailsScreen> createState() => _EstateDetailsScreenState();
}

class _EstateDetailsScreenState extends State<EstateDetailsScreen> {
  bool _isDescriptionExpanded = false;
  ReviewSubmitStatus _lastReviewStatus = ReviewSubmitStatus.initial;
  ContactAgentStatus _lastContactAgentStatus = ContactAgentStatus.initial;
  FavoriteActionStatus _lastFavoriteActionStatus = FavoriteActionStatus.initial;
  String? _lastFavoriteError;

  void _openGallery(List<String> images, int initialIndex) {
    context.pushNamed(
      AppRoutes.fullscreenGalleryName,
      extra: FullscreenGalleryRequest(
        images: images,
        initialIndex: initialIndex,
      ),
    );
  }

  Future<void> _contactAgent() async {
    final conversationId = await context
        .read<EstateDetailsCubit>()
        .startConversationWithAgent();
    if (!mounted || conversationId == null) return;

    try {
      await context.pushNamed(
        AppRoutes.chatConversationName,
        pathParameters: {'conversationId': conversationId},
      );
    } catch (_) {
      if (!mounted) return;
      AppFeedback.error(
        context,
        'The conversation was created, but could not be opened.',
      );
    }
  }

  bool _isOwner(EstateEntity estate, AgentEntity? agent) {
    String? currentUserUid;
    try {
      currentUserUid = FirebaseAuth.instance.currentUser?.uid.trim();
    } catch (_) {
      return false;
    }

    if (currentUserUid == null || currentUserUid.isEmpty) return false;

    final ownerIds =
        [
              estate.ownerId,
              estate.userId,
              estate.createdBy,
              estate.publisherId,
              estate.agentUserId,
            ]
            .whereType<String>()
            .map((value) => value.trim())
            .where((value) => value.isNotEmpty);

    if (ownerIds.contains(currentUserUid)) return true;
    final agentUid = agent?.userId.trim();
    return agentUid != null &&
        agentUid.isNotEmpty &&
        agentUid == currentUserUid &&
        estate.agentId.trim().isNotEmpty &&
        (agent?.id.trim() == estate.agentId.trim() ||
            estate.primaryOwnerUid == currentUserUid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: BlocConsumer<EstateDetailsCubit, EstateDetailsState>(
        listenWhen: (previous, current) =>
            previous.submitStatus != current.submitStatus ||
            previous.submitError != current.submitError ||
            previous.contactAgentStatus != current.contactAgentStatus ||
            previous.contactAgentError != current.contactAgentError ||
            previous.favoriteActionStatus != current.favoriteActionStatus ||
            previous.favoriteError != current.favoriteError,
        listener: (context, state) {
          final reviewStatusChanged = _lastReviewStatus != state.submitStatus;
          final contactStatusChanged =
              _lastContactAgentStatus != state.contactAgentStatus;
          final favoriteStatusChanged =
              _lastFavoriteActionStatus != state.favoriteActionStatus;
          final favoriteErrorChanged =
              _lastFavoriteError != state.favoriteError;
          _lastReviewStatus = state.submitStatus;
          _lastContactAgentStatus = state.contactAgentStatus;
          _lastFavoriteActionStatus = state.favoriteActionStatus;
          _lastFavoriteError = state.favoriteError;

          if (reviewStatusChanged &&
              state.submitStatus == ReviewSubmitStatus.error &&
              state.submitError != null) {
            AppFeedback.error(context, state.submitError!);
          } else if (reviewStatusChanged &&
              state.submitStatus == ReviewSubmitStatus.success) {
            AppFeedback.success(
              context,
              'Your review was successfully submitted!',
            );
          } else if (contactStatusChanged &&
              state.contactAgentStatus == ContactAgentStatus.error &&
              state.contactAgentError != null) {
            AppFeedback.error(context, state.contactAgentError!);
          } else if ((favoriteStatusChanged || favoriteErrorChanged) &&
              state.favoriteError != null) {
            AppFeedback.error(context, state.favoriteError!);
          }
        },
        builder: (context, state) {
          final colors = Theme.of(context).colorScheme;
          final l10n = AppLocalizations.of(context);
          final langCode = Localizations.localeOf(context).languageCode;
          if (state.estateStatus == EstateLoadingStatus.loading) {
            return const Scaffold(body: EstateDetailsSkeleton());
          }

          if (state.estateStatus == EstateLoadingStatus.error ||
              state.estate == null) {
            return Scaffold(
              body: AppErrorView(
                message: state.estateError ?? 'Failed to load estate details',
                onRetry: () => context
                    .read<EstateDetailsCubit>()
                    .loadEstateDetails(widget.estateId),
              ),
            );
          }

          final estate = state.estate!;
          final isOwnedByCurrentUser = _isOwner(estate, state.agent);
          final estateImages = ImageGallery.collectImages(
            estate.coverImage,
            estate.images,
          );

          return Stack(
            children: [
              // Scrollable content
              SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Gallery
                    ImageGallery(
                      coverImage: estate.coverImage,
                      images: estate.images,
                      onImageTap: (index) => _openGallery(estateImages, index),
                      onViewAll: (index) => _openGallery(estateImages, index),
                    ),

                    // 2. Main Details
                    Padding(
                      padding: const EdgeInsets.all(AppDimensions.p20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header: Title & Price
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  estate.localizedTitle(langCode),
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: colors.onSurface,
                                    height: 1.25,
                                  ),
                                ),
                              ),
                              horizontalSpace(12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '${l10n?.commonEgp ?? "EGP"} ${estate.price.toInt()}',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: colors.tertiary,
                                    ),
                                  ),
                                  if (estate.pricePeriod != null)
                                    Text(
                                      '/ ${estate.pricePeriod}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: colors.onSurfaceVariant,
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                          verticalSpace(8),

                          // Location & Rating Summary Row
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                size: 16,
                                color: colors.onSurfaceVariant,
                              ),
                              horizontalSpace(4),
                              Expanded(
                                child: Text(
                                  '${estate.location.localizedAddress(langCode)}, ${estate.location.localizedCity(langCode)}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: colors.onSurfaceVariant,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              horizontalSpace(8),
                              const Icon(
                                Icons.star_rounded,
                                color: Colors.amber,
                                size: 18,
                              ),
                              horizontalSpace(3),
                              Text(
                                '${state.calculatedRating}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                ' (${state.calculatedReviewCount})',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                          verticalSpace(20),

                          // 3. Property Stats Cards
                          PropertyInfoSection(estate: estate),
                          verticalSpace(24),

                          // 4. Description
                          Text(
                            l10n?.detailsDescription ?? 'Description',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: colors.onSurface,
                            ),
                          ),
                          verticalSpace(8),
                          Text(
                            estate.localizedDescription(langCode),
                            style: TextStyle(
                              fontSize: 14,
                              color: colors.onSurfaceVariant,
                              height: 1.5,
                            ),
                            maxLines: _isDescriptionExpanded ? null : 3,
                            overflow: _isDescriptionExpanded
                                ? TextOverflow.visible
                                : TextOverflow.ellipsis,
                          ),
                          if (estate.localizedDescription(langCode).length > 120)
                            GestureDetector(
                              onTap: () => setState(
                                () => _isDescriptionExpanded =
                                    !_isDescriptionExpanded,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  _isDescriptionExpanded
                                      ? (l10n?.detailsShowLess ?? 'Show less')
                                      : (l10n?.detailsReadMore ?? 'Read more'),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: colors.tertiary,
                                  ),
                                ),
                              ),
                            ),
                          verticalSpace(24),

                          // 5. Amenities
                          Text(
                            l10n?.detailsAmenities ?? 'Amenities',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: colors.onSurface,
                            ),
                          ),
                          verticalSpace(10),
                          if (estate.amenities.isEmpty)
                            Text(
                              'No specific amenities listed.',
                              style: TextStyle(color: colors.onSurfaceVariant),
                            )
                          else
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: estate.amenities.map((amenity) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colors.surfaceContainerLow,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: colors.outlineVariant,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.check_circle_outline,
                                        size: 15,
                                        color: colors.tertiary,
                                      ),
                                      horizontalSpace(6),
                                      Text(
                                        amenity,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          verticalSpace(24),

                          // 6. Location Map
                          Text(
                            l10n?.detailsLocation ?? 'Location',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: colors.onSurface,
                            ),
                          ),
                          verticalSpace(10),
                          EstateMapSection(
                            location: estate.location,
                            onTap: () {
                              context.push(
                                AppRoutes.map,
                                extra: MapScreenArgs(
                                  targetEstate: estate,
                                  title: estate.localizedTitle(langCode),
                                ),
                              );
                            },
                          ),
                          verticalSpace(24),

                          // 7. Assigned Agent
                          if (state.agent != null) ...[
                            if (isOwnedByCurrentUser) ...[
                              Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: colors.tertiary.withValues(
                                    alpha: 0.12,
                                  ),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  'My Property',
                                  style: TextStyle(
                                    color: colors.tertiary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                            Text(
                              l10n?.detailsListingAgent ?? 'Listing Agent',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: colors.onSurface,
                              ),
                            ),
                            verticalSpace(10),
                            InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () => context.pushNamed(
                                AppRoutes.agentDetailsName,
                                pathParameters: {'agentId': state.agent!.id},
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: colors.surface,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: colors.outlineVariant,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () => context.pushNamed(
                                        AppRoutes.agentDetailsName,
                                        pathParameters: {
                                          'agentId': state.agent!.id,
                                        },
                                      ),
                                      child: PersonAvatar(
                                        photoUrl: state.agent!.primaryPhotoUrl,
                                        radius: 26,
                                        iconSize: 28,
                                      ),
                                    ),
                                    horizontalSpace(12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  state.agent!.displayName,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w700,
                                                    color: colors.onSurface,
                                                  ),
                                                ),
                                              ),
                                              if (state.agent!.isVerified) ...[
                                                horizontalSpace(4),
                                                Icon(
                                                  Icons.verified,
                                                  size: 15,
                                                  color: colors.tertiary,
                                                ),
                                              ],
                                            ],
                                          ),
                                          verticalSpace(2),
                                          Text(
                                            '${state.agent!.yearsOfExperience} years exp • ★ ${state.agent!.rating.toStringAsFixed(1)}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: colors.onSurfaceVariant,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            verticalSpace(24),
                          ],

                          // 8. Reviews Section
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Reviews (${state.calculatedReviewCount})',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: colors.onSurface,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(24),
                                      ),
                                    ),
                                    builder: (_) => SubmitReviewBottomSheet(
                                      initialRating:
                                          state.currentUserReview?.rating ?? 5,
                                      initialComment:
                                          state.currentUserReview?.comment ??
                                          '',
                                      onSubmit: (rating, comment) => context
                                          .read<EstateDetailsCubit>()
                                          .submitReview(
                                            estateId: widget.estateId,
                                            rating: rating,
                                            comment: comment,
                                          ),
                                    ),
                                  );
                                },
                                child: Text(
                                  state.currentUserReview != null
                                      ? 'Edit Review'
                                      : 'Add Review',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: colors.tertiary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          verticalSpace(10),

                          if (state.reviews.isEmpty)
                            Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: colors.surfaceContainerLow,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Center(
                                child: Text(
                                  'No reviews yet. Be the first to share your experience!',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: colors.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            )
                          else
                            ...state.reviews.map(
                              (r) => Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: colors.surface,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: colors.outlineVariant,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          r.userName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 13,
                                          ),
                                        ),
                                        Row(
                                          children: List.generate(
                                            5,
                                            (idx) => Icon(
                                              idx < r.rating
                                                  ? Icons.star_rounded
                                                  : Icons.star_outline_rounded,
                                              color: Colors.amber,
                                              size: 15,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (r.comment.isNotEmpty) ...[
                                      verticalSpace(6),
                                      Text(
                                        r.comment,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: colors.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Back & Share Top Overlay
              Positioned(
                top: MediaQuery.of(context).padding.top + 8,
                left: 16,
                right: 16,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CircleAvatar(
                      backgroundColor: colors.surface,
                      radius: 20,
                      child: IconButton(
                        icon: Icon(
                          Icons.arrow_back,
                          color: colors.onSurface,
                          size: 20,
                        ),
                        onPressed: () => context.pop(),
                      ),
                    ),
                    EstateFavoriteButton(
                      isFavorite: state.isFavorite,
                      isLoading:
                          state.isFavoriteLoading ||
                          state.favoriteActionStatus ==
                              FavoriteActionStatus.loading,
                      onPressed: () {
                        final cubit = context.read<EstateDetailsCubit>();
                        if (!cubit.isAuthenticated) {
                          context.push(AppRoutes.login);
                          return;
                        }
                        cubit.toggleFavorite(estate.id);
                      },
                    ),
                  ],
                ),
              ),

              // Sticky Bottom Contact Bar
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    border: Border(
                      top: BorderSide(color: colors.outlineVariant),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      if (!isOwnedByCurrentUser)
                        Expanded(
                          child: AppButton(
                            text: l10n?.detailsContactAgent ?? 'Contact Agent',
                            isLoading:
                                state.contactAgentStatus ==
                                ContactAgentStatus.loading,
                            onPressed: _contactAgent,
                          ),
                        )
                      else
                        Expanded(
                          child: AppButton(
                            text: 'Your Property',
                            type: AppButtonType.outlined,
                            onPressed: null,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
