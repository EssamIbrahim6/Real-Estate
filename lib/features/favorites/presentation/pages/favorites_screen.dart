import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../../../home/presentation/widgets/estate_card.dart';
import '../cubit/favorites_cubit.dart';
import '../cubit/favorites_state.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Favorites'),
        backgroundColor: AppColors.background,
        actions: [
          IconButton(
            tooltip: 'Refresh favorites',
            onPressed: () => context.read<FavoritesCubit>().loadFavorites(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: BlocBuilder<FavoritesCubit, FavoritesState>(
        builder: (context, state) {
          if (state.status == FavoritesStatus.loading ||
              state.status == FavoritesStatus.initial) {
            return const Center(child: AppLoadingIndicator());
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
                      state.error ?? 'Favorites could not be loaded.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 12),
                    if (!cubit.isAuthenticated)
                      FilledButton(
                        onPressed: () => context.push(AppRoutes.login),
                        child: const Text('Sign in'),
                      )
                    else
                      TextButton(
                        onPressed: cubit.loadFavorites,
                        child: const Text('Try again'),
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
                      ? 'Your saved properties are currently unavailable.'
                      : 'You have not saved any properties yet.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ),
            );
          }

          return Column(
            children: [
              if (state.unavailableCount > 0)
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 8, 20, 12),
                  child: Text(
                    'Some saved properties are no longer available.',
                    style: TextStyle(color: AppColors.textSecondary),
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
