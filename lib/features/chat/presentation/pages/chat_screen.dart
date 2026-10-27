import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_skeleton.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../cubit/chat_cubit.dart';
import '../cubit/chat_state.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, this.currentUserUid});

  final String? currentUserUid;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final String? _currentUserUid;

  @override
  void initState() {
    super.initState();
    final uid =
        (widget.currentUserUid ?? FirebaseAuth.instance.currentUser?.uid)
            ?.trim();
    _currentUserUid = uid != null && uid.isNotEmpty ? uid : null;
    if (_currentUserUid != null) {
      context.read<ChatCubit>().watchConversations(_currentUserUid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n?.navChat ?? 'Chat')),
      body: _currentUserUid == null
          ? const _ChatAuthenticationRequired()
          : BlocBuilder<ChatCubit, ChatState>(
              builder: (context, state) {
                switch (state.conversationsStatus) {
                  case ChatLoadStatus.initial:
                  case ChatLoadStatus.loading:
                    return const ChatListSkeleton();
                  case ChatLoadStatus.failure:
                    return AppErrorView(
                      message: l10n?.commonError ??
                          'Could not load conversations. Please try again.',
                      onRetry: () => context
                          .read<ChatCubit>()
                          .watchConversations(_currentUserUid),
                    );
                  case ChatLoadStatus.empty:
                    return const _EmptyConversations();
                  case ChatLoadStatus.success:
                    if (state.conversations.isEmpty) {
                      return const _EmptyConversations();
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 16,
                      ),
                      itemCount: state.conversations.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 4),
                      itemBuilder: (context, index) {
                        final conversation = state.conversations[index];
                        final currentUserIsCustomer =
                            conversation.customerId == _currentUserUid;
                        final participantName = currentUserIsCustomer
                            ? 'Agent'
                            : 'Customer';
                        final readAt = conversation
                            .lastReadAtByParticipant[_currentUserUid];
                        final isUnread =
                            conversation.lastMessage != null &&
                            conversation.lastSenderId != _currentUserUid &&
                            (readAt == null ||
                                (conversation.lastMessageAt != null &&
                                    conversation.lastMessageAt!.isAfter(
                                      readAt,
                                    )));

                        return Card(
                          margin: EdgeInsets.zero,
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            leading: CircleAvatar(
                              backgroundColor: AppColors.primary.withAlpha(26),
                              child: Icon(
                                currentUserIsCustomer
                                    ? Icons.support_agent
                                    : Icons.person_outline,
                                color: AppColors.primary,
                              ),
                            ),
                            title: Text(
                              participantName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: isUnread
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                            ),
                            subtitle: Text(
                              conversation.lastMessage ??
                                  l10n?.chatInquiry ??
                                  'Property inquiry',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: isUnread
                                    ? Theme.of(context).colorScheme.onSurface
                                    : Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                              ),
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  _formatConversationTime(
                                    conversation.lastMessageAt,
                                    context,
                                  ),
                                  style: Theme.of(context).textTheme.labelSmall,
                                ),
                                if (isUnread) ...[
                                  const SizedBox(height: 6),
                                  const CircleAvatar(
                                    radius: 5,
                                    backgroundColor: AppColors.secondary,
                                  ),
                                ],
                              ],
                            ),
                            onTap: () => context.pushNamed(
                              AppRoutes.chatConversationName,
                              pathParameters: {
                                'conversationId': conversation.id,
                              },
                              queryParameters: {
                                'title': participantName,
                                if (conversation.estateId != null &&
                                    conversation.estateId!.isNotEmpty)
                                  'estateId': conversation.estateId,
                              },
                            ),
                          ),
                        );
                      },
                    );
                }
              },
            ),
    );
  }
}

class _EmptyConversations extends StatelessWidget {
  const _EmptyConversations();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 48,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              l10n?.chatEmptyTitle ?? 'No conversations yet',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              l10n?.chatEmptyMessage ??
                  'Start a conversation with an agent from a property.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatAuthenticationRequired extends StatelessWidget {
  const _ChatAuthenticationRequired();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Text(
        l10n?.chatAuthRequired ?? 'Sign in to view your conversations.',
      ),
    );
  }
}

String _formatConversationTime(DateTime? timestamp, BuildContext context) {
  if (timestamp == null) return '';
  final now = DateTime.now();
  final localTime = timestamp.toLocal();
  if (now.year == localTime.year &&
      now.month == localTime.month &&
      now.day == localTime.day) {
    return TimeOfDay.fromDateTime(localTime).format(context);
  }
  return '${localTime.month}/${localTime.day}/${localTime.year}';
}
