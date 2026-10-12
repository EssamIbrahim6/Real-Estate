import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:real_estate_app/features/estate_details/presentation/cubit/estate_details_cubit.dart';
import 'package:real_estate_app/features/estate_details/presentation/pages/estate_details_screen.dart';
import 'package:real_estate_app/features/home/presentation/cubit/home_cubit.dart';
import 'package:real_estate_app/features/home/presentation/pages/home_screen.dart';
import 'package:real_estate_app/features/estate_details/presentation/pages/fullscreen_gallery_screen.dart';
import 'package:real_estate_app/features/listing/presentation/cubit/listing_cubit.dart';
import 'package:real_estate_app/features/listing/presentation/pages/category_estates_screen.dart';
import 'package:real_estate_app/features/listing/presentation/pages/listings_screen.dart';
import 'package:real_estate_app/features/search/presentation/cubit/search_cubit.dart';
import 'package:real_estate_app/features/search/presentation/pages/search_screen.dart';
import 'package:real_estate_app/features/chat/presentation/pages/chat_screen.dart';
import 'package:real_estate_app/features/chat/presentation/pages/conversation_screen.dart';
import 'package:real_estate_app/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:real_estate_app/features/profile/presentation/pages/profile_screen.dart';

import '../di/injection_container.dart';
import '../navigation/main_navigation_shell.dart';
import 'route_names.dart';
import '../../features/estate/domain/entities/estate_entity.dart';

// Splash & Onboarding
import '../../features/splash/screens/splash_screen.dart';
import '../../features/onboarding/screens/onboarding_screen_1.dart';

// Auth
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/auth/presentation/pages/forgot_password_screen.dart';
import '../../features/auth/presentation/pages/login_screen.dart';
import '../../features/auth/presentation/pages/otp_verification_screen.dart';
import '../../features/auth/presentation/pages/register_screen.dart';
import '../../features/auth/presentation/pages/welcome_screen.dart';

// Support
import '../../features/support/presentation/pages/faq_support_screen.dart';

// Account Setup
import '../../features/account_setup/presentation/cubit/account_setup_cubit.dart';
import '../../features/account_setup/presentation/pages/account_success_screen.dart';
import '../../features/account_setup/presentation/pages/location_screen.dart';
import '../../features/account_setup/presentation/pages/payment_method_screen.dart';
import '../../features/account_setup/presentation/pages/personal_info_screen.dart';
import '../../features/account_setup/presentation/pages/real_estate_preferences_screen.dart';

class AppRouter {
  static final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'rootNav');
  static final GlobalKey<NavigatorState> _homeNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'homeNav');
  static final GlobalKey<NavigatorState> _searchNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'searchNav');
  static final GlobalKey<NavigatorState> _chatNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'chatNav');
  static final GlobalKey<NavigatorState> _profileNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'profileNav');

  static final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.root, // Starts at Splash
    routes: [
      // Splash
      GoRoute(
        path: AppRoutes.root,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // Onboarding
      GoRoute(
        path: AppRoutes.onBoarding,
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),

      // Auth Routes
      GoRoute(
        path: AppRoutes.welcome,
        name: 'welcome',
        builder: (context, state) => BlocProvider(
          create: (_) => sl<AuthCubit>(),
          child: const WelcomeScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => BlocProvider(
          create: (_) => sl<AuthCubit>(),
          child: const LoginScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.register,
        name: 'register',
        builder: (context, state) => BlocProvider(
          create: (_) => sl<AuthCubit>(),
          child: const RegisterScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        name: 'forgot-password',
        builder: (context, state) => BlocProvider(
          create: (_) => sl<AuthCubit>(),
          child: const ForgotPasswordScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.otpVerification,
        name: 'otp-verification',
        builder: (context, state) {
          final email = state.extra as String? ?? 'user@example.com';
          return BlocProvider(
            create: (_) => sl<AuthCubit>(),
            child: OtpVerificationScreen(email: email),
          );
        },
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainNavigationShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            navigatorKey: _homeNavigatorKey,
            routes: [
              GoRoute(
                path: AppRoutes.home,
                name: 'home',
                builder: (context, state) => BlocProvider(
                  create: (_) => sl<HomeCubit>()..loadHome(),
                  child: const HomeScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _searchNavigatorKey,
            routes: [
              GoRoute(
                path: AppRoutes.search,
                name: 'search',
                builder: (context, state) => BlocProvider(
                  create: (_) => sl<SearchCubit>(),
                  child: const SearchScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _chatNavigatorKey,
            routes: [
              GoRoute(
                path: AppRoutes.chat,
                name: 'chat',
                builder: (context, state) => BlocProvider(
                  create: (_) => sl<ChatCubit>(),
                  child: const ChatScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _profileNavigatorKey,
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                name: 'profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.chatConversation,
        name: AppRoutes.chatConversationName,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => BlocProvider(
          create: (_) => sl<ChatCubit>(),
          child: ConversationScreen(
            conversationId: state.pathParameters['conversationId'] ?? '',
            title: state.uri.queryParameters['title'] ?? 'Agent',
            currentUserUid: FirebaseAuth.instance.currentUser?.uid,
          ),
        ),
      ),
      // Support
      GoRoute(
        path: AppRoutes.faqSupport,
        name: 'faq-support',
        builder: (context, state) => const FaqSupportScreen(),
      ),

      // Account Setup Flow: Persistent Single Cubit across all 4 screens
      ShellRoute(
        builder: (context, state, child) {
          return BlocProvider<AccountSetupCubit>(
            create: (_) => sl<AccountSetupCubit>(),
            child: child,
          );
        },
        routes: [
          GoRoute(
            path: AppRoutes.accountSetupLocation,
            name: 'account-setup-location',
            builder: (context, state) => const LocationScreen(),
          ),
          GoRoute(
            path: AppRoutes.accountSetupPreferences,
            name: 'account-setup-preferences',
            builder: (context, state) => const RealEstatePreferencesScreen(),
          ),
          GoRoute(
            path: AppRoutes.accountSetupPayment,
            name: 'account-setup-payment',
            builder: (context, state) => const PaymentMethodScreen(),
          ),
          GoRoute(
            path: AppRoutes.accountSetupPersonalInfo,
            name: 'account-setup-personal-info',
            builder: (context, state) => const PersonalInfoScreen(),
          ),
        ],
      ),

      // Account Setup Success (outside the shell)
      GoRoute(
        path: AppRoutes.accountSetupSuccess,
        name: 'account-setup-success',
        builder: (context, state) => const AccountSuccessScreen(),
      ),
      GoRoute(
        path: '${AppRoutes.propertyDetails}/:estateId',
        name: 'property-details',
        builder: (context, state) {
          final estateId = state.pathParameters['estateId'] ?? '';
          final estate = state.extra is EstateEntity
              ? state.extra as EstateEntity
              : null;
          return BlocProvider(
            create: (_) =>
                sl<EstateDetailsCubit>()
                  ..loadEstateDetails(estateId, initialEstate: estate),
            child: EstateDetailsScreen(estateId: estateId),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.categoryListings,
        name: AppRoutes.categoryListingsName,
        builder: (context, state) {
          final categoryId = state.pathParameters['categoryId']?.trim() ?? '';
          final categoryName = state.uri.queryParameters['name']?.trim();
          final request = categoryId.isEmpty
              ? null
              : ListingRequest(
                  type: ListingType.category,
                  title: categoryName?.isNotEmpty == true
                      ? categoryName!
                      : 'Category Listings',
                  categoryId: categoryId,
                );
          if (request == null) {
            return const Scaffold(
              body: Center(child: Text('The category ID is invalid.')),
            );
          }
          return BlocProvider(
            create: (_) => sl<ListingCubit>()..load(request),
            child: CategoryEstatesScreen(request: request),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.listings,
        name: AppRoutes.listingsName,
        builder: (context, state) {
          final type = state.pathParameters['type'];
          final title = state.uri.queryParameters['title']?.trim();
          final city = state.uri.queryParameters['city']?.trim();
          final routeType = switch (type) {
            'featured' => ListingType.featured,
            'all' => ListingType.all,
            'city' when city?.isNotEmpty == true => ListingType.city,
            'nearby' => ListingType.nearby,
            _ => null,
          };
          final extra = state.extra;
          final request = routeType == null
              ? null
              : routeType == ListingType.nearby
              ? extra is ListingRequest && extra.type == ListingType.nearby
                    ? extra
                    : null
              : ListingRequest(
                  type: routeType,
                  title: title?.isNotEmpty == true
                      ? title!
                      : routeType == ListingType.featured
                      ? 'Featured Estates'
                      : routeType == ListingType.city
                      ? city!
                      : 'All Estates',
                  city: routeType == ListingType.city ? city : null,
                );
          return BlocProvider(
            create: (_) => sl<ListingCubit>()..load(request),
            child: ListingsScreen(request: request),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.fullscreenGallery,
        name: AppRoutes.fullscreenGalleryName,
        builder: (context, state) {
          final request = state.extra;
          if (request is! FullscreenGalleryRequest) {
            return const Scaffold(
              body: Center(
                child: Text('The image gallery could not be opened.'),
              ),
            );
          }
          return FullscreenGalleryScreen(
            images: request.images,
            initialIndex: request.initialIndex,
          );
        },
      ),
      // Home Screen
      // GoRoute(
      //   path: AppRoutes.home,
      //   name: 'home',
      //   builder: (context, state) => Scaffold(
      //     appBar: AppBar(
      //       title: const Text('Real Estate Home'),
      //       actions: [
      //         IconButton(
      //           icon: const Icon(Icons.help_outline),
      //           onPressed: () => context.pushNamed('faq-support'),
      //         ),
      //       ],
      //     ),
      //     body: const Center(
      //       child: Text(
      //         'Welcome to your Dream Home!',
      //         style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      //       ),
      //     ),
      //   ),
      // ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: Center(child: Text('No route defined for ${state.uri.toString()}')),
    ),
  );
}
