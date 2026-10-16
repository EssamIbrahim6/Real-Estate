import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/app_skeleton.dart';
import '../../../../core/widgets/person_avatar.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';
import '../widgets/account_actions.dart';
import '../widgets/profile_section.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is Unauthenticated) {
          context.go(AppRoutes.welcome);
        } else if (state is AuthFailureState) {
          AppFeedback.error(context, state.message);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n?.profileTitle ?? 'Your profile'),
          actions: [
            IconButton(
              tooltip: l10n?.profileSettingsTitle ?? 'Settings',
              onPressed: () => context.pushNamed(
                'settings',
                extra: context.read<ProfileCubit>().state.email,
              ),
              icon: const Icon(Icons.settings_outlined),
            ),
          ],
        ),
        body: BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, state) {
            if (state.status == ProfileStatus.initial ||
                state.status == ProfileStatus.loading) {
              return const SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(20, 16, 20, 32),
                child: Column(
                  children: [
                    ProfileHeaderSkeleton(),
                    SizedBox(height: 28),
                    AppSkeleton(height: 174),
                    SizedBox(height: 24),
                    AppSkeleton(height: 118),
                  ],
                ),
              );
            }
            if (state.status == ProfileStatus.signedOut) {
              return _SignedOutView(
                onSignIn: () => context.go(AppRoutes.login),
              );
            }
            if (state.status == ProfileStatus.error) {
              return _ProfileLoadError(
                message: state.error ??
                    l10n?.profileLoadError ??
                    'Your profile could not be loaded.',
                onRetry: context.read<ProfileCubit>().loadProfile,
              );
            }

            return RefreshIndicator(
              onRefresh: context.read<ProfileCubit>().loadProfile,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                children: [
                  _ProfileHeader(
                    name: state.displayName,
                    email: state.email,
                    photoUrl: state.photoUrl,
                    isEmailVerified: state.isEmailVerified,
                    onEdit: () async {
                      final updated = await context.pushNamed<bool>(
                        'edit-profile',
                      );
                      if (updated == true && context.mounted) {
                        await context.read<ProfileCubit>().loadProfile();
                      }
                    },
                  ),
                  if (state.warning != null) ...[
                    const SizedBox(height: 12),
                    _Notice(message: state.warning!),
                  ],
                  const SizedBox(height: 28),
                  ProfileSection(
                    title: l10n?.profileSectionAccount ?? 'YOUR ACCOUNT',
                    children: [
                      ProfileActionTile(
                        icon: Icons.person_outline_rounded,
                        title: l10n?.profileEditTitle ?? 'Edit profile',
                        subtitle: l10n?.profileEditSubtitle ??
                            'Update your name, phone, and photo',
                        onTap: () async {
                          final updated = await context.pushNamed<bool>(
                            'edit-profile',
                          );
                          if (updated == true && context.mounted) {
                            await context.read<ProfileCubit>().loadProfile();
                          }
                        },
                      ),
                      ProfileActionTile(
                        icon: Icons.favorite_border_rounded,
                        title: l10n?.favoritesTitle ?? 'Favorites',
                        subtitle: l10n?.profileFavoritesSubtitle ??
                            'Properties you have saved',
                        onTap: () => context.push(AppRoutes.favorites),
                      ),
                      ProfileActionTile(
                        icon: Icons.chat_bubble_outline_rounded,
                        title: l10n?.navChat ?? 'Messages',
                        subtitle: l10n?.profileMessagesSubtitle ??
                            'Continue your conversations',
                        onTap: () => context.go(AppRoutes.chat),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ProfileSection(
                    title: l10n?.profileSectionPreferences ??
                        'PREFERENCES & SUPPORT',
                    children: [
                      ProfileActionTile(
                        icon: Icons.settings_outlined,
                        title: l10n?.profileSettingsTitle ?? 'Settings',
                        subtitle: l10n?.profileSettingsSubtitle ??
                            'Account security and app preferences',
                        onTap: () =>
                            context.pushNamed('settings', extra: state.email),
                      ),
                      ProfileActionTile(
                        icon: Icons.help_outline_rounded,
                        title: l10n?.profileHelpTitle ?? 'Help & support',
                        subtitle: l10n?.profileHelpSubtitle ??
                            'Browse frequently asked questions',
                        onTap: () => context.push(AppRoutes.faqSupport),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ProfileSection(
                    title: l10n?.profileSectionSignOut ?? 'ACCOUNT',
                    children: [
                      ProfileActionTile(
                        icon: Icons.logout_rounded,
                        title: l10n?.profileSignOutTitle ?? 'Sign out',
                        subtitle: l10n?.profileSignOutSubtitle ??
                            'Sign out of this account on this device',
                        destructive: true,
                        onTap: () => confirmSignOut(context),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final String name;
  final String email;
  final String? photoUrl;
  final bool isEmailVerified;
  final VoidCallback onEdit;

  const _ProfileHeader({
    required this.name,
    required this.email,
    required this.photoUrl,
    required this.isEmailVerified,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        children: [
          Row(
            children: [
              PersonAvatar(
                photoUrl: photoUrl,
                radius: 34,
                iconSize: 32,
                backgroundColor: colors.primary.withValues(alpha: 0.08),
                iconColor: colors.primary,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name.trim().isEmpty
                          ? (l10n?.profileTitle ?? 'Your profile')
                          : name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                      ),
                    ),
                    if (email.isNotEmpty) ...[
                      const SizedBox(height: 5),
                      Text(
                        email,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colors.onSurface.withValues(alpha: 0.62),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Icon(
                isEmailVerified ? Icons.verified_rounded : Icons.info_outline,
                size: 16,
                color: isEmailVerified
                    ? colors.primary
                    : colors.onSurface.withValues(alpha: 0.55),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  isEmailVerified
                      ? (l10n?.profileEmailVerified ?? 'Email verified')
                      : (l10n?.profileEmailNotVerified ?? 'Email not verified'),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.onSurface.withValues(alpha: 0.65),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              OutlinedButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined, size: 16),
                label: Text(l10n?.profileEditTitle ?? 'Edit profile'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 40),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  visualDensity: VisualDensity.compact,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  final String message;

  const _Notice({required this.message});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.tertiaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        message,
        style: Theme.of(context).textTheme.bodySmall
            ?.copyWith(color: colors.onTertiaryContainer),
      ),
    );
  }
}

class _SignedOutView extends StatelessWidget {
  final VoidCallback onSignIn;

  const _SignedOutView({required this.onSignIn});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.person_outline_rounded, size: 48),
            const SizedBox(height: 16),
            Text(
              l10n?.profileSignInPrompt ?? 'Sign in to view your profile',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              l10n?.profileSignInSubtitle ??
                  'Your saved properties and account details will be here.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: onSignIn,
              child: Text(l10n?.authSignIn ?? 'Sign in'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileLoadError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ProfileLoadError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(l10n?.commonRetry ?? 'Try again'),
            ),
          ],
        ),
      ),
    );
  }
}
