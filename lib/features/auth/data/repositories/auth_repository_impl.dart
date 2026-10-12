import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/typedefs.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl(this._remoteDataSource);

  @override
  ResultFuture<UserEntity> loginWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final user = await _remoteDataSource.loginWithEmailAndPassword(
        email: email,
        password: password,
      );
      return (failure: null, data: user);
    } on AuthException catch (e) {
      return (failure: AuthFailure(message: e.message), data: null);
    } catch (e) {
      return (failure: AuthFailure(message: e.toString()), data: null);
    }
  }

  @override
  ResultFuture<UserEntity> registerWithEmailAndPassword({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      final user = await _remoteDataSource.registerWithEmailAndPassword(
        fullName: fullName,
        email: email,
        password: password,
      );
      return (failure: null, data: user);
    } on AuthException catch (e) {
      return (failure: AuthFailure(message: e.message), data: null);
    } catch (e) {
      return (failure: AuthFailure(message: e.toString()), data: null);
    }
  }

  @override
  ResultVoid sendPasswordResetEmail({required String email}) async {
    try {
      await _remoteDataSource.sendPasswordResetEmail(email: email);
      return (failure: null, isSuccess: true);
    } on AuthException catch (e) {
      return (failure: AuthFailure(message: e.message), isSuccess: false);
    } catch (e) {
      return (failure: AuthFailure(message: e.toString()), isSuccess: false);
    }
  }

  @override
  ResultVoid verifyOtp({required String email, required String otp}) async {
    try {
      await _remoteDataSource.verifyOtp(email: email, otp: otp);
      return (failure: null, isSuccess: true);
    } on AuthException catch (e) {
      return (failure: AuthFailure(message: e.message), isSuccess: false);
    } catch (e) {
      return (failure: AuthFailure(message: e.toString()), isSuccess: false);
    }
  }

  @override
  ResultVoid resendOtp({required String email}) async {
    try {
      await _remoteDataSource.resendOtp(email: email);
      return (failure: null, isSuccess: true);
    } on AuthException catch (e) {
      return (failure: AuthFailure(message: e.message), isSuccess: false);
    } catch (e) {
      return (failure: AuthFailure(message: e.toString()), isSuccess: false);
    }
  }

  @override
  ResultFuture<UserEntity> signInWithGoogle() async {
    try {
      final user = await _remoteDataSource.signInWithGoogle();
      return (failure: null, data: user);
    } on AuthException catch (e) {
      return (failure: AuthFailure(message: e.message), data: null);
    }
  }

  @override
  ResultFuture<UserEntity> signInWithFacebook() async {
    try {
      final user = await _remoteDataSource.signInWithFacebook();
      return (failure: null, data: user);
    } on AuthException catch (e) {
      return (failure: AuthFailure(message: e.message), data: null);
    }
  }

  @override
  ResultFuture<UserEntity?> getCurrentUser() async {
    try {
      final user = await _remoteDataSource.getCurrentUser();
      return (failure: null, data: user);
    } catch (e) {
      return (failure: AuthFailure(message: e.toString()), data: null);
    }
  }

  @override
  ResultVoid signOut() async {
    try {
      await _remoteDataSource.signOut();
      return (failure: null, isSuccess: true);
    } catch (e) {
      return (failure: AuthFailure(message: e.toString()), isSuccess: false);
    }
  }
}
