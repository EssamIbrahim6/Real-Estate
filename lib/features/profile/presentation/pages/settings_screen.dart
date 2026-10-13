import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../widgets/account_actions.dart';
import '../widgets/profile_section.dart';

class SettingsScreen extends StatelessWidget {
  final String email;

  const SettingsScreen({super.key, this.email = ''});

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
        appBar: AppBar(title: const Text('Settings')),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            ProfileSection(
              title: 'ACCOUNT & SECURITY',
              children: [
                ProfileActionTile(
                  icon: Icons.person_outline_rounded,
                  title: 'Edit profile',
                  subtitle: 'Update your personal details and photo',
                  onTap: () => context.pushNamed('edit-profile'),
                ),
                ProfileActionTile(
                  icon: Icons.lock_reset_rounded,
                  title: 'Reset password',
                  subtitle: email.isEmpty
                      ? 'Send a password reset link'
                      : 'Send a reset link to $email',
                  onTap: () =>
                      context.pushNamed('forgot-password', extra: email),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ProfileSection(
              title: 'PREFERENCES',
              children: const [
                ProfileActionTile(
                  icon: Icons.palette_outlined,
                  title: 'Appearance',
                  subtitle: 'Light theme is currently in use; theme selection is unavailable.',
                  enabled: false,
                ),
                ProfileActionTile(
                  icon: Icons.notifications_none_rounded,
                  title: 'Notifications',
                  subtitle: 'Notification preferences are not available yet.',
                  enabled: false,
                ),
                ProfileActionTile(
                  icon: Icons.language_rounded,
                  title: 'Language',
                  subtitle: 'Language selection is not available yet.',
                  enabled: false,
                ),
              ],
            ),
            const SizedBox(height: 24),
            ProfileSection(
              title: 'SUPPORT',
              children: [
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
      ),
    );
  }
}
