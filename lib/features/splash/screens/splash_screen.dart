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
  Timer? _startupTimer;

  @override
  void initState() {
    super.initState();
    _startupTimer = Timer(const Duration(seconds: 2), _determineNextScreen);
  }

  @override
  void dispose() {
    _startupTimer?.cancel();
    super.dispose();
  }

  Future<void> _determineNextScreen() async {
    if (!mounted) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      if (!mounted) return;
      final hasCompletedOnboarding =
          prefs.getBool('has_completed_onboarding') ?? false;

      if (!hasCompletedOnboarding) {
        context.go(AppRoutes.onBoarding);
        return;
      }

      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        context.go(AppRoutes.welcome);
        return;
      }

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();
      if (!mounted) return;

      final isSetupCompleted = userDoc.data()?['accountSetupCompleted'] == true;
      context.go(
        isSetupCompleted ? AppRoutes.home : AppRoutes.accountSetupLocation,
      );
    } catch (_) {
      if (mounted) context.go(AppRoutes.welcome);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    return Scaffold(
      body: Stack(
        children: [
          SizedBox.expand(
            child: Image.asset(
              'assets/images/Splash_Screen.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Center(child: Image.asset('assets/images/Mask group.png')),
          ),
          Positioned(
            bottom: screenHeight * 0.28,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Apexie',
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
