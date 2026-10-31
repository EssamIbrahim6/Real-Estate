import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/notifications_cubit.dart';

/// A small badge that sits on top of the bell icon showing unread count.
class NotificationBadge extends StatelessWidget {
  final Widget child;

  const NotificationBadge({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationsCubit, NotificationsState>(
      buildWhen: (prev, curr) => prev.unreadCount != curr.unreadCount,
      builder: (context, state) {
        if (!state.hasUnread) return child;
        return Badge(
          label: state.unreadCount > 9
              ? const Text('9+')
              : Text('${state.unreadCount}'),
          child: child,
        );
      },
    );
  }
}

