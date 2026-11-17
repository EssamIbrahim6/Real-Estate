import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../../core/widgets/app_empty_state.dart';
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
                      message:
                          l10n?.commonError ??
                          'Could not load conversations. Please try again.',
                      onRetry: () => context
                          .read<ChatCubit>()
                          .watchConversations(_currentUserUid),
                    );
                  case ChatLoadStatus.empty:
                    return AppEmptyState(
                      icon: Icons.chat_bubble_outline_rounded,
                      title: l10n?.chatEmptyTitle ?? 'No conversations yet',
                      description:
                          l10n?.chatEmptyMessage ??
                          'Start a conversation with an agent from a property.',
                    );
                  case ChatLoadStatus.success:
                    if (state.conversations.isEmpty) {
                      return AppEmptyState(
                        icon: Icons.chat_bubble_outline_rounded,
                        title: l10n?.chatEmptyTitle ?? 'No conversations yet',
                        description: l10n?.chatEmptyMessage ?? 'Start a conversation with an agent from a property.',
                      );
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
                        final colors = Theme.of(context).colorScheme;

                        return Material(
                          color: colors.surface,
                          borderRadius: BorderRadius.circular(22),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(22),
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
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(22),
                                border: Border.all(
                                  color: isUnread
                                      ? colors.primary.withValues(alpha: 0.4)
                                      : colors.outlineVariant,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      CircleAvatar(
                                        radius: 27,
                                        backgroundColor: colors.primary
                                            .withValues(alpha: 0.1),
                                        child: Icon(
                                          currentUserIsCustomer
                                              ? Icons.support_agent_rounded
                                              : Icons.person_outline_rounded,
                                          color: colors.primary,
                                          size: 25,
                                        ),
                                      ),
                                      if (isUnread)
                                        PositionedDirectional(
                                          end: -1,
                                          top: -1,
                                          child: Container(
                                            width: 13,
                                            height: 13,
                                            decoration: BoxDecoration(
                                              color: colors.tertiary,
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: colors.surface,
                                                width: 2,
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(width: 13),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                participantName,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleSmall
                                                    ?.copyWith(
                                                      fontWeight: isUnread
                                                          ? FontWeight.w800
                                                          : FontWeight.w600,
                                                    ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              _formatConversationTime(
                                                conversation.lastMessageAt,
                                                context,
                                              ),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .labelSmall
                                                  ?.copyWith(
                                                    color: isUnread
                                                        ? colors.primary
                                                        : colors
                                                              .onSurfaceVariant,
                                                  ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            if (conversation.estateId != null &&
                                                conversation
                                                    .estateId!
                                                    .isNotEmpty) ...[
                                              Icon(
                                                Icons.home_work_outlined,
                                                size: 15,
                                                color: colors.onSurfaceVariant,
                                              ),
                                              const SizedBox(width: 6),
                                            ],
                                            Expanded(
                                              child: Text(
                                                conversation.lastMessage ??
                                                    l10n?.chatInquiry ??
                                                    'Property inquiry',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall
                                                    ?.copyWith(
                                                      color: isUnread
                                                          ? colors.onSurface
                                                          : colors
                                                                .onSurfaceVariant,
                                                      fontWeight: isUnread
                                                          ? FontWeight.w600
                                                          : FontWeight.w400,
                                                    ),
                                              ),
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
                      },
                    );
                }
              },
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
