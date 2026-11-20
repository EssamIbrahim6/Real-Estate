import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';

class ConnectivityGate extends StatelessWidget {
  const ConnectivityGate({
    super.key,
    required this.isChecking,
    required this.onRetry,
  });

  final bool isChecking;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return Material(
      color: theme.scaffoldBackgroundColor,
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      color: colors.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isChecking
                          ? Icons.wifi_find_rounded
                          : Icons.wifi_off_rounded,
                      size: 34,
                      color: colors.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 22),
                  Text(
                    isChecking
                        ? (l10n?.connectionChecking ?? 'Checking connection')
                        : (l10n?.offlineTitle ?? 'You are offline'),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    isChecking
                        ? (l10n?.connectionCheckingDescription ??
                              'Please wait while we check your internet connection.')
                        : (l10n?.offlineDescription ??
                              'Connect to the internet to continue using the app.'),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (isChecking)
                    const CircularProgressIndicator()
                  else
                    FilledButton.icon(
                      onPressed: onRetry,
                      icon: const Icon(Icons.refresh_rounded),
                      label: Text(l10n?.commonRetry ?? 'Try again'),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
