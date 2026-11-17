import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/helpers/spacing.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/widgets/person_avatar.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../notifications/presentation/widgets/notification_badge.dart';

class HomeHeader extends StatelessWidget {
  final String? locationName;

  const HomeHeader({super.key, this.locationName});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final displayName =
        user?.displayName?.split(' ').first ??
        (user?.email != null ? user!.email!.split('@').first : 'Guest');
    final colors = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Row(
      children: [
        PersonAvatar(
          photoUrl: user?.photoURL,
          radius: 25,
          iconSize: 24,
          backgroundColor: colors.primary.withValues(alpha: 0.1),
          iconColor: colors.primary,
        ),
        horizontalSpace(13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello, $displayName',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                ),
              ),
              verticalSpace(4),
              Row(
                children: [
                  Icon(
                    Icons.location_on_rounded,
                    size: 14,
                    color: colors.tertiary,
                  ),
                  const SizedBox(width: 3),
                  Expanded(
                    child: Text(
                      locationName ?? 'Egypt',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall
                          ?.copyWith(fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        NotificationBadge(
          child: Material(
            color: colors.surfaceContainerLow,
            shape: const CircleBorder(),
            child: IconButton(
              tooltip: l10n?.notificationsTitle ?? 'Notifications',
              onPressed: () => context.pushNamed(AppRoutes.notificationsName),
              icon: Icon(
                Icons.notifications_none_rounded,
                color: colors.onSurface,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
