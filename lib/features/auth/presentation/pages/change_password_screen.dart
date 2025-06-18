import 'package:biteq/features/auth/presentation/widgets/password_input_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:biteq/features/auth/presentation/viewmodel/password_change_view_model.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmNewPasswordController =
      TextEditingController();

  final FocusNode _currentPasswordFocus = FocusNode();
  final FocusNode _newPasswordFocus = FocusNode();
  final FocusNode _confirmNewPasswordFocus = FocusNode();

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();
    _currentPasswordFocus.dispose();
    _newPasswordFocus.dispose();
    _confirmNewPasswordFocus.dispose();
    super.dispose();
  }

  // Validator for password fields
  String? _passwordValidator(String? value, {bool isConfirmation = false}) {
    if (value == null || value.isEmpty) {
      return 'Password cannot be empty.';
    }
    if (value.length < 8) {
      return 'Password must be at least 6 characters long.';
    }
    if (!RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d]{8,}$',
    ).hasMatch(value)) {
      return 'Password must contain at least one uppercase letter, one lowercase letter, and one number.';
    }
    if (isConfirmation && value != _newPasswordController.text) {
      return 'Passwords do not match.';
    }
    return null;
  }

  // Handle password change submission
  Future<void> _handleChangePassword() async {
    if (_formKey.currentState!.validate()) {
      final String currentPassword = _currentPasswordController.text;
      final String newPassword = _newPasswordController.text;

      final passwordChangeViewModel = ref.read(
        passwordChangeViewModelProvider.notifier,
      );
      await passwordChangeViewModel.changePassword(
        currentPassword,
        newPassword,
      );

      // Listen for state changes to show SnackBar
      final passwordChangeState = ref.read(passwordChangeViewModelProvider);
      if (passwordChangeState.status == PasswordChangeStatus.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Password changed successfully!'),
            backgroundColor: Colors.green.shade400,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        // Navigate back to profile or appropriate screen
        context.go('/profile'); // Assuming /profile is your user profile route
      } else if (passwordChangeState.status == PasswordChangeStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              passwordChangeState.errorMessage ?? 'An error occurred.',
            ),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
      passwordChangeViewModel.resetState();
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    final passwordChangeState = ref.watch(passwordChangeViewModelProvider);
    final bool isLoading =
        passwordChangeState.status == PasswordChangeStatus.loading;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Change Password',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => context.go('/profile'),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
        shadowColor: Colors.black.withOpacity(0.1),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Update your password securely.',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.black54,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Current Password Input
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PasswordInputField(
                    controller: _currentPasswordController,
                    labelText: 'Current Password',
                    validator: _passwordValidator,
                    focusNode: _currentPasswordFocus,
                    textInputAction: TextInputAction.next,
                    onEditingComplete:
                        () => FocusScope.of(
                          context,
                        ).requestFocus(_newPasswordFocus),
                  ),
                  const SizedBox(height: 4),
                  if (_passwordValidator(_currentPasswordController.text) !=
                      null)
                    Text(
                      _passwordValidator(_currentPasswordController.text)!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),

              // New Password Input
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PasswordInputField(
                    controller: _newPasswordController,
                    labelText: 'New Password',
                    validator: _passwordValidator,
                    focusNode: _newPasswordFocus,
                    textInputAction: TextInputAction.next,
                    onEditingComplete:
                        () => FocusScope.of(
                          context,
                        ).requestFocus(_confirmNewPasswordFocus),
                  ),
                  const SizedBox(height: 4),
                  if (_passwordValidator(_newPasswordController.text) != null)
                    Text(
                      _passwordValidator(_newPasswordController.text)!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),

              // Confirm New Password Input
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PasswordInputField(
                    controller: _confirmNewPasswordController,
                    labelText: 'Confirm New Password',
                    validator:
                        (value) =>
                            _passwordValidator(value, isConfirmation: true),
                    focusNode: _confirmNewPasswordFocus,
                    textInputAction: TextInputAction.done,
                    onEditingComplete: _handleChangePassword,
                  ),
                  const SizedBox(height: 4),
                  if (_passwordValidator(
                        _confirmNewPasswordController.text,
                        isConfirmation: true,
                      ) !=
                      null)
                    Text(
                      _passwordValidator(
                        _confirmNewPasswordController.text,
                        isConfirmation: true,
                      )!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 32),

              // Submit Button
              ElevatedButton(
                onPressed: isLoading ? null : _handleChangePassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 5,
                ),
                child:
                    isLoading
                        ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                        : const Text(
                          'Change Password',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
