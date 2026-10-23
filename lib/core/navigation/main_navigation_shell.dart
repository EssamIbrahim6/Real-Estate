import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/generated/app_localizations.dart';

class MainNavigationShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainNavigationShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: CurvedNavigationBar(
        index: navigationShell.currentIndex,
        height: 60,
        color: colors.surfaceContainerHighest,
        buttonBackgroundColor: colors.primary,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        animationDuration: const Duration(milliseconds: 250),
        items: [
          _NavigationIcon(
            icon: Icons.home_rounded,
            label: l10n?.navHome ?? 'Home',
            color: colors.onSurfaceVariant,
          ),
          _NavigationIcon(
            icon: Icons.search_rounded,
            label: l10n?.navSearch ?? 'Search',
            color: colors.onSurfaceVariant,
          ),
          _NavigationIcon(
            icon: Icons.chat_bubble_rounded,
            label: l10n?.navChat ?? 'Messages',
            color: colors.onSurfaceVariant,
          ),
          _NavigationIcon(
            icon: Icons.person_rounded,
            label: l10n?.navProfile ?? 'Profile',
            color: colors.onSurfaceVariant,
          ),
        ],
        onTap: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
      ),
    );
  }
}

class _NavigationIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _NavigationIcon({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Semantics(
    label: label,
    button: true,
    child: Icon(icon, color: color),
  );
}
