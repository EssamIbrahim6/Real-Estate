import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../account_setup/domain/entities/user_profile_entity.dart';
import '../../../account_setup/domain/repositories/account_setup_repository.dart';
import 'profile_edit_state.dart';

class ProfileEditCubit extends Cubit<ProfileEditState> {
  final FirebaseAuth _firebaseAuth;
  final AccountSetupRepository _accountSetupRepository;
  final ImagePicker _imagePicker;

  ProfileEditCubit({
    required FirebaseAuth firebaseAuth,
    required AccountSetupRepository accountSetupRepository,
    ImagePicker? imagePicker,
  }) : _firebaseAuth = firebaseAuth,
       _accountSetupRepository = accountSetupRepository,
       _imagePicker = imagePicker ?? ImagePicker(),
       super(const ProfileEditState());

  Future<void> loadProfile() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      emit(
        state.copyWith(
          status: ProfileEditStatus.loadError,
          message: 'Sign in to edit your profile.',
        ),
      );
      return;
    }

    emit(state.copyWith(status: ProfileEditStatus.loading, message: null));
    final result = await _accountSetupRepository.getProfile(user.uid);
    if (result.failure != null &&
        result.failure!.message != 'User profile not found in Firestore') {
      emit(
        state.copyWith(
          status: ProfileEditStatus.loadError,
          message: 'Profile details could not be loaded. Please try again.',
        ),
      );
      return;
    }
    final profile = result.data;
    final fallbackName = user.displayName?.trim() ?? '';
    final displayName = profile?.name.trim().isNotEmpty == true
        ? profile!.name.trim()
        : fallbackName;
    final profilePhoto = profile?.profileImageUrl?.trim() ?? '';
    final authPhoto = user.photoURL?.trim() ?? '';

    emit(
      ProfileEditState(
        status: ProfileEditStatus.ready,
        profile: profile,
        displayName: displayName,
        email: user.email ?? profile?.email ?? '',
        phone: profile?.phone ?? '',
        photoUrl: profilePhoto.isNotEmpty
            ? profilePhoto
            : authPhoto.isNotEmpty
            ? authPhoto
            : null,
        warning: result.failure == null ||
                result.failure!.message == 'User profile not found in Firestore'
            ? null
            : 'Existing profile details could not be loaded. Your account information is shown where available.',
      ),
    );
  }

  Future<void> pickProfileImage() async {
    if (state.status == ProfileEditStatus.saving) return;
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (image != null) {
        emit(
          state.copyWith(
            localImagePath: image.path,
            message: null,
            status: ProfileEditStatus.ready,
          ),
        );
      }
    } catch (_) {
      emit(
        state.copyWith(
          status: ProfileEditStatus.error,
          message: 'The profile photo could not be selected. Please try again.',
        ),
      );
    }
  }

  Future<void> saveProfile({
    required String displayName,
    required String phone,
  }) async {
    if (state.status == ProfileEditStatus.saving) return;
    if (state.status == ProfileEditStatus.initial ||
        state.status == ProfileEditStatus.loading ||
        state.status == ProfileEditStatus.loadError) {
      return;
    }
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      emit(
        state.copyWith(
          status: ProfileEditStatus.error,
          message: 'Your session has expired. Sign in and try again.',
        ),
      );
      return;
    }

    final normalizedName = displayName.trim();
    if (normalizedName.isEmpty) {
      emit(
        state.copyWith(
          status: ProfileEditStatus.error,
          message: 'Enter your name to continue.',
        ),
      );
      return;
    }

    emit(state.copyWith(status: ProfileEditStatus.saving, message: null));
    final oldProfile = state.profile;
    final profile = UserProfileEntity(
      userId: user.uid,
      name: normalizedName,
      email: user.email ?? state.email,
      phone: phone.trim(),
      profileImageUrl: state.photoUrl,
      location: oldProfile?.location,
      preferredRealEstateTypes:
          oldProfile?.preferredRealEstateTypes ?? const [],
      paymentMethod: oldProfile?.paymentMethod,
      accountSetupCompleted: oldProfile?.accountSetupCompleted ?? true,
    );
    final result = await _accountSetupRepository.saveProfile(
      profile,
      localImagePath: state.localImagePath,
    );

    if (result.failure != null || result.data == null) {
      emit(
        state.copyWith(
          status: ProfileEditStatus.error,
          message:
              result.failure?.message ?? 'Your profile could not be saved.',
        ),
      );
      return;
    }

    String? warning;
    try {
      await user.updateDisplayName(normalizedName);
      final savedPhoto = result.data!.profileImageUrl;
      if (savedPhoto != null && savedPhoto.trim().isNotEmpty) {
        await user.updatePhotoURL(savedPhoto);
      }
      await user.reload();
    } catch (_) {
      warning = 'Profile saved, but account display details could not be refreshed yet.';
    }

    emit(
      ProfileEditState(
        status: ProfileEditStatus.saved,
        profile: result.data,
        displayName: result.data!.name,
        email: result.data!.email,
        phone: result.data!.phone,
        photoUrl: result.data!.profileImageUrl,
        warning: warning,
      ),
    );
  }
}
