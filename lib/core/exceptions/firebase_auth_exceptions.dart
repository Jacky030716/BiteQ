class TFirebaseAuthException implements Exception {
  final String message;

  TFirebaseAuthException(this.message);

  @override
  String toString() => message;

  static TFirebaseAuthException getException(String errorCode) {
    switch (errorCode) {
      case 'email-already-in-use':
        return TFirebaseAuthException(
          'This email is already in use. Please use a different email.',
        );
      case 'invalid-email':
        return TFirebaseAuthException(
          'The email address is not valid. Please enter a valid email.',
        );
      case 'operation-not-allowed':
        return TFirebaseAuthException(
          'This operation is not allowed. Please contact support.',
        );
      case 'user-disabled':
        return TFirebaseAuthException(
          'This user account has been disabled. Please contact support.',
        );
      case 'user-not-found':
        return TFirebaseAuthException(
          'No user found with this email. Please sign up first.',
        );
      case 'wrong-password':
        return TFirebaseAuthException(
          'The password is incorrect. Please try again.',
        );
      case 'account-exists-with-different-credential':
        return TFirebaseAuthException(
          'An account already exists with a different credential.',
        );
      case 'invalid-credential':
        return TFirebaseAuthException(
          'The credential provided is invalid. Please try again.',
        );
      case 'network-request-failed':
        return TFirebaseAuthException(
          'Network error. Please check your internet connection.',
        );
      case 'too-many-requests':
        return TFirebaseAuthException(
          'Too many requests. Please try again later.',
        );
      case 'weak-password':
        return TFirebaseAuthException(
          'The password is too weak. Please choose a stronger password.',
        );
      default:
        return TFirebaseAuthException(
          'An unknown error occurred. Please try again.',
        );
    }
  }
}
