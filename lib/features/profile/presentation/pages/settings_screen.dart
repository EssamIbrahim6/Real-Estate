import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/locale_cubit.dart';
import '../../../../core/localization/locale_state.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../widgets/account_actions.dart';
import '../widgets/profile_section.dart';

class SettingsScreen extends StatelessWidget {
  final String email;

  const SettingsScreen({super.key, this.email = ''});

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
        appBar: AppBar(title: Text(l10n?.settingsTitle ?? 'Settings')),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            ProfileSection(
              title: l10n?.settingsAccountSection ?? 'ACCOUNT & SECURITY',
              children: [
                ProfileActionTile(
                  icon: Icons.person_outline_rounded,
                  title: l10n?.profileEditTitle ?? 'Edit profile',
                  subtitle: l10n?.profileEditSubtitle ??
                      'Update your personal details and photo',
                  onTap: () => context.pushNamed('edit-profile'),
                ),
                ProfileActionTile(
                  icon: Icons.lock_reset_rounded,
                  title: l10n?.settingsResetPassword ?? 'Reset password',
                  subtitle: email.isEmpty
                      ? (l10n?.settingsResetPasswordSubtitle ??
                          'Send a password reset link')
                      : 'Send a reset link to $email',
                  onTap: () =>
                      context.pushNamed('forgot-password', extra: email),
                ),
                ProfileActionTile(
                  icon: Icons.add_home_work_outlined,
                  title: l10n?.settingsAddProperty ?? 'Add New Property',
                  subtitle: l10n?.settingsAddPropertySubtitle ??
                      'List a new estate in English and Arabic',
                  onTap: () => context.push(AppRoutes.addProperty),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ProfileSection(
              title: l10n?.profileSectionPreferences ?? 'PREFERENCES',
              children: [
                const _ThemePreferenceTile(),
                const _LanguagePreferenceTile(),
                ProfileActionTile(
                  icon: Icons.notifications_none_rounded,
                  title: l10n?.settingsNotifications ?? 'Notifications',
                  subtitle: l10n?.settingsNotificationsSubtitle ??
                      'Notification preferences are not available yet.',
                  enabled: false,
                ),
              ],
            ),
            const SizedBox(height: 24),
            ProfileSection(
              title: l10n?.supportSection ?? 'SUPPORT',
              children: [
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
      ),
    );
  }
}

class _ThemePreferenceTile extends StatelessWidget {
  const _ThemePreferenceTile();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        final preference = state.preference;
        return ListTile(
          minVerticalPadding: 12,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .primary
                  .withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.palette_outlined, size: 20),
          ),
          title: Text(
            l10n?.settingsAppearance ?? 'Appearance',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            state.isLoaded
                ? (l10n?.settingsAppearanceSubtitle ??
                    'Choose your preferred theme')
                : (l10n?.commonLoading ?? 'Loading…'),
          ),
          trailing: DropdownButton<AppThemePreference>(
            value: preference,
            underline: const SizedBox.shrink(),
            borderRadius: BorderRadius.circular(12),
            onChanged: state.isLoaded
                ? (value) async {
                    if (value == null || value == preference) return;
                    final cubit = context.read<ThemeCubit>();
                    final saved = await cubit.setPreference(value);
                    if (!saved && context.mounted) {
                      AppFeedback.error(
                        context,
                        cubit.state.error ??
                            'Appearance preference could not be saved.',
                      );
                    }
                  }
                : null,
            items: [
              DropdownMenuItem(
                value: AppThemePreference.system,
                child: Text(l10n?.settingsThemeSystem ?? 'System'),
              ),
              DropdownMenuItem(
                value: AppThemePreference.light,
                child: Text(l10n?.settingsThemeLight ?? 'Light'),
              ),
              DropdownMenuItem(
                value: AppThemePreference.dark,
                child: Text(l10n?.settingsThemeDark ?? 'Dark'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LanguagePreferenceTile extends StatelessWidget {
  const _LanguagePreferenceTile();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocBuilder<LocaleCubit, LocaleState>(
      builder: (context, state) {
        final currentCode = state.locale.languageCode;
        return ListTile(
          minVerticalPadding: 12,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .primary
                  .withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.language_rounded, size: 20),
          ),
          title: Text(
            l10n?.settingsLanguage ?? 'Language',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            l10n?.settingsLanguageSubtitle ??
                'Choose between Arabic and English',
          ),
          trailing: DropdownButton<String>(
            value: currentCode,
            underline: const SizedBox.shrink(),
            borderRadius: BorderRadius.circular(12),
            onChanged: (code) async {
              if (code == null || code == currentCode) return;
              final cubit = context.read<LocaleCubit>();
              final saved = await cubit.setLocale(Locale(code));
              if (!saved && context.mounted) {
                AppFeedback.error(
                  context,
                  cubit.state.error ?? 'Language preference could not be saved.',
                );
              }
            },
            items: [
              DropdownMenuItem(
                value: 'en',
                child: Text(l10n?.settingsLanguageEn ?? 'English'),
              ),
              DropdownMenuItem(
                value: 'ar',
                child: Text(l10n?.settingsLanguageAr ?? 'العربية (Arabic)'),
              ),
            ],
          ),
        );
      },
    );
  }
}
