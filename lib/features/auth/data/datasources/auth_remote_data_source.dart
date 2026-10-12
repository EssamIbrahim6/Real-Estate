import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../core/errors/exceptions.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> loginWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<UserModel> registerWithEmailAndPassword({
    required String fullName,
    required String email,
    required String password,
  });

  Future<void> sendPasswordResetEmail({required String email});

  Future<void> verifyOtp({required String email, required String otp});

  Future<void> resendOtp({required String email});

  Future<UserModel> signInWithGoogle();

  Future<UserModel> signInWithFacebook();

  Future<UserModel?> getCurrentUser();

  Future<void> signOut();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final String _serverClientId;
  bool _isGoogleSignInInitialized = false;

  /// Web OAuth 2.0 Client ID ("client_type: 3") from Firebase / Google Cloud Console.
  static const String defaultServerClientId =
      '300274975557-bpmdmkasb2r3v5pgi3prr7ecnichojtr.apps.googleusercontent.com';

  AuthRemoteDataSourceImpl({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
    String? serverClientId,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _googleSignIn = googleSignIn ?? GoogleSignIn.instance,
       _serverClientId = serverClientId ?? defaultServerClientId;

  /// Ensures GoogleSignIn 7.x is initialized once with the Web Client ID as serverClientId.
  Future<void> _ensureGoogleSignInInitialized() async {
    if (!_isGoogleSignInInitialized) {
      await _googleSignIn.initialize(serverClientId: _serverClientId);
      _isGoogleSignInInitialized = true;
    }
  }

  @override
  Future<UserModel> loginWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        throw const AuthException(message: 'User credential not found.');
      }
      return UserModel.fromFirebaseUser(user);
    } on FirebaseAuthException catch (e) {
      throw AuthException(
        message: _mapFirebaseAuthErrorCode(e.code),
        code: e.code,
      );
    } catch (e) {
      throw AuthException(
        message: 'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  @override
  Future<UserModel> registerWithEmailAndPassword({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        throw const AuthException(message: 'User registration failed.');
      }
      if (fullName.trim().isNotEmpty) {
        await user.updateDisplayName(fullName.trim());
        await user.reload();
      }
      return UserModel.fromFirebaseUser(_firebaseAuth.currentUser ?? user);
    } on FirebaseAuthException catch (e) {
      throw AuthException(
        message: _mapFirebaseAuthErrorCode(e.code),
        code: e.code,
      );
    } catch (e) {
      throw AuthException(message: 'Registration failed: ${e.toString()}');
    }
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw AuthException(
        message: _mapFirebaseAuthErrorCode(e.code),
        code: e.code,
      );
    }
  }

  @override
  Future<void> verifyOtp({required String email, required String otp}) async {
    if (otp.length != 4) {
      throw const AuthException(
        message: 'Please enter a valid 4-digit verification code.',
        code: 'invalid-otp',
      );
    }
    final currentUser = _firebaseAuth.currentUser;
    if (currentUser != null) {
      await currentUser.reload();
    }
  }

  @override
  Future<void> resendOtp({required String email}) async {
    try {
      final currentUser = _firebaseAuth.currentUser;
      if (currentUser != null && !currentUser.emailVerified) {
        await currentUser.sendEmailVerification();
      }
    } on FirebaseAuthException catch (e) {
      throw AuthException(
        message: _mapFirebaseAuthErrorCode(e.code),
        code: e.code,
      );
    }
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      // 1. Ensure GoogleSignIn 7.x is initialized with serverClientId before authenticating
      await _ensureGoogleSignInInitialized();

      // 2. Trigger interactive authentication (account picker)
      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();

      // 3. Obtain authentication ID token
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      // 4. Request OAuth scopes for accessToken (if needed)
      final clientAuth = await googleUser.authorizationClient
          .authorizationForScopes(['email', 'profile']);

      // 5. Create Firebase credential
      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: clientAuth?.accessToken,
      );

      // 6. Sign in to Firebase Authentication
      final UserCredential userCredential = await _firebaseAuth
          .signInWithCredential(credential);

      final User? user = userCredential.user;
      if (user == null) {
        throw const AuthException(
          message: 'Google Sign-In failed. User credential not found.',
          code: 'google-user-not-found',
        );
      }

      // 7. Return existing UserModel
      return UserModel.fromFirebaseUser(user);
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        throw const AuthException(
          message: 'Google Sign-In was cancelled by user.',
          code: 'google-sign-in-cancelled',
        );
      }
      throw AuthException(
        message: e.description ?? 'Google Sign-In failed. Please try again.',
        code: 'google-sign-in-error',
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(
        message: _mapFirebaseAuthErrorCode(e.code),
        code: e.code,
      );
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException(
        message: 'Google Sign-In failed: ${e.toString()}',
        code: 'google-sign-in-error',
      );
    }
  }

  @override
  Future<UserModel> signInWithFacebook() async {
    throw const AuthException(
      message: 'Facebook Login requires Facebook App ID and client token configuration in Firebase Console.',
      code: 'facebook-not-configured',
    );
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final user = _firebaseAuth.currentUser;
    return user != null ? UserModel.fromFirebaseUser(user) : null;
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
  }

  String _mapFirebaseAuthErrorCode(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email address.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Invalid email or password. Please check your credentials.';
      case 'email-already-in-use':
        return 'This email is already registered. Please sign in instead.';
      case 'weak-password':
        return 'The password is too weak. Please use at least 6 characters.';
      case 'invalid-email':
        return 'The email address entered is not valid.';
      case 'network-request-failed':
        return 'Network connection error. Please check your internet connection.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a moment and try again.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact support.';
      case 'account-exists-with-different-credential':
        return 'An account already exists with the same email address using a different sign-in method.';
      default:
        return 'Authentication failed. Please check your details and try again.';
    }
  }
}
