import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/helpers/spacing.dart';

class HomeHeader extends StatelessWidget {
  final String? locationName;
  final VoidCallback? onNotificationTap;

  const HomeHeader({super.key, this.locationName, this.onNotificationTap});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final displayName =
        user?.displayName?.split(' ').first ??
        (user?.email != null ? user!.email!.split('@').first : 'Guest');

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.inputBackground,
              backgroundImage: user?.photoURL != null
                  ? NetworkImage(user!.photoURL!)
                  : null,
              child: user?.photoURL == null
                  ? const Icon(
                      Icons.person,
                      color: AppColors.brandNavy,
                      size: 24,
                    )
                  : null,
            ),
            horizontalSpace(12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, $displayName 👋',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.brandNavy,
                  ),
                ),
                verticalSpace(2),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 14,
                      color: AppColors.brandGreen,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      locationName ?? 'Egypt',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        IconButton(
          onPressed:
              onNotificationTap ??
              () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No new notifications')),
                );
              },
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.inputBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.inputBorder),
            ),
            child: const Icon(
              Icons.notifications_none_rounded,
              size: 20,
              color: AppColors.brandNavy,
            ),
          ),
        ),
      ],
    );
  }
}
