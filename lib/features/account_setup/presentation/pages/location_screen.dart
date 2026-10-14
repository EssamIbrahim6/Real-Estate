import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/helpers/spacing.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../cubit/account_setup_cubit.dart';
import '../cubit/account_setup_state.dart';
import '../widgets/setup_progress_bar.dart';
import '../widgets/setup_step_header.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  final MapController _mapController = MapController();
  static const LatLng _defaultLocation = LatLng(
    30.0444,
    31.2357,
  ); // Cairo default fallback

  @override
  void initState() {
    super.initState();
    // Pre-request location if not already present in cubit state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cubit = context.read<AccountSetupCubit>();
      if (cubit.state.data.location == null) {
        cubit.requestCurrentLocation();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AccountSetupCubit, AccountSetupState>(
      listener: (context, state) {
        if (state is AccountSetupFailure) {
          AppFeedback.error(context, state.message);
        }
        if (state.data.location != null) {
          final loc = state.data.location!;
          _mapController.move(LatLng(loc.latitude, loc.longitude), 15);
        }
      },
      builder: (context, state) {
        final location = state.data.location;
        final currentPoint = location != null
            ? LatLng(location.latitude, location.longitude)
            : _defaultLocation;
        final isLocating = state is AccountSetupLocating;

        return Scaffold(
          backgroundColor: AppColors.surface,
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.p24,
                      vertical: 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () => context.pop(),
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColors.inputBackground,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.arrow_back_ios_new,
                                  size: 18,
                                  color: AppColors.brandNavy,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () => context.push(
                                AppRoutes.accountSetupPreferences,
                              ), // Skip to preferences
                              child: const Text(
                                'Skip',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        verticalSpace(16),
                        const SetupProgressBar(currentStep: 1),
                        verticalSpace(24),
                        const SetupStepHeader(
                          title: 'Add your location',
                          subtitle: 'You can share your current location or tap anywhere on the map to pinpoint your location.',
                        ),
                        verticalSpace(24),

                        // Interactive OpenStreetMap Widget
                        Container(
                          height: 280,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.inputBorder),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Stack(
                            children: [
                              FlutterMap(
                                mapController: _mapController,
                                options: MapOptions(
                                  initialCenter: currentPoint,
                                  initialZoom: 14.0,
                                  onTap: (tapPosition, point) {
                                    context
                                        .read<AccountSetupCubit>()
                                        .updateCoordinates(
                                          point.latitude,
                                          point.longitude,
                                        );
                                  },
                                ),
                                children: [
                                  TileLayer(
                                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                    userAgentPackageName:
                                        'com.example.real_estate_app',
                                  ),
                                  RichAttributionWidget(
                                    attributions: [
                                      TextSourceAttribution(
                                        'OpenStreetMap contributors',
                                        onTap: () {},
                                      ),
                                    ],
                                  ),
                                  MarkerLayer(
                                    markers: [
                                      Marker(
                                        point: currentPoint,
                                        width: 50,
                                        height: 50,
                                        child: const Icon(
                                          Icons.location_on,
                                          size: 46,
                                          color: AppColors.brandGreen,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Positioned(
                                right: 12,
                                bottom: 12,
                                child: FloatingActionButton.small(
                                  backgroundColor: AppColors.surface,
                                  onPressed: isLocating
                                      ? null
                                      : () => context
                                            .read<AccountSetupCubit>()
                                            .requestCurrentLocation(),
                                  child: isLocating
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: AppColors.brandNavy,
                                          ),
                                        )
                                      : const Icon(
                                          Icons.my_location,
                                          color: AppColors.brandNavy,
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        verticalSpace(20),

                        // Address Preview Field
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.inputBackground,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.inputBorder),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                color: AppColors.brandGreen,
                                size: 22,
                              ),
                              horizontalSpace(12),
                              Expanded(
                                child: Text(
                                  location?.address ?? 'Detecting address...',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.brandNavy,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Bottom Next Button
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.p24,
                    vertical: 16,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: location != null
                          ? () => context.push('/account-setup/preferences')
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.brandGreen,
                        disabledBackgroundColor: AppColors.brandGreen
                            .withValues(alpha: 0.3),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Next',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
