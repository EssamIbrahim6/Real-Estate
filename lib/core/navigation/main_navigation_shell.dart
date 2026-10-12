import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../constants/app_colors.dart';

class MainNavigationShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainNavigationShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: CurvedNavigationBar(
        index: navigationShell.currentIndex,
        height: 60,
        color: AppColors.brandNavy,
        buttonBackgroundColor: AppColors.brandGreen,
        backgroundColor: AppColors.background,
        animationDuration: const Duration(milliseconds: 250),
        items: const [
          Icon(Icons.home_rounded, color: Colors.white),
          Icon(Icons.search_rounded, color: Colors.white),
          Icon(Icons.chat_bubble_rounded, color: Colors.white),
          Icon(Icons.person_rounded, color: Colors.white),
        ],
        onTap: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
      ),
    );
  }
}
