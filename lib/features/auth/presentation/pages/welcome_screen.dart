import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_app/core/constants/app_assets.dart';
import 'package:real_estate_app/core/helpers/auth_navigation_helper.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/helpers/spacing.dart';
import '../../../../core/router/route_names.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

import '../widgets/social_auth_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          handleAuthSuccessNavigation(context, state);
        } else if (state is AuthFailureState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return Stack(
          children: [
            Scaffold(
              backgroundColor: AppColors.surface,
              body: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      verticalSpace(12),
                      // 2x2 Image Grid
                      SizedBox(
                        height: size.height * 0.44,
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  Expanded(
                                    flex: 5,
                                    child: _buildImageCard(
                                      AppAssets.welcomeAuth1,
                                    ),
                                  ),
                                  verticalSpace(12),
                                  Expanded(
                                    flex: 5,
                                    child: _buildImageCard(
                                      AppAssets.welcomeAuth2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            horizontalSpace(12),
                            Expanded(
                              child: Column(
                                children: [
                                  Expanded(
                                    flex: 5,
                                    child: _buildImageCard(
                                      AppAssets.welcomeAuth3,
                                    ),
                                  ),
                                  verticalSpace(12),
                                  Expanded(
                                    flex: 5,
                                    child: _buildImageCard(
                                      AppAssets.welcomeAuth4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      verticalSpace(24),

                      // Title
                      RichText(
                        textAlign: TextAlign.center,
                        text: const TextSpan(
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            color: AppColors.brandNavy,
                            letterSpacing: -0.5,
                          ),
                          children: [
                            TextSpan(text: 'Ready to '),
                            TextSpan(
                              text: 'explore?',
                              style: TextStyle(color: AppColors.brandGreen),
                            ),
                          ],
                        ),
                      ),
                      verticalSpace(10),
                      const Text(
                        'Find your dream house easily and experience the comfort of your future home.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                      verticalSpace(28),

                      // Continue with Email Button
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: () => context.pushNamed('login'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.brandGreen,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.email_outlined,
                                color: Colors.white,
                                size: 20,
                              ),
                              SizedBox(width: 10),
                              Text(
                                'Continue with Email',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      verticalSpace(18),

                      const OrDivider(),
                      verticalSpace(18),

                      // Social Auth Buttons
                      Row(
                        children: [
                          SocialAuthButton(
                            label: 'Google',
                            icon: SvgPicture.asset(AppAssets.googleIcon),
                            onTap: isLoading
                                ? null
                                : () => context
                                      .read<AuthCubit>()
                                      .signInWithGoogle(),
                          ),
                          horizontalSpace(12),
                          SocialAuthButton(
                            label: 'Facebook',
                            icon: const Icon(
                              Icons.facebook,
                              color: Color(0xFF1877F2),
                              size: 22,
                            ),
                            onTap: () => _showFacebookNotice(context),
                          ),
                        ],
                      ),
                      verticalSpace(28),

                      // Bottom Register Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Don't have an account? ",
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => context.pushNamed('register'),
                            child: const Text(
                              'Register',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.brandGreen,
                              ),
                            ),
                          ),
                        ],
                      ),
                      verticalSpace(12),
                    ],
                  ),
                ),
              ),
            ),
            if (isLoading)
              Container(
                color: Colors.black26,
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        );
      },
    );
  }

  Widget _buildImageCard(String assetPath) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Image.asset(
        assetPath,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          color: AppColors.inputBackground,
          child: const Icon(
            Icons.home_outlined,
            color: AppColors.textMuted,
            size: 36,
          ),
        ),
      ),
    );
  }

  void _showFacebookNotice(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Facebook Login'),
        content: const Text(
          'Facebook Login requires configuring the Facebook App ID in Firebase Console.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
