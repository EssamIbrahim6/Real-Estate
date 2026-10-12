import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_text_styles.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _determineNextScreen();
  }

  Future<void> _determineNextScreen() async {
    // 2-second splash screen display
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final hasCompletedOnboarding =
          prefs.getBool('has_completed_onboarding') ?? false;

      // 1. First-time user -> Onboarding
      if (!hasCompletedOnboarding) {
        context.go(AppRoutes.onBoarding);
        return;
      }

      // 2. Check Firebase Authentication session
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        context.go(AppRoutes.welcome);
        return;
      }

      // 3. Authenticated user -> Check if Account Setup was completed in Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      final isSetupCompleted = userDoc.data()?['accountSetupCompleted'] == true;

      if (isSetupCompleted) {
        context.go(AppRoutes.home);
      } else {
        context.go(AppRoutes.accountSetupLocation);
      }
    } catch (_) {
      // Fallback safe route on network/storage failure
      if (mounted) context.go(AppRoutes.welcome);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SizedBox.expand(
            child: Image.asset(
              "assets/images/Splash_Screen.jpg",
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            top: 0,
            child: Center(child: Image.asset("assets/images/Mask group.png")),
          ),
          Positioned(
            bottom: 380,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                "Rice",
                style: AppTextStyles.headlineLarge.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
