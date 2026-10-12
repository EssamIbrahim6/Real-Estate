import 'package:equatable/equatable.dart';

import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/typedefs.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class LoginParams extends Equatable {
  final String email;
  final String password;

  const LoginParams({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class LoginUseCase
    extends UseCase<({dynamic failure, UserEntity? data}), LoginParams> {
  final AuthRepository _repository;
  const LoginUseCase(this._repository);

  @override
  ResultFuture<UserEntity> call(LoginParams params) {
    return _repository.loginWithEmailAndPassword(
      email: params.email,
      password: params.password,
    );
  }
}

class RegisterParams extends Equatable {
  final String fullName;
  final String email;
  final String password;

  const RegisterParams({
    required this.fullName,
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [fullName, email, password];
}

class RegisterUseCase
    extends UseCase<({dynamic failure, UserEntity? data}), RegisterParams> {
  final AuthRepository _repository;
  const RegisterUseCase(this._repository);

  @override
  ResultFuture<UserEntity> call(RegisterParams params) {
    return _repository.registerWithEmailAndPassword(
      fullName: params.fullName,
      email: params.email,
      password: params.password,
    );
  }
}

class ForgotPasswordUseCase
    extends UseCase<({dynamic failure, bool isSuccess}), String> {
  final AuthRepository _repository;
  const ForgotPasswordUseCase(this._repository);

  @override
  ResultVoid call(String email) {
    return _repository.sendPasswordResetEmail(email: email);
  }
}

class VerifyOtpParams extends Equatable {
  final String email;
  final String otp;

  const VerifyOtpParams({required this.email, required this.otp});

  @override
  List<Object?> get props => [email, otp];
}

class VerifyOtpUseCase
    extends UseCase<({dynamic failure, bool isSuccess}), VerifyOtpParams> {
  final AuthRepository _repository;
  const VerifyOtpUseCase(this._repository);

  @override
  ResultVoid call(VerifyOtpParams params) {
    return _repository.verifyOtp(email: params.email, otp: params.otp);
  }
}

class ResendOtpUseCase
    extends UseCase<({dynamic failure, bool isSuccess}), String> {
  final AuthRepository _repository;
  const ResendOtpUseCase(this._repository);

  @override
  ResultVoid call(String email) {
    return _repository.resendOtp(email: email);
  }
}

class GoogleSignInUseCase
    extends UseCase<({dynamic failure, UserEntity? data}), NoParams> {
  final AuthRepository _repository;
  const GoogleSignInUseCase(this._repository);

  @override
  ResultFuture<UserEntity> call(NoParams params) {
    return _repository.signInWithGoogle();
  }
}

class FacebookSignInUseCase
    extends UseCase<({dynamic failure, UserEntity? data}), NoParams> {
  final AuthRepository _repository;
  const FacebookSignInUseCase(this._repository);

  @override
  ResultFuture<UserEntity> call(NoParams params) {
    return _repository.signInWithFacebook();
  }
}

class GetCurrentUserUseCase
    extends UseCase<({dynamic failure, UserEntity? data}), NoParams> {
  final AuthRepository _repository;
  const GetCurrentUserUseCase(this._repository);

  @override
  ResultFuture<UserEntity?> call(NoParams params) {
    return _repository.getCurrentUser();
  }
}

class LogoutUseCase
    extends UseCase<({dynamic failure, bool isSuccess}), NoParams> {
  final AuthRepository _repository;
  const LogoutUseCase(this._repository);

  @override
  ResultVoid call(NoParams params) {
    return _repository.signOut();
  }
}
