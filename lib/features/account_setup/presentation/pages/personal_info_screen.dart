import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/helpers/spacing.dart';
import '../../../../core/utils/validators.dart';
import '../cubit/account_setup_cubit.dart';
import '../cubit/account_setup_state.dart';
import '../widgets/setup_progress_bar.dart';
import '../widgets/setup_step_header.dart';

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    final data = context.read<AccountSetupCubit>().state.data;
    _nameController = TextEditingController(text: data.name);
    _phoneController = TextEditingController(text: data.phone);
    _emailController = TextEditingController(text: data.email);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _onFinishPressed() {
    if (_formKey.currentState?.validate() ?? false) {
      final cubit = context.read<AccountSetupCubit>();
      cubit.updateName(_nameController.text.trim());
      cubit.updatePhone(_phoneController.text.trim());
      cubit.updateEmail(_emailController.text.trim());
      cubit.finishSetup();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AccountSetupCubit, AccountSetupState>(
      listener: (context, state) {
        if (state is AccountSetupSuccess) {
          context.go('/account-setup/success');
        } else if (state is AccountSetupFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is AccountSetupLoading;
        final localImagePath = state.data.localImagePath;

        return Scaffold(
          backgroundColor: AppColors.surface,
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.p24,
                      vertical: 16,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () => context.pop(),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.inputBackground,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.arrow_back_ios_new,
                                size: 18,
                                color: AppColors.brandNavy,
                              ),
                            ),
                          ),
                          verticalSpace(16),
                          const SetupProgressBar(currentStep: 4),
                          verticalSpace(24),
                          const SetupStepHeader(
                            title: 'Fill your information\nbelow',
                            subtitle: 'Add a profile photo, your name and phone number to complete your profile.',
                          ),
                          verticalSpace(24),

                          // Profile Picture Selector
                          Center(
                            child: Stack(
                              children: [
                                CircleAvatar(
                                  radius: 54,
                                  backgroundColor: AppColors.inputBackground,
                                  backgroundImage: localImagePath != null
                                      ? FileImage(File(localImagePath))
                                      : null,
                                  child: localImagePath == null
                                      ? const Icon(
                                          Icons.person,
                                          size: 56,
                                          color: AppColors.textMuted,
                                        )
                                      : null,
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: GestureDetector(
                                    onTap: () => context
                                        .read<AccountSetupCubit>()
                                        .pickProfileImage(),
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: const BoxDecoration(
                                        color: AppColors.brandGreen,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.edit,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          verticalSpace(28),

                          // Name Field
                          TextFormField(
                            controller: _nameController,
                            validator: (val) =>
                                val == null || val.trim().isEmpty
                                ? 'Full name is required'
                                : null,
                            decoration: InputDecoration(
                              hintText: 'Full Name',
                              prefixIcon: const Icon(
                                Icons.person_outline,
                                color: AppColors.textSecondary,
                              ),
                              filled: true,
                              fillColor: AppColors.inputBackground,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          verticalSpace(16),

                          // Phone Field
                          TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            validator: (val) =>
                                val == null || val.trim().isEmpty
                                ? 'Phone number is required'
                                : null,
                            decoration: InputDecoration(
                              hintText: 'Phone Number',
                              prefixIcon: const Icon(
                                Icons.phone_outlined,
                                color: AppColors.textSecondary,
                              ),
                              filled: true,
                              fillColor: AppColors.inputBackground,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          verticalSpace(16),

                          // Email Field
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            validator: AppValidators.email,
                            decoration: InputDecoration(
                              hintText: 'Email Address',
                              prefixIcon: const Icon(
                                Icons.email_outlined,
                                color: AppColors.textSecondary,
                              ),
                              filled: true,
                              fillColor: AppColors.inputBackground,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.p24,
                    vertical: 16,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _onFinishPressed,
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
                              'Finish',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
