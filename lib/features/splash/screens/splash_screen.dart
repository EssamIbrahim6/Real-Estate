import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/cubits/connectivity/connectivity_cubit.dart';
import '../../../core/router/route_names.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _nativeSplashRemoved = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unawaited(_determineNextScreen());
    });
  }

  void _removeNativeSplash() {
    if (_nativeSplashRemoved) return;
    _nativeSplashRemoved = true;
    FlutterNativeSplash.remove();
  }

  Future<void> _determineNextScreen() async {
    if (!mounted) return;

    final ConnectivityCubit connectivityCubit;
    try {
      connectivityCubit = context.read<ConnectivityCubit>();
    } catch (_) {
      return;
    }

    try {
      var connectivityStatus = connectivityCubit.state.status;
      if (connectivityStatus == ConnectivityStatus.checking) {
        connectivityStatus = (await connectivityCubit.stream.first).status;
      }
      if (connectivityStatus == ConnectivityStatus.disconnected) {
        _removeNativeSplash();
        await connectivityCubit.stream.firstWhere((state) => state.isConnected);
        if (!mounted) return;
      }

      final prefs = await SharedPreferences.getInstance();
      if (!mounted) return;
      final hasCompletedOnboarding =
          prefs.getBool('has_completed_onboarding') ?? false;

      if (!hasCompletedOnboarding) {
        _navigateTo(AppRoutes.onBoarding);
        return;
      }

      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        _navigateTo(AppRoutes.welcome);
        return;
      }

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();
      if (!mounted) return;

      final isSetupCompleted = userDoc.data()?['accountSetupCompleted'] == true;
      _navigateTo(
        isSetupCompleted ? AppRoutes.home : AppRoutes.accountSetupLocation,
      );
    } catch (_) {
      if (mounted) _navigateTo(AppRoutes.welcome);
    }
  }

  void _navigateTo(String location) {
    if (!mounted) return;
    context.go(location);
    WidgetsBinding.instance.addPostFrameCallback((_) => _removeNativeSplash());
  }

  @override
  Widget build(BuildContext context) => const SizedBox.expand();
}
