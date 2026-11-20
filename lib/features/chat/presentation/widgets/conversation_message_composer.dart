import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../cubit/chat_cubit.dart';
import '../cubit/chat_state.dart';

class ConversationMessageComposer extends StatelessWidget {
  const ConversationMessageComposer({
    super.key,
    required this.controller,
    required this.enabled,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool enabled;
  final Future<void> Function() onSend;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
        decoration: BoxDecoration(
          color: colors.surface,
          border: Border(top: BorderSide(color: colors.outlineVariant)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                key: const ValueKey<String>('message-composer'),
                controller: controller,
                enabled: enabled,
                minLines: 1,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                textAlign: TextAlign.start,
                decoration: InputDecoration(
                  hintText: enabled
                      ? (l10n?.chatMessageHint ?? 'Write a message...')
                      : (l10n?.chatSignInToSend ?? 'Sign in to send a message'),
                  filled: true,
                  fillColor: colors.surfaceContainerLow,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(26),
                    borderSide: BorderSide(color: colors.outlineVariant),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(26),
                    borderSide: BorderSide(color: colors.outlineVariant),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 9),
            BlocBuilder<ChatCubit, ChatState>(
              buildWhen: (previous, current) =>
                  previous.isSending != current.isSending,
              builder: (context, state) => IconButton.filled(
                key: const ValueKey<String>('send-message'),
                style: IconButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: colors.onPrimary,
                  disabledBackgroundColor: colors.surfaceContainerHigh,
                  disabledForegroundColor: colors.onSurfaceVariant,
                ),
                onPressed: enabled && !state.isSending ? () => onSend() : null,
                icon: state.isSending
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colors.onPrimary,
                        ),
                      )
                    : const Icon(Icons.send_rounded),
                tooltip: l10n?.chatSendTooltip ?? 'Send message',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
