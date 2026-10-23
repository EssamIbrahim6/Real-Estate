import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_skeleton.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../home/presentation/widgets/estate_card.dart';
import '../cubit/listing_cubit.dart';
import '../cubit/listing_state.dart';
import '../../../map/domain/models/map_screen_args.dart';

class ListingsScreen extends StatelessWidget {
  final ListingRequest? request;

  const ListingsScreen({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
          final colors = Theme.of(context).colorScheme;
          switch (state.status) {
            case ListingStatus.initial:
            case ListingStatus.loading:
              return const EstateListSkeleton();
            case ListingStatus.error:
              return AppErrorView(
                message: state.error ??
                    l10n?.listingsLoading ??
                    'Failed to load properties.',
                onRetry: () => context.read<ListingCubit>().load(request),
              );
            case ListingStatus.success:
              if (state.estates.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppDimensions.p20),
                    child: Text(
                      l10n?.listingsEmpty ?? 'No properties found.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: colors.onSurfaceVariant),
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
                    distanceKm: state.distancesKm[estate.id],
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
