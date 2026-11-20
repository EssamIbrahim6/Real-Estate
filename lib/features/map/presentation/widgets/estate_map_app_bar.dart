import 'package:flutter/material.dart';

import '../../../../l10n/generated/app_localizations.dart';

class EstateMapAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback onBack;
  final VoidCallback onRefresh;

  const EstateMapAppBar({
    super.key,
    required this.title,
    required this.onBack,
    required this.onRefresh,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded),
        onPressed: onBack,
      ),
      title: Text(title),
      actions: [
        IconButton(
          tooltip: l10n?.mapRefresh ?? 'Refresh',
          icon: const Icon(Icons.refresh_rounded),
          onPressed: onRefresh,
        ),
      ],
    );
  }
}
