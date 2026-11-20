import 'package:flutter/material.dart';

class ConversationAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const ConversationAppBar({
    super.key,
    required this.title,
    required this.onBack,
  });

  final String title;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return AppBar(
      leading: BackButton(onPressed: onBack),
      title: Row(
        children: [
          CircleAvatar(
            radius: 17,
            backgroundColor: colors.primary.withValues(alpha: 0.1),
            child: Icon(
              Icons.support_agent_rounded,
              size: 20,
              color: colors.primary,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
