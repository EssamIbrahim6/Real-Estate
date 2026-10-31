import 'package:flutter/material.dart';

import '../../../../core/helpers/spacing.dart';

class AuthHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const AuthHeader({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: colors.onSurface,
            letterSpacing: -0.5,
          ),
        ),
        verticalSpace(8),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 13,
            color: colors.onSurfaceVariant,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
