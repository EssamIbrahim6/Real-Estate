import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/app_skeleton.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/entities/estate_entity.dart';
import '../cubit/my_properties_cubit.dart';
import '../cubit/my_properties_state.dart';

class PropertyManagementScreen extends StatefulWidget {
  const PropertyManagementScreen({super.key});

  @override
  State<PropertyManagementScreen> createState() =>
      _PropertyManagementScreenState();
}

class _PropertyManagementScreenState extends State<PropertyManagementScreen> {
  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      context.read<MyPropertiesCubit>().loadProperties(uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n?.myPropertiesTitle ?? 'Your Properties'),
        ),
        body: AppEmptyState(
          icon: Icons.lock_outline_rounded,
          title:
              l10n?.favoritesSignInPrompt ?? 'Sign in to view your properties',
          actionLabel: l10n?.authSignIn ?? 'Sign In',
          onAction: () => context.push(AppRoutes.login),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.myPropertiesTitle ?? 'Your Properties'),
        leading: BackButton(onPressed: () => context.pop()),
        actions: [
          IconButton(
            tooltip: l10n?.commonRefresh ?? 'Refresh',
            onPressed: _load,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await context.push(AppRoutes.addProperty);
          _load();
        },
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        icon: const Icon(Icons.add_rounded),
        label: Text(l10n?.myPropertiesAddNew ?? 'Add New Property'),
      ),
      body: BlocConsumer<MyPropertiesCubit, MyPropertiesState>(
        listener: (context, state) {
          if (state.actionFeedback != null) {
            AppFeedback.success(
              context,
              l10n?.myPropertiesDeleteSuccess ?? state.actionFeedback!,
            );
          } else if (state.error != null && state.isDeleting) {
            AppFeedback.error(
              context,
              l10n?.myPropertiesDeleteError ?? state.error!,
            );
          }
        },
        builder: (context, state) {
          if (state.status == MyPropertiesStatus.initial ||
              state.status == MyPropertiesStatus.loading) {
            return const PropertyManagementSkeleton();
          }

          if (state.status == MyPropertiesStatus.error) {
            return AppErrorView(
              message: state.error ?? 'Failed to load properties',
              onRetry: _load,
            );
          }

          if (state.properties.isEmpty) {
            return AppEmptyState(
              icon: Icons.holiday_village_outlined,
              title: l10n?.myPropertiesEmpty ?? 'No properties listed yet.',
              description:
                  l10n?.myPropertiesEmptySubtitle ??
                  'Publish your first property to reach thousands of buyers.',
              actionLabel: l10n?.myPropertiesAddNew ?? 'Add New Property',
              onAction: () async {
                await context.push(AppRoutes.addProperty);
                _load();
              },
            );
          }

          final langCode = Localizations.localeOf(context).languageCode;

          return RefreshIndicator(
            onRefresh: () async => _load(),
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
              itemCount: state.properties.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final property = state.properties[index];
                final isBeingDeleted =
                    state.isDeleting && state.deletingPropertyId == property.id;

                return _UserPropertyCard(
                  property: property,
                  langCode: langCode,
                  isDeleting: isBeingDeleted,
                  onTap: () => context.pushNamed(
                    AppRoutes.propertyDetailsName,
                    pathParameters: {'estateId': property.id},
                    extra: property,
                  ),
                  onDelete: () => _confirmDelete(context, property, uid),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext outerContext,
    EstateEntity property,
    String uid,
  ) async {
    final l10n = AppLocalizations.of(outerContext);
    final colors = Theme.of(outerContext).colorScheme;
    final cubit = outerContext.read<MyPropertiesCubit>();

    final confirmed = await showDialog<bool>(
      context: outerContext,
      builder: (ctx) => AlertDialog(
        title: Text(l10n?.myPropertiesDeleteTitle ?? 'Delete Property?'),
        content: Text(
          l10n?.myPropertiesDeleteMessage ?? 'Are you sure you want to permanently delete this property listing? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n?.commonCancel ?? 'Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: colors.error,
              foregroundColor: colors.onError,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n?.myPropertiesDeleteButton ?? 'Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      cubit.deleteProperty(estateId: property.id, ownerId: uid);
    }
  }
}

class _UserPropertyCard extends StatelessWidget {
  final EstateEntity property;
  final String langCode;
  final bool isDeleting;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _UserPropertyCard({
    required this.property,
    required this.langCode,
    required this.isDeleting,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final title = property.localizedTitle(langCode);
    final address = property.location.localizedAddress(langCode);

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colors.outlineVariant.withValues(alpha: 0.5)),
      ),
      color: colors.surface,
      child: InkWell(
        onTap: isDeleting ? null : onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Property Cover
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 88,
                  height: 88,
                  child: property.coverImage.isNotEmpty
                      ? Image.network(
                          property.coverImage,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Container(
                            color: colors.surfaceContainerLow,
                            child: Icon(
                              Icons.home_outlined,
                              color: colors.onSurfaceVariant,
                              size: 32,
                            ),
                          ),
                        )
                      : Container(
                          color: colors.surfaceContainerLow,
                          child: Icon(
                            Icons.home_outlined,
                            color: colors.onSurfaceVariant,
                            size: 32,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 14),

              // Property Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildStatusBadge(context, property.status),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      address,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'EGP ${property.price.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: colors.primary,
                          ),
                        ),
                        if (isDeleting)
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        else
                          IconButton(
                            icon: Icon(
                              Icons.delete_outline_rounded,
                              color: colors.error,
                              size: 20,
                            ),
                            tooltip: l10n?.myPropertiesDeleteButton ?? 'Delete',
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: onDelete,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, String rawStatus) {
    final l10n = AppLocalizations.of(context);
    final status = rawStatus.toLowerCase().trim();

    Color bgColor;
    Color textColor;
    String label;

    switch (status) {
      case 'pending':
        bgColor = Colors.amber.withValues(alpha: 0.15);
        textColor = Colors.amber.shade900;
        label = l10n?.myPropertiesStatusPending ?? 'Pending Review';
      case 'rejected':
        bgColor = Colors.red.withValues(alpha: 0.15);
        textColor = Colors.red.shade800;
        label = l10n?.myPropertiesStatusRejected ?? 'Rejected';
      case 'active':
      case 'approved':
      default:
        bgColor = Colors.green.withValues(alpha: 0.15);
        textColor = Colors.green.shade800;
        label = l10n?.myPropertiesStatusActive ?? 'Active';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
      ),
    );
  }
}
