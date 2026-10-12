import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/helpers/spacing.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../../../listing/presentation/cubit/listing_cubit.dart';
import '../cubit/home_cubit.dart';
import '../cubit/home_state.dart';
import '../widgets/agent_card.dart';
import '../widgets/category_card.dart';
import '../widgets/estate_card.dart';
import '../widgets/home_header.dart';
import '../widgets/home_search_bar.dart';
import '../widgets/location_card.dart';
import '../widgets/section_header.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
            if (state.status == HomeStatus.loading &&
                state.featuredEstates.isEmpty) {
              return const AppLoadingIndicator(
                message: 'Loading properties...',
              );
            }

            return RefreshIndicator(
              color: AppColors.brandGreen,
              onRefresh: () => context.read<HomeCubit>().loadHome(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.p20,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Header
                    HomeHeader(locationName: state.currentLocationName),
                    verticalSpace(18),

                    // 2. Property search
                    HomeSearchBar(
                      onSearchTap: () => context.go(AppRoutes.search),
                    ),
                    verticalSpace(24),

                    // 3. Property Categories
                    const SectionHeader(title: 'Categories'),
                    verticalSpace(12),
                    if (state.categoriesError != null)
                      Text(
                        state.categoriesError!,
                        style: const TextStyle(
                          color: AppColors.error,
                          fontSize: 13,
                        ),
                      )
                    else if (state.categories.isEmpty)
                      const Text(
                        'No categories available right now.',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      )
                    else
                      SizedBox(
                        height: 92,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: state.categories.length,
                          separatorBuilder: (_, __) => horizontalSpace(10),
                          itemBuilder: (context, index) {
                            final category = state.categories[index];
                            return CategoryCard(
                              category: category,
                              onTap: () => context.pushNamed(
                                AppRoutes.categoryListingsName,
                                pathParameters: {'categoryId': category.id},
                                queryParameters: {'name': category.name},
                              ),
                            );
                          },
                        ),
                      ),
                    verticalSpace(24),

                    // 4. Featured Estates Section
                    SectionHeader(
                      title: 'Featured Estates',
                      onSeeAll: () => context.pushNamed(
                        AppRoutes.listingsName,
                        pathParameters: {'type': 'featured'},
                        queryParameters: {'title': 'Featured Estates'},
                      ),
                    ),
                    verticalSpace(12),
                    if (state.featuredError != null)
                      Text(
                        state.featuredError!,
                        style: const TextStyle(
                          color: AppColors.error,
                          fontSize: 13,
                        ),
                      )
                    else if (state.featuredEstates.isEmpty)
                      const Text(
                        'No featured estates available right now.',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      )
                    else
                      SizedBox(
                        // height: 255,
                        height: 275,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: state.featuredEstates.length,
                          separatorBuilder: (_, __) => horizontalSpace(14),
                          itemBuilder: (context, index) {
                            final estate = state.featuredEstates[index];
                            return EstateCard(
                              estate: estate,
                              onTap: () {
                                context.push(
                                  '${AppRoutes.propertyDetails}/${estate.id}',
                                  extra: estate,
                                );
                              },
                            );
                          },
                        ),
                      ),
                    verticalSpace(24),

                    // 5. Top Locations Section
                    const SectionHeader(title: 'Top Locations'),
                    verticalSpace(12),
                    if (state.topLocations.isEmpty)
                      const Text(
                        'No location data available right now.',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      )
                    else
                      SizedBox(
                        height: 110,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: state.topLocations.length,
                          separatorBuilder: (_, __) => horizontalSpace(12),
                          itemBuilder: (context, index) {
                            final location = state.topLocations[index];
                            return LocationCard(
                              location: location,
                              onTap: () => context.pushNamed(
                                AppRoutes.listingsName,
                                pathParameters: {'type': 'city'},
                                queryParameters: {
                                  'city': location.city,
                                  'title': location.city,
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    verticalSpace(24),

                    // 6. Top Estate Agents Section
                    const SectionHeader(title: 'Top Estate Agents'),
                    verticalSpace(12),
                    if (state.agentsError != null)
                      Text(
                        state.agentsError!,
                        style: const TextStyle(
                          color: AppColors.error,
                          fontSize: 13,
                        ),
                      )
                    else if (state.topAgents.isEmpty)
                      const Text(
                        'No agents available right now.',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      )
                    else
                      SizedBox(
                        // height: 125,
                        height: 140,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: state.topAgents.length,
                          separatorBuilder: (_, __) => horizontalSpace(12),
                          itemBuilder: (context, index) {
                            final agent = state.topAgents[index];
                            return AgentCard(
                              agent: agent,
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Agent: ${agent.agencyName}'),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    verticalSpace(24),

                    // 7. Explore Nearby Estates Section
                    SectionHeader(
                      title: 'Explore Nearby Estates',
                      onSeeAll: () async {
                        final homeCubit = context.read<HomeCubit>();
                        await homeCubit.requestLocationPermission();
                        if (!context.mounted) return;
                        final homeState = homeCubit.state;
                        if (!homeState.isLocationPermissionGranted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Enable location access to see nearby properties.',
                              ),
                            ),
                          );
                          return;
                        }
                        context.pushNamed(
                          AppRoutes.listingsName,
                          pathParameters: {'type': 'nearby'},
                          extra: ListingRequest(
                            type: ListingType.nearby,
                            title: 'Nearby Estates',
                            estates: homeState.nearbyEstates,
                            distancesKm: homeState.estateDistancesKm,
                          ),
                        );
                      },
                    ),
                    verticalSpace(12),
                    if (!state.isLocationPermissionGranted)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.inputBackground,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.inputBorder),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.location_disabled_rounded,
                              color: AppColors.textSecondary,
                              size: 28,
                            ),
                            horizontalSpace(14),
                            const Expanded(
                              child: Text(
                                'Enable location to explore estates near you.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.brandNavy,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () => context
                                  .read<HomeCubit>()
                                  .requestLocationPermission(),
                              child: const Text(
                                'Enable',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.brandGreen,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    else if (state.nearbyEstates.isEmpty)
                      const Text(
                        'No estates found near your location.',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      )
                    else
                      SizedBox(
                        //height: 255,
                        height: 275,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: state.nearbyEstates.length,
                          separatorBuilder: (_, __) => horizontalSpace(14),
                          itemBuilder: (context, index) {
                            final estate = state.nearbyEstates[index];
                            final distance = state.estateDistancesKm[estate.id];
                            return EstateCard(
                              estate: estate,
                              distanceKm: distance,
                              onTap: () {
                                context.push(
                                  '${AppRoutes.propertyDetails}/${estate.id}',
                                  extra: estate,
                                );
                              },
                            );
                          },
                        ),
                      ),
                    verticalSpace(24),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
