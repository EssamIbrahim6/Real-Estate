import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/helpers/spacing.dart';
import '../../../../core/router/route_names.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../widgets/app_back_button.dart';
import '../widgets/auth_header.dart';
import '../widgets/otp_input_boxes.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String email;

  const OtpVerificationScreen({super.key, required this.email});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  String _enteredOtp = '';
  int _secondsRemaining = 45;
  Timer? _timer;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _secondsRemaining = 45;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _onVerifyPressed() {
    if (_enteredOtp.length == 4) {
      setState(() => _errorMessage = null);
      context.read<AuthCubit>().verifyOtp(
        email: widget.email,
        otp: _enteredOtp,
      );
    } else {
      setState(() => _errorMessage = 'Please enter all 4 digits');
    }
  }

  void _onResendPressed() {
    if (_secondsRemaining == 0) {
      context.read<AuthCubit>().resendOtp(widget.email);
      _startCountdown();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is OtpVerificationSuccessState) {
          context.go(AppRoutes.home);
        } else if (state is AuthFailureState) {
          setState(() => _errorMessage = state.message);
        } else if (state is OtpResentSuccessState) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('A new verification code has been dispatched.'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return Scaffold(
          backgroundColor: AppColors.surface,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppBackButton(onTap: () => context.pop()),
                  verticalSpace(24),

                  const AuthHeader(
                    title: 'Enter the code',
                    subtitle: 'Enter the 4-digit verification code sent to your email:',
                  ),
                  verticalSpace(6),

                  Text(
                    widget.email,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.brandNavy,
                    ),
                  ),
                  verticalSpace(36),

                  OtpInputBoxes(
                    length: 4,
                    hasError: _errorMessage != null,
                    onChanged: (val) {
                      _enteredOtp = val;
                      if (_errorMessage != null) {
                        setState(() => _errorMessage = null);
                      }
                    },
                    onCompleted: (otp) {
                      _enteredOtp = otp;
                      _onVerifyPressed();
                    },
                  ),
                  verticalSpace(16),

                  if (_errorMessage != null) ...[
                    Center(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(
                          color: AppColors.error,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    verticalSpace(16),
                  ],

                  Center(
                    child: _secondsRemaining > 0
                        ? Text(
                            'Resend code in 00:${_secondsRemaining.toString().padLeft(2, '0')}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          )
                        : GestureDetector(
                            onTap: _onResendPressed,
                            child: const Text(
                              'Resend OTP',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.brandGreen,
                              ),
                            ),
                          ),
                  ),
                  verticalSpace(36),

                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _onVerifyPressed,
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
                          : const Text(
                              'Verify',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
