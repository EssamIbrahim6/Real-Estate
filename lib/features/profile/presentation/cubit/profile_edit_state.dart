import 'package:equatable/equatable.dart';

import '../../../account_setup/domain/entities/user_profile_entity.dart';

enum ProfileEditStatus {
  initial,
  loading,
  loadError,
  ready,
  saving,
  saved,
  error,
}

class ProfileEditState extends Equatable {
  final ProfileEditStatus status;
  final UserProfileEntity? profile;
  final String displayName;
  final String email;
  final String phone;
  final String? photoUrl;
  final String? localImagePath;
  final String? message;
  final String? warning;

  const ProfileEditState({
    this.status = ProfileEditStatus.initial,
    this.profile,
    this.displayName = '',
    this.email = '',
    this.phone = '',
    this.photoUrl,
    this.localImagePath,
    this.message,
    this.warning,
  });

  ProfileEditState copyWith({
    ProfileEditStatus? status,
    UserProfileEntity? profile,
    String? displayName,
    String? email,
    String? phone,
    String? photoUrl,
    String? localImagePath,
    bool clearLocalImagePath = false,
    String? message,
    String? warning,
  }) => ProfileEditState(
    status: status ?? this.status,
    profile: profile ?? this.profile,
    displayName: displayName ?? this.displayName,
    email: email ?? this.email,
    phone: phone ?? this.phone,
    photoUrl: photoUrl ?? this.photoUrl,
    localImagePath: clearLocalImagePath
        ? null
        : localImagePath ?? this.localImagePath,
    message: message,
    warning: warning,
  );

  @override
  List<Object?> get props => [
    status,
    profile,
    displayName,
    email,
    phone,
    photoUrl,
    localImagePath,
    message,
    warning,
  ];
}
