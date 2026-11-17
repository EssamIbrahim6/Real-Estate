import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_skeleton.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../home/presentation/widgets/estate_card.dart';
import '../cubit/favorites_cubit.dart';
import '../cubit/favorites_state.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(l10n?.favoritesTitle ?? 'Favorites'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        actions: [
          IconButton(
            tooltip: l10n?.commonRefresh ?? 'Refresh favorites',
            onPressed: () => context.read<FavoritesCubit>().loadFavorites(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: BlocBuilder<FavoritesCubit, FavoritesState>(
        builder: (context, state) {
          final colors = Theme.of(context).colorScheme;
          if (state.status == FavoritesStatus.loading ||
              state.status == FavoritesStatus.initial) {
            return const EstateListSkeleton();
          }

          if (state.status == FavoritesStatus.error) {
            final cubit = context.read<FavoritesCubit>();
            return AppErrorView(
              message:
                  state.error ??
                  l10n?.favoritesLoadError ??
                  'Favorites could not be loaded.',
              onRetry: () {
                if (cubit.isAuthenticated) {
                  cubit.loadFavorites();
                } else {
                  context.push(AppRoutes.login);
                }
              },
            );
          }

          if (state.estates.isEmpty) {
            return AppEmptyState(
              icon: Icons.favorite_outline,
              title: state.unavailableCount > 0
                  ? (l10n?.favoritesUnavailableNotice ??
                        'Your saved properties are currently unavailable.')
                  : (l10n?.favoritesEmpty ??
                        'You have not saved any properties yet.'),
            );
          }

          return Column(
            children: [
              Container(
                margin: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: colors.outlineVariant),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: colors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(Icons.favorite_rounded, color: colors.error),
                    ),
                    const SizedBox(width: 13),
                    Expanded(
                      child: Text(
                        l10n?.profileFavoritesSubtitle ??
                            'Properties you have saved',
                        style: Theme.of(context).textTheme.titleSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 13,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: colors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        '${state.estates.length}',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (state.unavailableCount > 0)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: Text(
                    l10n?.favoritesUnavailableNotice ??
                        'Some saved properties are no longer available.',
                    style: TextStyle(color: colors.onSurfaceVariant),
                  ),
                ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  itemCount: state.estates.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final estate = state.estates[index];
                    return EstateCard(
                      estate: estate,
                      width: MediaQuery.sizeOf(context).width - 40,
                      onTap: () => context.pushNamed(
                        AppRoutes.propertyDetailsName,
                        pathParameters: {'estateId': estate.id},
                        extra: estate,
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
