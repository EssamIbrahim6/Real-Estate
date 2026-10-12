import '../../../../core/utils/typedefs.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  ResultFuture<UserEntity> loginWithEmailAndPassword({
    required String email,
    required String password,
  });

  ResultFuture<UserEntity> registerWithEmailAndPassword({
    required String fullName,
    required String email,
    required String password,
  });

  ResultVoid sendPasswordResetEmail({required String email});

  ResultVoid verifyOtp({required String email, required String otp});

  ResultVoid resendOtp({required String email});

  ResultFuture<UserEntity> signInWithGoogle();

  ResultFuture<UserEntity> signInWithFacebook();

  ResultFuture<UserEntity?> getCurrentUser();

  ResultVoid signOut();
}
