import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_app/core/errors/failures.dart';
import 'package:real_estate_app/core/utils/typedefs.dart';
import 'package:real_estate_app/features/account_setup/domain/entities/user_profile_entity.dart';
import 'package:real_estate_app/features/account_setup/domain/repositories/account_setup_repository.dart';
import 'package:real_estate_app/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:real_estate_app/features/profile/presentation/cubit/profile_edit_cubit.dart';
import 'package:real_estate_app/features/profile/presentation/cubit/profile_edit_state.dart';
import 'package:real_estate_app/features/profile/presentation/cubit/profile_state.dart';

void main() {
  group('ProfileCubit', () {
    test(
      'loads Firestore profile values and Firebase verification state',
      () async {
        final repository = _FakeAccountSetupRepository(
          profile: _profile(name: 'Firestore Name', photoUrl: 'https://photo'),
        );
        final cubit = ProfileCubit(
          firebaseAuth: _FakeFirebaseAuth(
            _FakeUser(
              uid: 'user-1',
              email: 'account@example.com',
              displayName: 'Auth Name',
              photoURL: 'https://auth-photo',
              emailVerified: true,
            ),
          ),
          accountSetupRepository: repository,
        );

        await cubit.loadProfile();

        expect(cubit.state.status, ProfileStatus.loaded);
        expect(cubit.state.displayName, 'Firestore Name');
        expect(cubit.state.email, 'account@example.com');
        expect(cubit.state.photoUrl, 'https://photo');
        expect(cubit.state.isEmailVerified, isTrue);
        await cubit.close();
      },
    );

    test(
      'falls back to Firebase details when the profile document is missing',
      () async {
        final repository = _FakeAccountSetupRepository(
          getFailure: const ServerFailure(
            message: 'User profile not found in Firestore',
          ),
        );
        final cubit = ProfileCubit(
          firebaseAuth: _FakeFirebaseAuth(
            _FakeUser(
              uid: 'user-2',
              email: 'fallback@example.com',
              displayName: 'Firebase Name',
              photoURL: 'https://firebase-photo',
            ),
          ),
          accountSetupRepository: repository,
        );

        await cubit.loadProfile();

        expect(cubit.state.status, ProfileStatus.loaded);
        expect(cubit.state.displayName, 'Firebase Name');
        expect(cubit.state.photoUrl, 'https://firebase-photo');
        expect(cubit.state.warning, isNull);
        await cubit.close();
      },
    );

    test('reports signed-out state without reading a profile', () async {
      final repository = _FakeAccountSetupRepository();
      final cubit = ProfileCubit(
        firebaseAuth: _FakeFirebaseAuth(null),
        accountSetupRepository: repository,
      );

      await cubit.loadProfile();

      expect(cubit.state.status, ProfileStatus.signedOut);
      expect(repository.requestedUserId, isNull);
      await cubit.close();
    });
  });

  group('ProfileEditCubit', () {
    test('saves the current user profile and uses its UID', () async {
      final repository = _FakeAccountSetupRepository(
        profile: _profile(
          name: 'Old Name',
          phone: '555123',
          photoUrl: 'https://photo',
        ),
      );
      final cubit = ProfileEditCubit(
        firebaseAuth: _FakeFirebaseAuth(
          _FakeUser(
            uid: 'user-3',
            email: 'edit@example.com',
            displayName: 'Old Name',
          ),
        ),
        accountSetupRepository: repository,
      );
      await cubit.loadProfile();

      await cubit.saveProfile(displayName: '  New Name  ', phone: '555999');

      expect(cubit.state.status, ProfileEditStatus.saved);
      expect(repository.savedProfile?.userId, 'user-3');
      expect(repository.savedProfile?.name, 'New Name');
      expect(repository.savedProfile?.phone, '555999');
      expect(repository.savedProfile?.profileImageUrl, 'https://photo');
      await cubit.close();
    });

    test(
      'does not allow saving when profile loading fails unexpectedly',
      () async {
        final repository = _FakeAccountSetupRepository(
          getFailure: const ServerFailure(message: 'Firestore unavailable'),
        );
        final cubit = ProfileEditCubit(
          firebaseAuth: _FakeFirebaseAuth(_FakeUser(uid: 'user-4')),
          accountSetupRepository: repository,
        );
        await cubit.loadProfile();
        await cubit.saveProfile(displayName: 'Name', phone: '');

        expect(cubit.state.status, ProfileEditStatus.loadError);
        expect(repository.savedProfile, isNull);
        await cubit.close();
      },
    );
  });
}

UserProfileEntity _profile({
  required String name,
  String phone = '',
  String? photoUrl,
}) => UserProfileEntity(
  userId: 'user-1',
  name: name,
  email: 'profile@example.com',
  phone: phone,
  profileImageUrl: photoUrl,
  preferredRealEstateTypes: const [RealEstateType.villa],
);

class _FakeAccountSetupRepository implements AccountSetupRepository {
  _FakeAccountSetupRepository({this.profile, this.getFailure});

  final UserProfileEntity? profile;
  final Failure? getFailure;
  String? requestedUserId;
  UserProfileEntity? savedProfile;

  @override
  ResultFuture<UserProfileEntity> getProfile(String userId) async {
    requestedUserId = userId;
    return (failure: getFailure, data: getFailure == null ? profile : null);
  }

  @override
  ResultFuture<UserProfileEntity> saveProfile(
    UserProfileEntity profile, {
    String? localImagePath,
  }) async {
    savedProfile = profile;
    return (failure: null, data: profile);
  }
}

class _FakeFirebaseAuth implements FirebaseAuth {
  const _FakeFirebaseAuth(this.currentUser);

  @override
  final User? currentUser;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeUser implements User {
  _FakeUser({
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
  Future<void> updateDisplayName(String? displayName) async {}

  @override
  Future<void> updatePhotoURL(String? photoURL) async {}

  @override
  Future<void> reload() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
