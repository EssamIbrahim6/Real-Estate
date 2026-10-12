import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/helpers/spacing.dart';
import '../../../../core/widgets/person_avatar.dart';
import '../../../agent/domain/entities/agent_entity.dart';

class AgentCard extends StatelessWidget {
  final AgentEntity agent;
  final VoidCallback? onTap;

  const AgentCard({super.key, required this.agent, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        //padding: const EdgeInsets.all(12),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.inputBorder),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: .min,
          children: [
            PersonAvatar(
              photoUrl: agent.primaryPhotoUrl,
              radius: 26,
              iconSize: 28,
            ),
            verticalSpace(8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    agent.displayName,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.brandNavy,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (agent.isVerified) ...[
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.verified,
                    size: 14,
                    color: AppColors.brandGreen,
                  ),
                ],
              ],
            ),
            verticalSpace(4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 13),
                const SizedBox(width: 3),
                Text(
                  '${agent.rating.toStringAsFixed(1)} (${agent.reviewCount})',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
