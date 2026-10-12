import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class AgentAvatar extends StatelessWidget {
  final String photoUrl;
  final double radius;
  final double iconSize;

  const AgentAvatar({
    super.key,
    required this.photoUrl,
    required this.radius,
    required this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    final url = photoUrl.trim();
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.brandNavy.withValues(alpha: 0.08),
      child: url.isEmpty
          ? _placeholder()
          : Image.network(
              key: const Key('agent-profile-image'),
              url,
              width: radius * 2,
              height: radius * 2,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => _placeholder(),
            ),
    );
  }

  Widget _placeholder() =>
      Icon(Icons.person, color: AppColors.brandNavy, size: iconSize);
}
