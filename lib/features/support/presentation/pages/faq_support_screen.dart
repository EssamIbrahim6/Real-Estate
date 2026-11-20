import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/helpers/spacing.dart';
import '../../../../core/widgets/app_feedback.dart';
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
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
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
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: colors.onSurface,
                  letterSpacing: -0.5,
                ),
              ),
              verticalSpace(8),
              Text(
                l10n?.supportSubtitle ??
                    'Find answers to common questions or reach out directly to our dedicated support team.',
                style: TextStyle(
                  fontSize: 13,
                  color: colors.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
              verticalSpace(24),

              Row(
                children: [
                  _buildContactCard(
                    context: context,
                    icon: Icons.language_rounded,
                    label: l10n?.supportWebsite ?? 'Website',
                    onTap: () {
                      AppFeedback.info(context, 'https://apexie-realestate.web.app');
                    },
                  ),
                  horizontalSpace(12),
                  _buildContactCard(
                    context: context,
                    icon: Icons.mail_outline_rounded,
                    label: l10n?.supportEmailUs ?? 'Email Us',
                    onTap: () async {
                      await Clipboard.setData(
                        const ClipboardData(text: 'support@apexie.com'),
                      );
                      if (context.mounted) {
                        AppFeedback.success(
                          context,
                          l10n?.supportEmailCopied ?? 'Support email copied',
                        );
                      }
                    },
                  ),
                  horizontalSpace(12),
                  _buildContactCard(
                    context: context,
                    icon: Icons.description_outlined,
                    label: l10n?.supportTerms ?? 'Terms',
                    onTap: () {
                      AppFeedback.info(
                        context,
                        l10n?.commonTermsAndPrivacy ?? 'Terms of Service & Privacy Policy',
                      );
                    },
                  ),
                ],
              ),
              verticalSpace(24),

              TextField(
                onChanged: (q) => context.read<SupportCubit>().search(q),
                style: TextStyle(color: colors.onSurface, fontSize: 14),
                decoration: InputDecoration(
                  hintText: l10n?.faqSearchHint ?? 'Search questions...',
                  hintStyle: TextStyle(
                    fontSize: 14,
                    color: colors.onSurfaceVariant,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: colors.onSurfaceVariant,
                    size: 20,
                  ),
                  filled: true,
                  fillColor: colors.surfaceContainerLow,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: colors.outlineVariant.withValues(alpha: 0.4),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: colors.outlineVariant.withValues(alpha: 0.4),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: colors.primary,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              verticalSpace(20),

              BlocBuilder<SupportCubit, SupportState>(
                builder: (context, state) {
                  return Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: colors.outlineVariant.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        _buildSegmentTab(
                          context: context,
                          label: l10n?.supportBuyer ?? 'Buyer',
                          isSelected:
                              state.selectedCategory == FaqCategory.buyer,
                          onTap: () => context
                              .read<SupportCubit>()
                              .selectCategory(FaqCategory.buyer),
                        ),
                        _buildSegmentTab(
                          context: context,
                          label: l10n?.supportEstateAgent ?? 'Estate Agent',
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
                              ? (l10n?.faqNoResults ?? 'No questions found.')
                              : 'No questions found matching "${state.searchQuery}".',
                          style: TextStyle(
                            color: colors.onSurfaceVariant,
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
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final colors = Theme.of(context).colorScheme;
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: colors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: colors.outlineVariant.withValues(alpha: 0.4),
              ),
            ),
            child: Column(
              children: [
                Icon(icon, color: colors.primary, size: 22),
                const SizedBox(height: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: colors.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSegmentTab({
    required BuildContext context,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final colors = Theme.of(context).colorScheme;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? colors.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: isSelected
                ? Border.all(
                    color: colors.outlineVariant.withValues(alpha: 0.5),
                  )
                : null,
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: colors.shadow.withValues(alpha: 0.05),
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
                color: isSelected ? colors.onSurface : colors.onSurfaceVariant,
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
    final colors = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          onExpansionChanged: (val) => setState(() => _isExpanded = val),
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          title: Text(
            widget.item.question,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: colors.onSurface,
            ),
          ),
          trailing: AnimatedRotation(
            turns: _isExpanded ? 0.125 : 0,
            duration: const Duration(milliseconds: 200),
            child: Icon(Icons.add, color: colors.primary, size: 22),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  widget.item.answer,
                  style: TextStyle(
                    fontSize: 13,
                    color: colors.onSurfaceVariant,
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
