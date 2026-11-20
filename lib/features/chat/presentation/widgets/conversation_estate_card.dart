import 'package:flutter/material.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../../estate/domain/entities/estate_entity.dart';

class ConversationEstateCard extends StatelessWidget {
  const ConversationEstateCard({
    super.key,
    required this.estate,
    required this.onTap,
  });

  final EstateEntity estate;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final langCode = Localizations.localeOf(context).languageCode;
    final title = estate.localizedTitle(langCode);
    final address = estate.location.localizedAddress(langCode);
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colors.outlineVariant),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(13),
              child: Image.network(
                estate.coverImage,
                width: 66,
                height: 66,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  width: 66,
                  height: 66,
                  color: colors.surfaceContainerHighest,
                  child: Icon(
                    Icons.home_work_outlined,
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${estate.price.toInt()} ${l10n?.commonEgp ?? 'EGP'}',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: colors.tertiary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (address.isNotEmpty)
                    Text(
                      address,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelMedium
                          ?.copyWith(color: colors.onSurfaceVariant),
                    ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: colors.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}
