import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'core/theme/theme_cubit.dart';
import 'core/constants/app_strings.dart';
import 'core/cubits/connectivity/connectivity_cubit.dart';
import 'core/di/injection_container.dart' as di;
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

class RealEstateApp extends StatelessWidget {
  const RealEstateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => di.sl<ConnectivityCubit>()),
        BlocProvider(create: (_) => di.sl<ThemeCubit>()..loadPreference()),
      ],
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return BlocBuilder<ThemeCubit, ThemeState>(
            builder: (context, themeState) => MaterialApp.router(
              title: AppStrings.appName,
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeState.themeMode,
              routerConfig: AppRouter.router,
              builder: (context, child) =>
                  BlocBuilder<ConnectivityCubit, ConnectivityState>(
                    buildWhen: (previous, current) =>
                        previous.isConnected != current.isConnected,
                    builder: (context, state) => Column(
                      children: [
                        if (!state.isConnected)
                          Material(
                            color: Theme.of(context).colorScheme.errorContainer,
                            child: SafeArea(
                              bottom: false,
                              child: SizedBox(
                                width: double.infinity,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                  child: Text(
                                    'No internet connection. Some features may be unavailable.',
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onErrorContainer,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        Expanded(child: child ?? const SizedBox.shrink()),
                      ],
                    ),
                  ),
            ),
          );
        },
      ),
    );
  }
}
