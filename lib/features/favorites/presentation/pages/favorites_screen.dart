import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
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
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      state.error ??
                          l10n?.favoritesLoadError ??
                          'Favorites could not be loaded.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: colors.onSurfaceVariant),
                    ),
                    const SizedBox(height: 12),
                    if (!cubit.isAuthenticated)
                      FilledButton(
                        onPressed: () => context.push(AppRoutes.login),
                        child: Text(l10n?.favoritesSignInButton ?? 'Sign in'),
                      )
                    else
                      TextButton(
                        onPressed: cubit.loadFavorites,
                        child: Text(l10n?.commonRetry ?? 'Try again'),
                      ),
                  ],
                ),
              ),
            );
          }

          if (state.estates.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  state.unavailableCount > 0
                      ? (l10n?.favoritesUnavailableNotice ??
                          'Your saved properties are currently unavailable.')
                      : (l10n?.favoritesEmpty ??
                          'You have not saved any properties yet.'),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: colors.onSurfaceVariant),
                ),
              ),
            );
          }

          return Column(
            children: [
              if (state.unavailableCount > 0)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                  child: Text(
                    l10n?.favoritesUnavailableNotice ??
                        'Some saved properties are no longer available.',
                    style: TextStyle(color: colors.onSurfaceVariant),
                  ),
                ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(20),
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
