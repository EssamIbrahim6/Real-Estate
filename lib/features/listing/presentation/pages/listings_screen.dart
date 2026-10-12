import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../../../home/presentation/widgets/estate_card.dart';
import '../cubit/listing_cubit.dart';
import '../cubit/listing_state.dart';

class ListingsScreen extends StatelessWidget {
  final ListingRequest? request;

  const ListingsScreen({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: BlocBuilder<ListingCubit, ListingState>(
          builder: (context, state) => Text(state.title),
        ),
      ),
      body: BlocBuilder<ListingCubit, ListingState>(
        builder: (context, state) {
          switch (state.status) {
            case ListingStatus.initial:
            case ListingStatus.loading:
              return const AppLoadingIndicator(
                message: 'Loading properties...',
              );
            case ListingStatus.error:
              return AppErrorView(
                message: state.error ?? 'Failed to load properties.',
                onRetry: () => context.read<ListingCubit>().load(request),
              );
            case ListingStatus.success:
              if (state.estates.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppDimensions.p20),
                    child: Text(
                      'No properties found.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textSecondary),
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
