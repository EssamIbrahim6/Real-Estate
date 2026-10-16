import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';

Future<void> confirmSignOut(BuildContext context) async {
  if (context.read<AuthCubit>().state is AuthLoading) return;
  final l10n = AppLocalizations.of(context);
  final shouldSignOut = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(l10n?.profileSignOutDialogTitle ?? 'Sign out?'),
      content: Text(
        l10n?.profileSignOutDialogContent ??
            'You can sign back in at any time to access your account.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: Text(l10n?.commonCancel ?? 'Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: Text(l10n?.profileSignOutTitle ?? 'Sign out'),
        ),
      ],
    ),
  );
  if (shouldSignOut == true &&
      context.mounted &&
      context.read<AuthCubit>().state is! AuthLoading) {
    await context.read<AuthCubit>().signOut();
  }
}
