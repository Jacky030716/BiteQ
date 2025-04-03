import 'package:biteq/core/exceptions/firebase_auth_exceptions.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/services/firebase_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepository {
  // Keys for SharedPreferences
  static const String _lastLoginTimeKey = 'last_login_time';
  static const String _userEmailKey = 'user_email';
  static const String _userPasswordKey = 'user_password';
  static const String _onboardingDisplayedKey = 'onboarding_displayed';

  // Session timeout duration (3 hours)
  static const int _sessionTimeout = 3 * 60 * 60 * 1000;

  // Check if onboarding has been displayed
  Future<bool> hasDisplayedOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingDisplayedKey) ?? false;
  }

  // Mark onboarding as displayed
  Future<void> setOnboardingDisplayed() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingDisplayedKey, true);
  }

  // Save user credentials for auto-login
  Future<void> _saveUserCredentials(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userEmailKey, email);
    await prefs.setString(
      _userPasswordKey,
      password,
    ); // Consider encrypting this
    await prefs.setInt(
      _lastLoginTimeKey,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  // Clear saved credentials
  Future<void> clearSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userEmailKey);
    await prefs.remove(_userPasswordKey);
    await prefs.remove(_lastLoginTimeKey);
  }

  // Check if auto-login is possible
  Future<bool> canAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final lastLoginTime = prefs.getInt(_lastLoginTimeKey);
    final userEmail = prefs.getString(_userEmailKey);
    final userPassword = prefs.getString(_userPasswordKey);

    if (lastLoginTime == null || userEmail == null || userPassword == null) {
      return false;
    }

    final currentTime = DateTime.now().millisecondsSinceEpoch;
    final sessionValid = (currentTime - lastLoginTime) < _sessionTimeout;

    return sessionValid;
  }

  // Attempt auto-login
  Future<UserModel?> attemptAutoLogin() async {
    try {
      if (!await canAutoLogin()) {
        return null;
      }

      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString(_userEmailKey)!;
      final password = prefs.getString(_userPasswordKey)!;

      // Refresh the session timer
      await prefs.setInt(
        _lastLoginTimeKey,
        DateTime.now().millisecondsSinceEpoch,
      );

      return await signIn(email, password);
    } catch (e) {
      // If auto-login fails, clear credentials
      await clearSavedCredentials();
      return null;
    }
  }

  // Sign up the user with email and password
  Future<UserModel> signUp(
    String email,
    String username,
    String password,
  ) async {
    try {
      UserCredential userCredential = await FirebaseService()
          .createUserWithEmailAndPassword(email, password);

      if (userCredential.user == null) {
        throw Exception('User not found');
      }

      await FirebaseService().createUserProfile(userCredential.user!.uid, {
        'email': email,
        'name': username,
      });

      await _saveUserCredentials(email, password);
      await setOnboardingDisplayed();

      return UserModel(
        id: userCredential.user!.uid,
        email: email,
        name: username,
      );
    } on FirebaseAuthException catch (e) {
      throw TFirebaseAuthException.getException(e.code);
    }
  }

  // Sign in the user with email and password
  Future<UserModel> signIn(String email, String password) async {
    try {
      UserCredential userCredential = await FirebaseService()
          .signInWithEmailAndPassword(email, password);

      if (userCredential.user == null) {
        throw Exception('User not found');
      }

      final userProfile = await FirebaseService().getUserProfile(
        userCredential.user!.uid,
      );

      await _saveUserCredentials(email, password);
      await setOnboardingDisplayed();

      return UserModel(
        id: userCredential.user!.uid,
        email: userProfile['email'],
        name: userProfile['name'],
      );
    } on FirebaseAuthException catch (e) {
      throw TFirebaseAuthException.getException(e.code);
    } catch (e) {
      throw Exception('Something went wrong');
    }
  }

  Future<UserCredential> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId:
            '1078808067825-atjp13jdt45ritsjt3483e6661tep6sp.apps.googleusercontent.com',
        scopes: ['email', 'profile'],
      );

      // Trigger the authentication flow
      final GoogleSignInAccount? userAccount = await googleSignIn.signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
          await userAccount?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      return await FirebaseService().signInWithCredentials(credential);
    } on FirebaseAuthException catch (e) {
      throw TFirebaseAuthException.getException(e.code);
    } catch (e) {
      throw Exception('Something went wrong');
    }
  }

  Future<void> signOut() async {
    await FirebaseService().signOut();
    await clearSavedCredentials();
  }

  // Send the password reset email
  Future<UserModel> forgotPassword(String email) async {
    try {
      await FirebaseService().sendPasswordResetEmail(email);
      return UserModel(
        id: email,
        email: email,
        name: 'Password reset email sent',
      );
    } on FirebaseAuthException catch (e) {
      throw TFirebaseAuthException.getException(e.code);
    }
  }
}
