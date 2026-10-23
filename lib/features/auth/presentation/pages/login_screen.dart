import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_app/core/constants/app_assets.dart';
import 'package:real_estate_app/core/helpers/auth_navigation_helper.dart';
import 'package:real_estate_app/l10n/generated/app_localizations.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/helpers/spacing.dart';
import '../../../../core/utils/validators.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../widgets/app_back_button.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_text_field.dart';

import '../widgets/social_auth_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLoginPressed() {
    setState(() => _errorMessage = null);
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthCubit>().login(
        email: _emailController.text,
        password: _passwordController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          handleAuthSuccessNavigation(context, state);
        } else if (state is AuthFailureState) {
          setState(() {
            _errorMessage = state.message;
          });
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return Scaffold(
          backgroundColor: AppColors.surface,
          body: SafeArea(
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppBackButton(onTap: () => context.pop()),
                    verticalSpace(24),

                    AuthHeader(
                      title: l10n?.authLoginTitle ?? "Let's Sign In",
                      subtitle: l10n?.authLoginSubtitle ??
                          "Welcome back! Sign in to continue.",
                    ),
                    verticalSpace(28),

                    if (_errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.error.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: AppColors.error,
                              size: 20,
                            ),
                            horizontalSpace(10),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: const TextStyle(
                                  color: AppColors.error,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      verticalSpace(16),
                    ],

                    AuthTextField(
                      controller: _emailController,
                      hintText: l10n?.authEmailLabel ?? 'Email',
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: AppValidators.email,
                      hasError: _errorMessage != null,
                    ),
                    verticalSpace(16),

                    AuthTextField(
                      controller: _passwordController,
                      hintText: l10n?.authPasswordLabel ?? 'Password',
                      prefixIcon: Icons.lock_outline_rounded,
                      isPassword: true,
                      textInputAction: TextInputAction.done,
                      validator: (val) => val == null || val.isEmpty
                          ? (l10n?.authPasswordRequiredField ??
                              'Password is required')
                          : null,
                      hasError: _errorMessage != null,
                    ),
                    verticalSpace(12),

                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () => context.pushNamed('forgot-password'),
                        child: Text(
                          l10n?.authForgotPasswordLink ?? 'Forgot password?',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.brandNavy,
                          ),
                        ),
                      ),
                    ),
                    verticalSpace(28),

                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _onLoginPressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.brandGreen,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                l10n?.authLoginButton ?? 'Login',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                    verticalSpace(24),

                    const OrDivider(),
                    verticalSpace(24),

                    Row(
                      children: [
                        SocialAuthButton(
                          label: 'Google',
                          icon: SvgPicture.asset(AppAssets.googleIcon),
                          onTap: () =>
                              context.read<AuthCubit>().signInWithGoogle(),
                        ),
                        horizontalSpace(12),
                        SocialAuthButton(
                          label: 'Facebook',
                          icon: const Icon(
                            Icons.facebook,
                            color: Color(0xFF1877F2),
                            size: 22,
                          ),
                          onTap: () =>
                              context.read<AuthCubit>().signInWithFacebook(),
                        ),
                      ],
                    ),
                    verticalSpace(28),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          l10n?.authDontHaveAccountShort ??
                              "Don't have an account? ",
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => context.pushReplacementNamed('register'),
                          child: Text(
                            l10n?.authRegisterLink ?? 'Register',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.brandGreen,
                            ),
                          ),
                        ),
                      ],
                    ),
                    verticalSpace(16),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
