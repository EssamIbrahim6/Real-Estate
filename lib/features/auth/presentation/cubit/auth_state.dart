import 'package:equatable/equatable.dart';

import '../../domain/entities/user_entity.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  final String? message;
  const AuthLoading({this.message});

  @override
  List<Object?> get props => [message];
}

class Authenticated extends AuthState {
  final UserEntity user;
  final bool accountSetupCompleted;

  const Authenticated(this.user, {this.accountSetupCompleted = false});

  @override
  List<Object?> get props => [user, accountSetupCompleted];
}
// class Authenticated extends AuthState {
//   final UserEntity user;
//   const Authenticated(this.user);

//   @override
//   List<Object?> get props => [user];
// }

class Unauthenticated extends AuthState {
  const Unauthenticated();
}

class AuthFailureState extends AuthState {
  final String message;
  const AuthFailureState(this.message);

  @override
  List<Object?> get props => [message];
}

class PasswordResetSentState extends AuthState {
  final String email;
  const PasswordResetSentState(this.email);

  @override
  List<Object?> get props => [email];
}

class OtpVerificationSuccessState extends AuthState {
  const OtpVerificationSuccessState();
}

class OtpResentSuccessState extends AuthState {
  const OtpResentSuccessState();
}
