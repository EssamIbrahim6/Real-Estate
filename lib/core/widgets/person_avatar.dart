import 'package:flutter/material.dart';

class PersonAvatar extends StatelessWidget {
  final String? photoUrl;
  final double radius;
  final double iconSize;
  final Color? backgroundColor;
  final Color? iconColor;

  const PersonAvatar({
    super.key,
    required this.photoUrl,
    required this.radius,
    required this.iconSize,
    this.backgroundColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final url = photoUrl?.trim() ?? '';
    return CircleAvatar(
      radius: radius,
      backgroundColor:
          backgroundColor ??
          Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
      child: SizedBox(
        width: radius * 2,
        height: radius * 2,
        child: ClipOval(
          child: url.isEmpty
              ? _placeholder(context)
              : Image.network(
                  key: const Key('person-profile-image'),
                  url,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      _placeholder(context),
                ),
        ),
      ),
    );
  }

  Widget _placeholder(BuildContext context) => Center(
    child: Icon(
      Icons.person,
      color: iconColor ?? Theme.of(context).colorScheme.onSurfaceVariant,
      size: iconSize,
    ),
  );
}
