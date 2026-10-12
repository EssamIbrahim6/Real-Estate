import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/auth_usecases.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final ForgotPasswordUseCase _forgotPasswordUseCase;
  final VerifyOtpUseCase _verifyOtpUseCase;
  final ResendOtpUseCase _resendOtpUseCase;
  final GoogleSignInUseCase _googleSignInUseCase;
  final FacebookSignInUseCase _facebookSignInUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final LogoutUseCase _logoutUseCase;

  AuthCubit({
    required this._loginUseCase,
    required RegisterUseCase registerUseCase,
    required this._forgotPasswordUseCase,
    required this._verifyOtpUseCase,
    required this._resendOtpUseCase,
    required this._googleSignInUseCase,
    required this._facebookSignInUseCase,
    required this._getCurrentUserUseCase,
    required this._logoutUseCase,
  }) : _registerUseCase = registerUseCase,
       super(const AuthInitial());

  Future<bool> _isAccountSetupCompleted(String userId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      return doc.data()?['accountSetupCompleted'] == true;
    } catch (_) {
      return false;
    }
  }

  Future<void> checkAuthStatus() async {
    final result = await _getCurrentUserUseCase(const NoParams());
    if (result.data != null) {
      final user = result.data!;
      final setupCompleted = await _isAccountSetupCompleted(user.id);
      emit(Authenticated(user, accountSetupCompleted: setupCompleted));
    } else {
      emit(const Unauthenticated());
    }
  }

  Future<void> login({required String email, required String password}) async {
    emit(const AuthLoading(message: 'Signing in...'));
    final result = await _loginUseCase(
      LoginParams(email: email, password: password),
    );

    if (result.failure != null) {
      emit(AuthFailureState(result.failure!.message));
    } else if (result.data != null) {
      final user = result.data!;
      final setupCompleted = await _isAccountSetupCompleted(user.id);
      emit(Authenticated(user, accountSetupCompleted: setupCompleted));
    }
  }

  Future<void> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    emit(const AuthLoading(message: 'Creating your account...'));
    final result = await _registerUseCase(
      RegisterParams(fullName: fullName, email: email, password: password),
    );

    if (result.failure != null) {
      emit(AuthFailureState(result.failure!.message));
    } else if (result.data != null) {
      emit(Authenticated(result.data!, accountSetupCompleted: false));
    }
  }

  Future<void> sendPasswordReset(String email) async {
    emit(const AuthLoading(message: 'Sending reset instructions...'));
    final result = await _forgotPasswordUseCase(email);

    if (result.failure != null || !result.isSuccess) {
      emit(
        AuthFailureState(
          result.failure?.message ?? 'Failed to send reset email',
        ),
      );
    } else {
      emit(PasswordResetSentState(email));
    }
  }

  Future<void> verifyOtp({required String email, required String otp}) async {
    emit(const AuthLoading(message: 'Verifying code...'));
    final result = await _verifyOtpUseCase(
      VerifyOtpParams(email: email, otp: otp),
    );

    if (result.failure != null || !result.isSuccess) {
      emit(
        AuthFailureState(result.failure?.message ?? 'Failed to verify code'),
      );
    } else {
      emit(const OtpVerificationSuccessState());
    }
  }

  Future<void> resendOtp(String email) async {
    emit(const AuthLoading(message: 'Resending code...'));
    final result = await _resendOtpUseCase(email);

    if (result.failure != null || !result.isSuccess) {
      emit(
        AuthFailureState(result.failure?.message ?? 'Failed to resend code'),
      );
    } else {
      emit(const OtpResentSuccessState());
    }
  }

  Future<void> signInWithGoogle() async {
    emit(const AuthLoading());
    final result = await _googleSignInUseCase(const NoParams());
    if (result.failure != null) {
      emit(AuthFailureState(result.failure!.message));
    } else if (result.data != null) {
      final user = result.data!;
      final setupCompleted = await _isAccountSetupCompleted(user.id);
      emit(Authenticated(user, accountSetupCompleted: setupCompleted));
    }
  }

  Future<void> signInWithFacebook() async {
    emit(const AuthLoading());
    final result = await _facebookSignInUseCase(const NoParams());
    if (result.failure != null) {
      emit(AuthFailureState(result.failure!.message));
    } else if (result.data != null) {
      final user = result.data!;
      final setupCompleted = await _isAccountSetupCompleted(user.id);
      emit(Authenticated(user, accountSetupCompleted: setupCompleted));
    }
  }

  Future<void> signOut() async {
    emit(const AuthLoading());
    final result = await _logoutUseCase(const NoParams());
    if (result.failure != null || !result.isSuccess) {
      emit(AuthFailureState(result.failure?.message ?? 'Sign out failed'));
      return;
    }
    emit(const Unauthenticated());
  }

  void resetState() {
    emit(const AuthInitial());
  }
}
