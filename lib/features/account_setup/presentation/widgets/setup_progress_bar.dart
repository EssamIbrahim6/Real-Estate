import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class SetupProgressBar extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const SetupProgressBar({
    super.key,
    required this.currentStep,
    this.totalSteps = 4,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Step $currentStep of $totalSteps',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              '${((currentStep / totalSteps) * 100).toInt()}%',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.brandGreen,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: currentStep / totalSteps,
            minHeight: 6,
            backgroundColor: AppColors.inputBackground,
            valueColor: const AlwaysStoppedAnimation<Color>(
              AppColors.brandGreen,
            ),
          ),
        ),
      ],
    );
  }
}
