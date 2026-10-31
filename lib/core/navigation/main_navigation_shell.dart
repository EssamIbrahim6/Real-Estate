import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../constants/app_dimensions.dart';
import '../../l10n/generated/app_localizations.dart';

class MainNavigationShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainNavigationShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final items = [
      _NavigationItem(
        icon: Icons.home_rounded,
        label: l10n?.navHome ?? 'Home',
      ),
      _NavigationItem(
        icon: Icons.search_rounded,
        label: l10n?.navSearch ?? 'Search',
      ),
      _NavigationItem(
        icon: Icons.chat_bubble_rounded,
        label: l10n?.navChat ?? 'Messages',
      ),
      _NavigationItem(
        icon: Icons.person_rounded,
        label: l10n?.navProfile ?? 'Profile',
      ),
    ];

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: navigationShell,
      bottomNavigationBar: MediaQuery.viewInsetsOf(context).bottom > 0
          ? null
          : SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppDimensions.p16,
                  AppDimensions.p8,
                  AppDimensions.p16,
                  AppDimensions.p8,
                ),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(AppDimensions.rFull),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(
                          context,
                        ).colorScheme.shadow.withValues(alpha: 0.07),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                  ),
                  child: SizedBox(
                    height: 64,
                    child: Row(
                      children: [
                        for (var index = 0; index < items.length; index++)
                          Expanded(
                            child: _NavigationDestination(
                              item: items[index],
                              selected: navigationShell.currentIndex == index,
                              onTap: () => navigationShell.goBranch(
                                index,
                                initialLocation:
                                    index == navigationShell.currentIndex,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}

class _NavigationItem {
  final IconData icon;
  final String label;

  const _NavigationItem({required this.icon, required this.label});
}

class _NavigationDestination extends StatelessWidget {
  final _NavigationItem item;
  final bool selected;
  final VoidCallback onTap;

  const _NavigationDestination({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final foreground = selected ? colors.primary : colors.onSurfaceVariant;
    return Semantics(
      label: item.label,
      button: true,
      selected: selected,
      child: Tooltip(
        message: item.label,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 2,
            vertical: 4,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(AppDimensions.rFull),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.p6,
                  vertical: AppDimensions.p4,
                ),
                decoration: BoxDecoration(
                  color: selected
                      ? colors.primary.withValues(alpha: 0.11)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppDimensions.rFull),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    AnimatedScale(
                      scale: selected ? 1.05 : 1,
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOutCubic,
                      child: Icon(item.icon, color: foreground, size: 22),
                    ),
                    Flexible(
                      child: AnimatedSize(
                        duration: const Duration(milliseconds: 180),
                        curve: Curves.easeOutCubic,
                        alignment: AlignmentDirectional.centerStart,
                        child: selected
                            ? Padding(
                                padding: const EdgeInsetsDirectional.only(
                                  start: AppDimensions.p6,
                                ),
                                child: Text(
                                  item.label,
                                  maxLines: 1,
                                  softWrap: false,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.labelMedium
                                      ?.copyWith(
                                        color: foreground,
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
