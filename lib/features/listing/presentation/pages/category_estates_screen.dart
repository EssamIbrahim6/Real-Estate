// This file re-exports CategoryEstatesScreen which now lives in listings_screen.dart
// and receives a ListingRequest parameter from the router.
//
// This file exists only so existing imports still compile.
// Do not add new imports of CategoryEstatesScreen here —
// import from listings_screen.dart directly.
export 'listings_screen.dart' show ListingsScreen;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../home/presentation/widgets/estate_card.dart';
import '../cubit/listing_cubit.dart';
import '../cubit/listing_state.dart';
import '../../../map/domain/models/map_screen_args.dart';

/// Category-specific listing screen.
/// Receives a [ListingRequest] from the GoRouter via [request].
class CategoryEstatesScreen extends StatelessWidget {
  final ListingRequest? request;

  const CategoryEstatesScreen({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: BlocBuilder<ListingCubit, ListingState>(
          builder: (context, state) => Text(state.title),
        ),
        actions: [
          BlocBuilder<ListingCubit, ListingState>(
            builder: (context, state) => IconButton(
              tooltip: l10n?.searchViewOnMap ?? 'View on map',
              icon: const Icon(Icons.map_outlined),
              onPressed: () {
                context.push(
                  AppRoutes.map,
                  extra: MapScreenArgs(
                    estates: state.estates,
                    title: state.title,
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: BlocBuilder<ListingCubit, ListingState>(
        builder: (context, state) {
          switch (state.status) {
            case ListingStatus.initial:
            case ListingStatus.loading:
              return AppLoadingIndicator(
                message: l10n?.listingsLoading ?? 'Loading estates...',
              );
            case ListingStatus.error:
              return AppErrorView(
                message: state.error ??
                    l10n?.listingsLoading ??
                    'Failed to load estates.',
                onRetry: () => context.read<ListingCubit>().load(request),
              );
            case ListingStatus.success:
              if (state.estates.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppDimensions.p20),
                    child: Text(
                      l10n?.listingsCategoryEmpty ??
                          'No estates found for this category.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.all(AppDimensions.p20),
                itemCount: state.estates.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final estate = state.estates[index];
                  return EstateCard(
                    estate: estate,
                    width: double.infinity,
                    onTap: () => context.push(
                      '${AppRoutes.propertyDetails}/${estate.id}',
                      extra: estate,
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
