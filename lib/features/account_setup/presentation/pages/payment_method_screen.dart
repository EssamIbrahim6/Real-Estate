import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/helpers/spacing.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../cubit/account_setup_cubit.dart';
import '../cubit/account_setup_state.dart';
import '../widgets/setup_progress_bar.dart';
import '../widgets/setup_step_header.dart';

class PaymentMethodScreen extends StatelessWidget {
  const PaymentMethodScreen({super.key});

  static const List<({PaymentPreference method, String title, IconData icon})>
  _methods = [
    (
      method: PaymentPreference.cash,
      title: 'Cash on visit',
      icon: Icons.money_rounded,
    ),
    (
      method: PaymentPreference.visa,
      title: 'Visa card',
      icon: Icons.credit_card_rounded,
    ),
    (
      method: PaymentPreference.mastercard,
      title: 'Mastercard',
      icon: Icons.payment_rounded,
    ),
    (
      method: PaymentPreference.paypal,
      title: 'PayPal',
      icon: Icons.account_balance_wallet_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccountSetupCubit, AccountSetupState>(
      builder: (context, state) {
        final selectedMethod = state.data.paymentMethod;

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
                        const SetupProgressBar(currentStep: 3),
                        verticalSpace(24),
                        const SetupStepHeader(
                          title: 'Add your payment method',
                          subtitle: 'Choose your default payment preference. No credit card details are charged or stored.',
                        ),
                        verticalSpace(24),

                        ..._methods.map((item) {
                          final isSelected = selectedMethod == item.method;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: GestureDetector(
                              onTap: () => context
                                  .read<AccountSetupCubit>()
                                  .selectPaymentMethod(item.method),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 18,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.brandGreen.withValues(
                                          alpha: 0.08,
                                        )
                                      : AppColors.inputBackground,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.brandGreen
                                        : AppColors.inputBorder,
                                    width: isSelected ? 2 : 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        item.icon,
                                        color: isSelected
                                            ? AppColors.brandGreen
                                            : AppColors.brandNavy,
                                        size: 24,
                                      ),
                                    ),
                                    horizontalSpace(16),
                                    Expanded(
                                      child: Text(
                                        item.title,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: isSelected
                                              ? FontWeight.w700
                                              : FontWeight.w500,
                                          color: AppColors.brandNavy,
                                        ),
                                      ),
                                    ),
                                    Icon(
                                      isSelected
                                          ? Icons.radio_button_checked
                                          : Icons.radio_button_off,
                                      color: isSelected
                                          ? AppColors.brandGreen
                                          : AppColors.textMuted,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
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
                      onPressed: selectedMethod != null
                          ? () => context.push('/account-setup/personal-info')
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.brandGreen,
                        disabledBackgroundColor: AppColors.brandGreen
                            .withValues(alpha: 0.3),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Next',
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
