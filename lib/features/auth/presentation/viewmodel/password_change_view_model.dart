import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Enum to represent the state of the password change operation
enum PasswordChangeStatus { initial, loading, success, error }

// State for the password change operation (status and optional error message)
class PasswordChangeState {
  final PasswordChangeStatus status;
  final String? errorMessage;

  PasswordChangeState({
    this.status = PasswordChangeStatus.initial,
    this.errorMessage,
  });

  // Helper to create new states
  PasswordChangeState copyWith({
    PasswordChangeStatus? status,
    String? errorMessage,
  }) {
    return PasswordChangeState(
      status: status ?? this.status,
      errorMessage: errorMessage, // Nullable to clear previous errors
    );
  }
}

// StateNotifier for the PasswordChangeViewModel
final passwordChangeViewModelProvider =
    StateNotifierProvider<PasswordChangeViewModel, PasswordChangeState>((ref) {
      return PasswordChangeViewModel();
    });

class PasswordChangeViewModel extends StateNotifier<PasswordChangeState> {
  PasswordChangeViewModel() : super(PasswordChangeState());

  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Changes the user's password. Requires re-authentication if the user
  /// recently signed in using a method that doesn't provide a long-lived credential.
  ///
  /// [currentPassword] The user's current password.
  /// [newPassword] The new password the user wants to set.
  Future<void> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    state = state.copyWith(
      status: PasswordChangeStatus.loading,
      errorMessage: null,
    );

    try {
      final User? user = _auth.currentUser;
      if (user == null) {
        throw FirebaseAuthException(
          code: 'no-user',
          message: 'No authenticated user found.',
        );
      }

      // Re-authenticate the user with their current credentials.
      // This is often required for security-sensitive operations like password changes.
      final AuthCredential credential = EmailAuthProvider.credential(
        email:
            user.email!, // Assumes email is available for email/password users
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);

      // If re-authentication is successful, update the password
      await user.updatePassword(newPassword);

      state = state.copyWith(status: PasswordChangeStatus.success);
      print('Password changed successfully!');
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'wrong-password':
          errorMessage = 'Incorrect current password.';
          break;
        case 'user-disabled':
          errorMessage = 'User account has been disabled.';
          break;
        case 'too-many-requests':
          errorMessage = 'Too many requests. Try again later.';
          break;
        case 'requires-recent-login':
          errorMessage =
              'Please log in again to change your password. Your session may have expired.';
          break;
        case 'weak-password':
          errorMessage =
              'The new password is too weak. Please choose a stronger password.';
          break;
        case 'invalid-credential':
          errorMessage = 'Your old password is invalid. Please try again.';
          break;
        default:
          errorMessage = 'Failed to change password: ${e.message}';
      }
      state = state.copyWith(
        status: PasswordChangeStatus.error,
        errorMessage: errorMessage,
      );
      print('Firebase Auth Error: ${e.code} - ${e.message}');
    } catch (e) {
      state = state.copyWith(
        status: PasswordChangeStatus.error,
        errorMessage: 'An unexpected error occurred: $e',
      );
      print('General Error: $e');
    }
  }

  // Resets the state back to initial, useful after a success or error message is displayed
  void resetState() {
    state = PasswordChangeState();
  }
}
