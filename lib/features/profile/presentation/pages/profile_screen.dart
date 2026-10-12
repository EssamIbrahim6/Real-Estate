import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/route_names.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(
              Icons.favorite_border,
              color: AppColors.brandGreen,
            ),
            title: const Text('Favorites'),
            subtitle: const Text('View your saved properties'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(AppRoutes.favorites),
          ),
        ],
      ),
    );
  }
}
