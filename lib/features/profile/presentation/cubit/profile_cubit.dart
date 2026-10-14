import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../account_setup/domain/repositories/account_setup_repository.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final FirebaseAuth _firebaseAuth;
  final AccountSetupRepository _accountSetupRepository;

  ProfileCubit({
    required FirebaseAuth firebaseAuth,
    required AccountSetupRepository accountSetupRepository,
  }) : _firebaseAuth = firebaseAuth,
       _accountSetupRepository = accountSetupRepository,
       super(const ProfileState());

  Future<void> loadProfile() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      emit(const ProfileState(status: ProfileStatus.signedOut));
      return;
    }

    emit(state.copyWith(status: ProfileStatus.loading, error: null));
    final result = await _accountSetupRepository.getProfile(user.uid);
    final profile = result.data;
    final profileName = profile?.name.trim() ?? '';
    final displayName = profileName.isNotEmpty
        ? profileName
        : (user.displayName?.trim().isNotEmpty == true
              ? user.displayName!.trim()
              : 'Your profile');
    final profilePhoto = profile?.profileImageUrl?.trim() ?? '';
    final authPhoto = user.photoURL?.trim() ?? '';

    emit(
      ProfileState(
        status: ProfileStatus.loaded,
        profile: profile,
        displayName: displayName,
        email: user.email ?? profile?.email ?? '',
        photoUrl: profilePhoto.isNotEmpty
            ? profilePhoto
            : authPhoto.isNotEmpty
            ? authPhoto
            : null,
        isEmailVerified: user.emailVerified,
        warning: result.failure == null ||
                result.failure!.message == 'User profile not found in Firestore'
            ? null
            : 'Some profile details could not be loaded. Showing account information instead.',
      ),
    );
  }
}
