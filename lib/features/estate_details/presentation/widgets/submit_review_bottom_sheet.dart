import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/helpers/spacing.dart';
import '../../../../core/widgets/app_button.dart';

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
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.initialComment.isNotEmpty
                    ? 'Edit Your Review'
                    : 'How was your experience?',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.brandNavy,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          verticalSpace(14),
          // Interactive 1-5 Star selector
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final starValue = index + 1;
              return GestureDetector(
                onTap: () => setState(() => _rating = starValue),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Icon(
                    starValue <= _rating
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    color: Colors.amber,
                    size: 38,
                  ),
                ),
              );
            }),
          ),
          verticalSpace(18),
          TextField(
            controller: _commentController,
            maxLines: 4,
            maxLength: 300,
            decoration: InputDecoration(
              hintText: 'Share your thoughts about this estate...',
              filled: true,
              fillColor: AppColors.inputBackground,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.inputBorder),
              ),
            ),
          ),
          verticalSpace(16),
          AppButton(
            text: widget.initialComment.isNotEmpty
                ? 'Update Review'
                : 'Submit Review',
            isLoading: _isLoading,
            onPressed: () async {
              setState(() => _isLoading = true);
              final success = await widget.onSubmit(
                _rating,
                _commentController.text,
              );
              if (mounted) {
                setState(() => _isLoading = false);
                if (success) Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }
}
