import 'package:equatable/equatable.dart';

import '../../../account_setup/domain/entities/user_profile_entity.dart';

enum ProfileStatus { initial, loading, loaded, signedOut, error }

class ProfileState extends Equatable {
  final ProfileStatus status;
  final UserProfileEntity? profile;
  final String displayName;
  final String email;
  final String? photoUrl;
  final bool isEmailVerified;
  final String? warning;
  final String? error;

  const ProfileState({
    this.status = ProfileStatus.initial,
    this.profile,
    this.displayName = '',
    this.email = '',
    this.photoUrl,
    this.isEmailVerified = false,
    this.warning,
    this.error,
  });

  ProfileState copyWith({
    ProfileStatus? status,
    UserProfileEntity? profile,
    String? displayName,
    String? email,
    String? photoUrl,
    bool clearPhotoUrl = false,
    bool? isEmailVerified,
    String? warning,
    String? error,
  }) => ProfileState(
    status: status ?? this.status,
    profile: profile ?? this.profile,
    displayName: displayName ?? this.displayName,
    email: email ?? this.email,
    photoUrl: clearPhotoUrl ? null : photoUrl ?? this.photoUrl,
    isEmailVerified: isEmailVerified ?? this.isEmailVerified,
    warning: warning,
    error: error,
  );

  @override
  List<Object?> get props => [
    status,
    profile,
    displayName,
    email,
    photoUrl,
    isEmailVerified,
    warning,
    error,
  ];
}
