import 'dart:async';

import 'package:flutter/material.dart';

enum AppFeedbackType { success, error, info }

abstract final class AppFeedback {
  static OverlayEntry? _entry;
  static Timer? _dismissTimer;
  static String? _activeMessage;

  static void success(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) => _show(context, message, AppFeedbackType.success, duration);

  static void error(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 4),
  }) => _show(context, message, AppFeedbackType.error, duration);

  static void info(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) => _show(context, message, AppFeedbackType.info, duration);

  static void _show(
    BuildContext context,
    String message,
    AppFeedbackType type,
    Duration duration,
  ) {
    if (message.trim().isEmpty || !context.mounted) return;
    if (_activeMessage == message) return;
    _removeCurrent();

    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) {
      throw StateError('AppFeedback requires a mounted Overlay.');
    }

    final entry = OverlayEntry(
      builder: (context) => _FeedbackOverlay(message: message, type: type),
    );
    _entry = entry;
    _activeMessage = message;
    overlay.insert(entry);
    _dismissTimer = Timer(duration, _removeCurrent);
  }

  static void _removeCurrent() {
    _dismissTimer?.cancel();
    _dismissTimer = null;
    final entry = _entry;
    _entry = null;
    _activeMessage = null;
    if (entry != null) {
      entry.remove();
      entry.dispose();
    }
  }
}

class _FeedbackOverlay extends StatelessWidget {
  final String message;
  final AppFeedbackType type;

  const _FeedbackOverlay({required this.message, required this.type});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final icon = switch (type) {
      AppFeedbackType.success => Icons.check_circle_outline_rounded,
      AppFeedbackType.error => Icons.error_outline_rounded,
      AppFeedbackType.info => Icons.info_outline_rounded,
    };
    final accent = switch (type) {
      AppFeedbackType.success => colors.tertiary,
      AppFeedbackType.error => colors.error,
      AppFeedbackType.info => colors.primary,
    };

    return Positioned(
      left: 16,
      right: 16,
      bottom: 72,
      child: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) => Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 12 * (1 - value)),
                  child: child,
                ),
              ),
              child: Semantics(
                liveRegion: true,
                child: Material(
                  color: colors.inverseSurface,
                  elevation: 8,
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    child: Row(
                      children: [
                        Icon(icon, color: accent, size: 21),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            message,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: colors.onInverseSurface),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
