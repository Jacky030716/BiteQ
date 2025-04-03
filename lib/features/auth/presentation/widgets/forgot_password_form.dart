import 'package:biteq/core/theme/_app.Palette.dart';
import 'package:biteq/features/auth/presentation/viewmodel/forgot_password_view_model.dart';
import 'package:biteq/features/auth/presentation/widgets/error-dialog.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:biteq/features/auth/presentation/widgets/custom_text_field.dart';

class ForgotPasswordForm extends ConsumerStatefulWidget {
  const ForgotPasswordForm({super.key});

  @override
  ConsumerState<ForgotPasswordForm> createState() => _ForgotPasswordFormState();
}

class _ForgotPasswordFormState extends ConsumerState<ForgotPasswordForm> {
  final TextEditingController _emailController = TextEditingController();

  bool _emailTouched = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return ErrorDialog(
          message: message,
          onRetry: () {
            context.pop();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = ref.read(forgotPasswordViewModelProvider.notifier);
    final state = ref.watch(forgotPasswordViewModelProvider);

    if (state is AsyncError) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showErrorDialog(
          context,
          (state.error as Exception).toString().replaceFirst('Exception: ', ''),
        );
      });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Email Field
        CustomTextField(
          controller: _emailController,
          labelText: 'Email',
          errorText:
              (_emailTouched || state.hasError) ? viewModel.emailError : null,
          prefixIcon: Icons.email_outlined,
          onChanged: (value) {
            setState(() {
              _emailTouched = true;
            });
            viewModel.setEmail(value);
          },
        ),

        const SizedBox(height: 30),

        // Submit Button
        SizedBox(
          width: double.infinity,
          height: 45,
          child: ElevatedButton(
            onPressed:
                state.isLoading
                    ? null
                    : () {
                      // Mark all fields as touched to show errors
                      setState(() {
                        _emailTouched = true;
                      });

                      // Trigger validation
                      viewModel.setEmail(_emailController.text);

                      // Continue only if there are no errors
                      if (viewModel.emailError == null) {
                        viewModel.resetPassword(() {
                          context.pop();
                          context.go('/sign-in');
                        });
                      }
                    },
            style: ElevatedButton.styleFrom(
              backgroundColor: Palette.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
            ),
            child:
                state.isLoading
                    ? const CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    )
                    : Text(
                      'Continue',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Palette.whiteText,
                      ),
                    ),
          ),
        ),
      ],
    );
  }
}
