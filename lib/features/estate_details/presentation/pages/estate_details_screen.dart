import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/helpers/spacing.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../cubit/estate_details_cubit.dart';
import '../cubit/estate_details_state.dart';
import 'fullscreen_gallery_screen.dart';
import '../widgets/estate_map_section.dart';
import '../widgets/image_gallery.dart';
import '../widgets/property_info_section.dart';
import '../widgets/submit_review_bottom_sheet.dart';

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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'The conversation was created, but could not be opened.',
          ),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocConsumer<EstateDetailsCubit, EstateDetailsState>(
        listenWhen: (previous, current) =>
            previous.submitStatus != current.submitStatus ||
            previous.submitError != current.submitError ||
            previous.contactAgentStatus != current.contactAgentStatus ||
            previous.contactAgentError != current.contactAgentError,
        listener: (context, state) {
          final reviewStatusChanged = _lastReviewStatus != state.submitStatus;
          final contactStatusChanged =
              _lastContactAgentStatus != state.contactAgentStatus;
          _lastReviewStatus = state.submitStatus;
          _lastContactAgentStatus = state.contactAgentStatus;

          if (reviewStatusChanged &&
              state.submitStatus == ReviewSubmitStatus.error &&
              state.submitError != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.submitError!),
                backgroundColor: AppColors.error,
              ),
            );
          } else if (reviewStatusChanged &&
              state.submitStatus == ReviewSubmitStatus.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Your review was successfully submitted!'),
                backgroundColor: AppColors.brandGreen,
              ),
            );
          } else if (contactStatusChanged &&
              state.contactAgentStatus == ContactAgentStatus.error &&
              state.contactAgentError != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.contactAgentError!),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.estateStatus == EstateLoadingStatus.loading) {
            return const Scaffold(body: Center(child: AppLoadingIndicator()));
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
                                  estate.title,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.brandNavy,
                                    height: 1.25,
                                  ),
                                ),
                              ),
                              horizontalSpace(12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'EGP ${estate.price.toInt()}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.brandGreen,
                                    ),
                                  ),
                                  if (estate.pricePeriod != null)
                                    Text(
                                      '/ ${estate.pricePeriod}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textMuted,
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
                              const Icon(
                                Icons.location_on_outlined,
                                size: 16,
                                color: AppColors.textSecondary,
                              ),
                              horizontalSpace(4),
                              Expanded(
                                child: Text(
                                  '${estate.location.address}, ${estate.location.city}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textSecondary,
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
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                          verticalSpace(20),

                          // 3. Property Stats Cards
                          PropertyInfoSection(estate: estate),
                          verticalSpace(24),

                          // 4. Description
                          const Text(
                            'Description',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.brandNavy,
                            ),
                          ),
                          verticalSpace(8),
                          Text(
                            estate.description,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                              height: 1.5,
                            ),
                            maxLines: _isDescriptionExpanded ? null : 3,
                            overflow: _isDescriptionExpanded
                                ? TextOverflow.visible
                                : TextOverflow.ellipsis,
                          ),
                          if (estate.description.length > 120)
                            GestureDetector(
                              onTap: () => setState(
                                () => _isDescriptionExpanded =
                                    !_isDescriptionExpanded,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  _isDescriptionExpanded
                                      ? 'Show less'
                                      : 'Read more',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.brandGreen,
                                  ),
                                ),
                              ),
                            ),
                          verticalSpace(24),

                          // 5. Amenities
                          const Text(
                            'Amenities',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.brandNavy,
                            ),
                          ),
                          verticalSpace(10),
                          if (estate.amenities.isEmpty)
                            const Text(
                              'No specific amenities listed.',
                              style: TextStyle(color: AppColors.textMuted),
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
                                    color: AppColors.inputBackground,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: AppColors.inputBorder,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.check_circle_outline,
                                        size: 15,
                                        color: AppColors.brandGreen,
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
                          const Text(
                            'Location',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.brandNavy,
                            ),
                          ),
                          verticalSpace(10),
                          EstateMapSection(location: estate.location),
                          verticalSpace(24),

                          // 7. Assigned Agent
                          if (state.agent != null) ...[
                            const Text(
                              'Listing Agent',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.brandNavy,
                              ),
                            ),
                            verticalSpace(10),
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: AppColors.inputBorder,
                                ),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 26,
                                    backgroundColor: AppColors.brandNavy
                                        .withValues(alpha: 0.08),
                                    child: const Icon(
                                      Icons.person,
                                      color: AppColors.brandNavy,
                                      size: 28,
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
                                            Text(
                                              state.agent!.agencyName,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.brandNavy,
                                              ),
                                            ),
                                            if (state.agent!.isVerified) ...[
                                              horizontalSpace(4),
                                              const Icon(
                                                Icons.verified,
                                                size: 15,
                                                color: AppColors.brandGreen,
                                              ),
                                            ],
                                          ],
                                        ),
                                        verticalSpace(2),
                                        Text(
                                          '${state.agent!.yearsOfExperience} years exp • ★ ${state.agent!.rating.toStringAsFixed(1)}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.textMuted,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
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
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.brandNavy,
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
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.brandGreen,
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
                                color: AppColors.inputBackground,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Center(
                                child: Text(
                                  'No reviews yet. Be the first to share your experience!',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textMuted,
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
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: AppColors.inputBorder,
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
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: AppColors.textSecondary,
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
                      backgroundColor: Colors.white,
                      radius: 20,
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                          color: AppColors.brandNavy,
                          size: 20,
                        ),
                        onPressed: () => context.pop(),
                      ),
                    ),
                    CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 20,
                      child: IconButton(
                        icon: const Icon(
                          Icons.favorite_border,
                          color: AppColors.brandNavy,
                          size: 20,
                        ),
                        onPressed: () {},
                      ),
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
                    color: AppColors.surface,
                    border: const Border(
                      top: BorderSide(color: AppColors.inputBorder),
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
                      if (estate.virtualTourUrl != null &&
                          estate.virtualTourUrl!.isNotEmpty) ...[
                        Expanded(
                          child: AppButton(
                            text: 'Virtual Tour',
                            type: AppButtonType.outlined,
                            icon: const Icon(Icons.view_in_ar, size: 18),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Opening 3D Tour: ${estate.virtualTourUrl}',
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        horizontalSpace(12),
                      ],
                      Expanded(
                        child: AppButton(
                          text: 'Contact Agent',
                          isLoading:
                              state.contactAgentStatus ==
                              ContactAgentStatus.loading,
                          onPressed: _contactAgent,
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
