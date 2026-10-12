import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/helpers/spacing.dart';

class SetupStepHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const SetupStepHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: AppColors.brandNavy,
            letterSpacing: -0.5,
            height: 1.25,
          ),
        ),
        verticalSpace(8),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary,
            height: 1.45,
          ),
        ),
      ],
    );
  }
}
