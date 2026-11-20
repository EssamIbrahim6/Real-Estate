import 'package:flutter/material.dart';

import '../../../../core/helpers/spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../l10n/generated/app_localizations.dart';
import 'review_comment_field.dart';
import 'review_rating_selector.dart';

class SubmitReviewBottomSheet extends StatefulWidget {
  final int initialRating;
  final String initialComment;
  final Future<bool> Function(int rating, String comment) onSubmit;

  const SubmitReviewBottomSheet({
    super.key,
    this.initialRating = 5,
    this.initialComment = '',
    required this.onSubmit,
  });

  @override
  State<SubmitReviewBottomSheet> createState() =>
      _SubmitReviewBottomSheetState();
}

class _SubmitReviewBottomSheetState extends State<SubmitReviewBottomSheet> {
  late int _rating;
  late final TextEditingController _commentController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _rating = widget.initialRating;
    _commentController = TextEditingController(text: widget.initialComment);
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final isEditing = widget.initialComment.isNotEmpty;

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          20,
          12,
          20,
          MediaQuery.viewInsetsOf(context).bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    isEditing
                        ? (l10n?.detailsEditReview ?? 'Edit Your Review')
                        : (l10n?.detailsExperiencePrompt ??
                              'How was your experience?'),
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  tooltip: l10n?.commonClose ?? 'Close',
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            verticalSpace(14),
            ReviewRatingSelector(
              rating: _rating,
              onChanged: (rating) => setState(() => _rating = rating),
            ),
            verticalSpace(12),
            ReviewCommentField(controller: _commentController),
            verticalSpace(16),
            AppButton(
              text: isEditing
                  ? (l10n?.detailsUpdateReview ?? 'Update Review')
                  : (l10n?.detailsSubmitReview ?? 'Submit Review'),
              isLoading: _isLoading,
              onPressed: () async {
                final navigator = Navigator.of(context);
                setState(() => _isLoading = true);
                final success = await widget.onSubmit(
                  _rating,
                  _commentController.text,
                );
                if (!mounted) return;
                setState(() => _isLoading = false);
                if (success) navigator.pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}
