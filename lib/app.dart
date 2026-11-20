import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'core/constants/app_strings.dart';
import 'core/cubits/connectivity/connectivity_cubit.dart';
import 'core/di/dependency_injection.dart' as di;
import 'core/localization/locale_cubit.dart';
import 'core/localization/locale_state.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_cubit.dart';
import 'core/widgets/connectivity_gate.dart';
import 'features/notifications/presentation/cubit/notifications_cubit.dart';
import 'l10n/generated/app_localizations.dart';

class RealEstateApp extends StatelessWidget {
  const RealEstateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => di.sl<ConnectivityCubit>()),
        BlocProvider(create: (_) => di.sl<ThemeCubit>()..loadPreference()),
        BlocProvider(create: (_) => di.sl<LocaleCubit>()..loadPreference()),
        BlocProvider(create: (_) => di.sl<NotificationsCubit>()),
      ],
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return BlocBuilder<ThemeCubit, ThemeState>(
            builder: (context, themeState) {
              return BlocBuilder<LocaleCubit, LocaleState>(
                builder: (context, localeState) {
                  return MaterialApp.router(
                    title: AppStrings.appName,
                    debugShowCheckedModeBanner: false,
                    theme: AppTheme.lightTheme,
                    darkTheme: AppTheme.darkTheme,
                    themeMode: themeState.themeMode,
                    locale: localeState.locale,
                    supportedLocales: AppLocalizations.supportedLocales,
                    localizationsDelegates:
                        AppLocalizations.localizationsDelegates,
                    routerConfig: AppRouter.router,
                    builder: (context, child) =>
                        BlocBuilder<ConnectivityCubit, ConnectivityState>(
                          buildWhen: (previous, current) =>
                              previous.status != current.status,
                          builder: (context, state) {
                            return Stack(
                              fit: StackFit.expand,
                              children: [
                                child ?? const SizedBox.shrink(),
                                if (!state.isConnected)
                                  Positioned.fill(
                                    child: ConnectivityGate(
                                      isChecking:
                                          state.status ==
                                          ConnectivityStatus.checking,
                                      onRetry: () => context
                                          .read<ConnectivityCubit>()
                                          .retryConnectivity(),
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
