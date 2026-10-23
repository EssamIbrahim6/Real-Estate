import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/helpers/spacing.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../auth/presentation/widgets/app_back_button.dart';
import '../../domain/entities/faq_item.dart';
import '../cubit/support_cubit.dart';

class FaqSupportScreen extends StatelessWidget {
  const FaqSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SupportCubit(),
      child: const _FaqSupportView(),
    );
  }
}

class _FaqSupportView extends StatelessWidget {
  const _FaqSupportView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppBackButton(onTap: () => context.pop()),
              verticalSpace(20),

              Text(
                l10n?.faqTitle ?? 'FAQ & Support',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: AppColors.brandNavy,
                  letterSpacing: -0.5,
                ),
              ),
              verticalSpace(8),
              const Text(
                'Find answers to common questions or reach out directly to our dedicated support team.',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              verticalSpace(24),

              Row(
                children: [
                  _buildContactCard(
                    icon: Icons.language_rounded,
                    label: 'Website',
                    onTap: () {},
                  ),
                  horizontalSpace(12),
                  _buildContactCard(
                    icon: Icons.mail_outline_rounded,
                    label: 'Email Us',
                    onTap: () {},
                  ),
                  horizontalSpace(12),
                  _buildContactCard(
                    icon: Icons.description_outlined,
                    label: 'Terms',
                    onTap: () {},
                  ),
                ],
              ),
              verticalSpace(24),

              TextField(
                onChanged: (q) => context.read<SupportCubit>().search(q),
                decoration: InputDecoration(
                  hintText: l10n?.faqSearchHint ?? 'Search questions...',
                  hintStyle: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textMuted,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppColors.textMuted,
                    size: 20,
                  ),
                  filled: true,
                  fillColor: AppColors.inputBackground,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              verticalSpace(20),

              BlocBuilder<SupportCubit, SupportState>(
                builder: (context, state) {
                  return Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.inputBackground,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        _buildSegmentTab(
                          label: 'Buyer',
                          isSelected:
                              state.selectedCategory == FaqCategory.buyer,
                          onTap: () => context
                              .read<SupportCubit>()
                              .selectCategory(FaqCategory.buyer),
                        ),
                        _buildSegmentTab(
                          label: 'Estate Agent',
                          isSelected:
                              state.selectedCategory == FaqCategory.estateAgent,
                          onTap: () => context
                              .read<SupportCubit>()
                              .selectCategory(FaqCategory.estateAgent),
                        ),
                      ],
                    ),
                  );
                },
              ),
              verticalSpace(20),

              BlocBuilder<SupportCubit, SupportState>(
                builder: (context, state) {
                  if (state.filteredFaqs.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 36),
                      child: Center(
                        child: Text(
                          state.searchQuery.isEmpty
                              ? (l10n?.faqNoResults ??
                                  'No questions found.')
                              : 'No questions found matching "${state.searchQuery}".',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: state.filteredFaqs.length,
                    separatorBuilder: (_, _) => verticalSpace(12),
                    itemBuilder: (context, index) {
                      return _FaqTile(item: state.filteredFaqs[index]);
                    },
                  );
                },
              ),
              verticalSpace(24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.inputBackground,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              Icon(icon, color: AppColors.brandNavy, size: 22),
              const SizedBox(height: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.brandNavy,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSegmentTab({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? AppColors.brandNavy
                    : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FaqTile extends StatefulWidget {
  final FaqItem item;
  const _FaqTile({required this.item});

  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          onExpansionChanged: (val) => setState(() => _isExpanded = val),
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          title: Text(
            widget.item.question,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.brandNavy,
            ),
          ),
          trailing: AnimatedRotation(
            turns: _isExpanded ? 0.125 : 0,
            duration: const Duration(milliseconds: 200),
            child: const Icon(Icons.add, color: AppColors.brandNavy, size: 22),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  widget.item.answer,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
