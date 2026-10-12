import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class HomeSearchBar extends StatelessWidget {
  final VoidCallback onSearchTap;

  const HomeSearchBar({super.key, required this.onSearchTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onSearchTap,
          child: Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.inputBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.inputBorder),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.search_rounded,
                  color: AppColors.textMuted,
                  size: 22,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Search properties, location, type...',
                    style: TextStyle(fontSize: 14, color: AppColors.textMuted),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.tune_rounded,
                    size: 16,
                    color: AppColors.brandNavy,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
