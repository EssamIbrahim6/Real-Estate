import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../../core/widgets/person_avatar.dart';
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
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is Unauthenticated) {
          context.go(AppRoutes.welcome);
        } else if (state is AuthFailureState) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Your profile'),
          actions: [
            IconButton(
              tooltip: 'Settings',
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
              return const Center(child: CircularProgressIndicator());
            }
            if (state.status == ProfileStatus.signedOut) {
              return _SignedOutView(
                onSignIn: () => context.go(AppRoutes.login),
              );
            }
            if (state.status == ProfileStatus.error) {
              return _ProfileLoadError(
                message: state.error ?? 'Your profile could not be loaded.',
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
                    title: 'YOUR ACCOUNT',
                    children: [
                      ProfileActionTile(
                        icon: Icons.person_outline_rounded,
                        title: 'Edit profile',
                        subtitle: 'Update your name, phone, and photo',
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
                        title: 'Favorites',
                        subtitle: 'Properties you have saved',
                        onTap: () => context.push(AppRoutes.favorites),
                      ),
                      ProfileActionTile(
                        icon: Icons.chat_bubble_outline_rounded,
                        title: 'Messages',
                        subtitle: 'Continue your conversations',
                        onTap: () => context.go(AppRoutes.chat),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ProfileSection(
                    title: 'PREFERENCES & SUPPORT',
                    children: [
                      ProfileActionTile(
                        icon: Icons.settings_outlined,
                        title: 'Settings',
                        subtitle: 'Account security and app preferences',
                        onTap: () =>
                            context.pushNamed('settings', extra: state.email),
                      ),
                      ProfileActionTile(
                        icon: Icons.help_outline_rounded,
                        title: 'Help & support',
                        subtitle: 'Browse frequently asked questions',
                        onTap: () => context.push(AppRoutes.faqSupport),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ProfileSection(
                    title: 'ACCOUNT',
                    children: [
                      ProfileActionTile(
                        icon: Icons.logout_rounded,
                        title: 'Sign out',
                        subtitle: 'Sign out of this account on this device',
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
                      name.trim().isEmpty ? 'Your profile' : name,
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
                  isEmailVerified ? 'Email verified' : 'Email not verified',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.onSurface.withValues(alpha: 0.65),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              OutlinedButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined, size: 16),
                label: const Text('Edit profile'),
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
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.person_outline_rounded, size: 48),
          const SizedBox(height: 16),
          Text(
            'Sign in to view your profile',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          const Text('Your saved properties and account details will be here.'),
          const SizedBox(height: 20),
          FilledButton(onPressed: onSignIn, child: const Text('Sign in')),
        ],
      ),
    ),
  );
}

class _ProfileLoadError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ProfileLoadError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
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
            label: const Text('Try again'),
          ),
        ],
      ),
    ),
  );
}
