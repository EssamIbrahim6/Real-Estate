import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';

Future<void> confirmSignOut(BuildContext context) async {
  if (context.read<AuthCubit>().state is AuthLoading) return;
  final shouldSignOut = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Sign out?'),
      content: const Text(
        'You can sign back in at any time to access your account.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: const Text('Sign out'),
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
