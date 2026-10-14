import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class EstateFavoriteButton extends StatelessWidget {
  final bool isFavorite;
  final bool isLoading;
  final VoidCallback? onPressed;

  const EstateFavoriteButton({
    super.key,
    required this.isFavorite,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) => CircleAvatar(
    backgroundColor: Colors.white,
    radius: 20,
    child: IconButton(
      key: const Key('estate-favorite-button'),
      icon: isLoading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.brandGreen,
              ),
            )
          : Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? AppColors.error : AppColors.brandNavy,
              size: 20,
            ),
      tooltip: 'Toggle favorite',
      onPressed: isLoading ? null : onPressed,
    ),
  );
}
