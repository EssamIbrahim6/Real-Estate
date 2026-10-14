import 'package:flutter/material.dart';

import '../../../../core/helpers/spacing.dart';
import '../../../../core/widgets/person_avatar.dart';
import '../../../agent/domain/entities/agent_entity.dart';

class AgentCard extends StatelessWidget {
  final AgentEntity agent;
  final VoidCallback? onTap;

  const AgentCard({super.key, required this.agent, this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        //padding: const EdgeInsets.all(12),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.outlineVariant),
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
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: colors.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (agent.isVerified) ...[
                  const SizedBox(width: 4),
                  Icon(Icons.verified, size: 14, color: colors.tertiary),
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
                  style: TextStyle(
                    fontSize: 11,
                    color: colors.onSurfaceVariant,
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
