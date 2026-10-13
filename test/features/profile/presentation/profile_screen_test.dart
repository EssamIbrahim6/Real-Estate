import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_app/core/errors/failures.dart';
import 'package:real_estate_app/core/utils/typedefs.dart';
import 'package:real_estate_app/features/account_setup/domain/entities/user_profile_entity.dart';
import 'package:real_estate_app/features/account_setup/domain/repositories/account_setup_repository.dart';
import 'package:real_estate_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:real_estate_app/features/auth/presentation/cubit/auth_state.dart';
import 'package:real_estate_app/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:real_estate_app/features/profile/presentation/pages/profile_screen.dart';
import 'package:real_estate_app/features/profile/presentation/pages/settings_screen.dart';

void main() {
  testWidgets('shows real profile details and circular-avatar fallback', (
    tester,
  ) async {
    final profileCubit = ProfileCubit(
      firebaseAuth: _FakeFirebaseAuth(
        _FakeUser(
          uid: 'user-1',
          email: 'actual@example.com',
          displayName: 'Auth display name',
          photoURL: null,
          emailVerified: true,
        ),
      ),
      accountSetupRepository: _FakeAccountSetupRepository(
        profile: const UserProfileEntity(
          userId: 'user-1',
          name: 'Actual Firestore Name',
          email: 'stale@example.com',
          phone: '',
        ),
      ),
    );
    await profileCubit.loadProfile();
    final authCubit = _FakeAuthCubit();
    final router = _testRouter();
    addTearDown(() async {
      router.dispose();
      await profileCubit.close();
      await authCubit.close();
    });

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<ProfileCubit>.value(value: profileCubit),
          BlocProvider<AuthCubit>.value(value: authCubit),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Actual Firestore Name'), findsOneWidget);
    expect(find.text('actual@example.com'), findsOneWidget);
    expect(find.text('Email verified'), findsOneWidget);
    expect(find.byIcon(Icons.person), findsOneWidget);
  });

  testWidgets('navigates to existing Favorites and Edit Profile destinations', (
    tester,
  ) async {
    final profileCubit = ProfileCubit(
      firebaseAuth: _FakeFirebaseAuth(_FakeUser(uid: 'user-2')),
      accountSetupRepository: _FakeAccountSetupRepository(),
    );
    await profileCubit.loadProfile();
    final authCubit = _FakeAuthCubit();
    final router = _testRouter();
    addTearDown(() async {
      router.dispose();
      await profileCubit.close();
      await authCubit.close();
    });

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<ProfileCubit>.value(value: profileCubit),
          BlocProvider<AuthCubit>.value(value: authCubit),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Favorites'));
    await tester.pumpAndSettle();
    expect(find.text('Favorites destination'), findsOneWidget);

    router.pop();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit profile').first);
    await tester.pumpAndSettle();
    expect(find.text('Edit Profile destination'), findsOneWidget);
  });

  testWidgets('shows unsupported preferences as unavailable, not controls', (
    tester,
  ) async {
    final authCubit = _FakeAuthCubit();
    addTearDown(authCubit.close);

    await tester.pumpWidget(
      BlocProvider<AuthCubit>.value(
        value: authCubit,
        child: const MaterialApp(
          home: SettingsScreen(email: 'user@example.com'),
        ),
      ),
    );

    expect(
      find.text(
        'Light theme is currently in use; theme selection is unavailable.',
      ),
      findsOneWidget,
    );
    expect(
      find.text('Notification preferences are not available yet.'),
      findsOneWidget,
    );
    expect(find.byType(Switch), findsNothing);
    expect(find.textContaining('user@example.com'), findsOneWidget);
  });
}

GoRouter _testRouter() => GoRouter(
  initialLocation: '/profile',
  routes: [
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/profile/edit',
      name: 'edit-profile',
      builder: (context, state) =>
          const Scaffold(body: Text('Edit Profile destination')),
    ),
    GoRoute(
      path: '/settings',
      name: 'settings',
      builder: (context, state) =>
          const Scaffold(body: Text('Settings destination')),
    ),
    GoRoute(
      path: '/favorites',
      builder: (context, state) =>
          const Scaffold(body: Text('Favorites destination')),
    ),
    GoRoute(
      path: '/chat',
      builder: (context, state) =>
          const Scaffold(body: Text('Chat destination')),
    ),
    GoRoute(
      path: '/faq-support',
      builder: (context, state) =>
          const Scaffold(body: Text('Support destination')),
    ),
  ],
);

class _FakeAuthCubit extends Cubit<AuthState> implements AuthCubit {
  _FakeAuthCubit() : super(const AuthInitial());

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeFirebaseAuth implements FirebaseAuth {
  const _FakeFirebaseAuth(this.currentUser);

  @override
  final User? currentUser;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeUser implements User {
  const _FakeUser({
    required this.uid,
    this.email,
    this.displayName,
    this.photoURL,
    this.emailVerified = false,
  });

  @override
  final String uid;
  @override
  final String? email;
  @override
  final String? displayName;
  @override
  final String? photoURL;
  @override
  final bool emailVerified;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeAccountSetupRepository implements AccountSetupRepository {
  const _FakeAccountSetupRepository({this.profile});

  final UserProfileEntity? profile;

  @override
  ResultFuture<UserProfileEntity> getProfile(String userId) async =>
      profile == null
      ? (
          failure: const ServerFailure(
            message: 'User profile not found in Firestore',
          ),
          data: null,
        )
      : (failure: null, data: profile);

  @override
  ResultFuture<UserProfileEntity> saveProfile(
    UserProfileEntity profile, {
    String? localImagePath,
  }) async => (failure: null, data: profile);
}
