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
import '../../../home/presentation/widgets/estate_card.dart';
import '../cubit/listing_cubit.dart';
import '../cubit/listing_state.dart';

/// Category-specific listing screen.
/// Receives a [ListingRequest] from the GoRouter via [request].
class CategoryEstatesScreen extends StatelessWidget {
  final ListingRequest? request;

  const CategoryEstatesScreen({super.key, required this.request});

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
                message: 'Loading estates...',
              );
            case ListingStatus.error:
              return AppErrorView(
                message: state.error ?? 'Failed to load estates.',
                onRetry: () =>
                    context.read<ListingCubit>().load(request),
              );
            case ListingStatus.success:
              if (state.estates.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppDimensions.p20),
                    child: Text(
                      'No estates found for this category.',
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
