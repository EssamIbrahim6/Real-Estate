import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainNavigationShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainNavigationShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
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
            label: 'Home',
            color: colors.onSurfaceVariant,
          ),
          _NavigationIcon(
            icon: Icons.search_rounded,
            label: 'Search',
            color: colors.onSurfaceVariant,
          ),
          _NavigationIcon(
            icon: Icons.chat_bubble_rounded,
            label: 'Messages',
            color: colors.onSurfaceVariant,
          ),
          _NavigationIcon(
            icon: Icons.person_rounded,
            label: 'Profile',
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
