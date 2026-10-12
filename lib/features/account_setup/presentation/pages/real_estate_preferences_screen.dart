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

class RealEstatePreferencesScreen extends StatelessWidget {
  const RealEstatePreferencesScreen({super.key});

  static const List<({RealEstateType type, String label, IconData icon})>
  _types = [
    (
      type: RealEstateType.apartment,
      label: 'Apartment',
      icon: Icons.apartment_rounded,
    ),
    (type: RealEstateType.villa, label: 'Villa', icon: Icons.villa_rounded),
    (type: RealEstateType.house, label: 'House', icon: Icons.home_rounded),
    (
      type: RealEstateType.cottage,
      label: 'Cottage',
      icon: Icons.holiday_village_rounded,
    ),
    (
      type: RealEstateType.studio,
      label: 'Studio',
      icon: Icons.meeting_room_rounded,
    ),
    (type: RealEstateType.chalet, label: 'Chalet', icon: Icons.cabin_rounded),
    (
      type: RealEstateType.office,
      label: 'Office',
      icon: Icons.business_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccountSetupCubit, AccountSetupState>(
      builder: (context, state) {
        final selectedTypes = state.data.preferredTypes;

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
                        const SetupProgressBar(currentStep: 2),
                        verticalSpace(24),
                        const SetupStepHeader(
                          title: 'Select your preferable\nreal estate type',
                          subtitle: 'You can choose more than one option so we can tailor the listings.',
                        ),
                        verticalSpace(24),

                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _types.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 14,
                                mainAxisSpacing: 14,
                                childAspectRatio: 1.15,
                              ),
                          itemBuilder: (context, index) {
                            final item = _types[index];
                            final isSelected = selectedTypes.contains(
                              item.type,
                            );

                            return GestureDetector(
                              onTap: () => context
                                  .read<AccountSetupCubit>()
                                  .togglePropertyType(item.type),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.brandGreen.withValues(
                                          alpha: 0.08,
                                        )
                                      : AppColors.inputBackground,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.brandGreen
                                        : AppColors.inputBorder,
                                    width: isSelected ? 2 : 1,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      item.icon,
                                      size: 38,
                                      color: isSelected
                                          ? AppColors.brandGreen
                                          : AppColors.brandNavy,
                                    ),
                                    verticalSpace(10),
                                    Text(
                                      item.label,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: isSelected
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                        color: isSelected
                                            ? AppColors.brandGreen
                                            : AppColors.brandNavy,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
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
                      onPressed: selectedTypes.isNotEmpty
                          ? () => context.push('/account-setup/payment')
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
