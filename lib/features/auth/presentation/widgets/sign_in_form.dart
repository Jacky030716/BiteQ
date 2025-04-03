import 'package:biteq/core/theme/_app.Palette.dart';
import 'package:biteq/features/auth/presentation/viewmodel/sign_in_view_model.dart';
import 'package:biteq/features/auth/presentation/widgets/custom_text_field.dart';
import 'package:biteq/features/auth/presentation/widgets/error-dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SignInForm extends ConsumerStatefulWidget {
  const SignInForm({super.key});

  @override
  ConsumerState<SignInForm> createState() => _SignInFormState();
}

class _SignInFormState extends ConsumerState<SignInForm> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _emailTouched = false;
  bool _passwordTouched = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
    final viewModel = ref.read(signInViewModelProvider.notifier);
    final state = ref.watch(signInViewModelProvider);

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

        const SizedBox(height: 15),

        // Password Field
        CustomTextField(
          controller: _passwordController,
          labelText: 'Password',
          errorText:
              (_passwordTouched || state.hasError)
                  ? viewModel.passwordError
                  : null,
          prefixIcon: Icons.lock,
          obscureText: true,
          onChanged: (value) {
            setState(() {
              _passwordTouched = true;
            });
            viewModel.setPassword(value);
          },
        ),

        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            style: TextButton.styleFrom(overlayColor: Colors.transparent),
            onPressed: () {
              context.go('/forgot-password');
            },
            child: Text(
              'Forgot Password?',
              style: TextStyle(
                color: Palette.primary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),

        const SizedBox(height: 30),

        // Submit Button
        SizedBox(
          width: double.infinity,
          height: 45,
          child: ElevatedButton(
            onPressed: () async {
              // Mark fields as touched to show errors
              setState(() {
                _emailTouched = true;
                _passwordTouched = true;
              });

              // Trigger validation
              viewModel.setEmail(_emailController.text);
              viewModel.setPassword(_passwordController.text);

              // Attempt sign in if no errors
              if (viewModel.emailError == null &&
                  viewModel.passwordError == null) {
                final surveyStatus = await viewModel.isSurveyCompleted();

                viewModel.signIn(() {
                  if (surveyStatus) {
                    context.push('/home');
                  } else {
                    context.push('/survey');
                  }
                }, ref);
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
                      constraints: BoxConstraints(minHeight: 20, minWidth: 20),
                    )
                    : Text(
                      'Login',
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
