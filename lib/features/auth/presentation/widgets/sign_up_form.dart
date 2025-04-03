import 'package:biteq/core/theme/_app.Palette.dart';
import 'package:biteq/features/auth/presentation/widgets/error-dialog.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../viewmodel/sign_up_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:biteq/features/auth/presentation/widgets/custom_text_field.dart';

class SignUpForm extends ConsumerStatefulWidget {
  const SignUpForm({super.key});

  @override
  ConsumerState<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends ConsumerState<SignUpForm> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _usernameTouched = false;
  bool _emailTouched = false;
  bool _passwordTouched = false;

  @override
  void dispose() {
    _usernameController.dispose();
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
    final viewModel = ref.read(signUpViewModelProvider.notifier);
    final state = ref.watch(signUpViewModelProvider);

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
        // Username Field
        CustomTextField(
          controller: _usernameController,
          labelText: 'Username',
          errorText:
              (_usernameTouched || state.hasError)
                  ? viewModel.usernameError
                  : null,
          prefixIcon: Icons.person,
          onChanged: (value) {
            setState(() {
              _usernameTouched = true;
            });
            viewModel.setUsername(value);
          },
        ),
        const SizedBox(height: 15),

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
                        _usernameTouched = true;
                        _emailTouched = true;
                        _passwordTouched = true;
                      });

                      // Trigger validation
                      viewModel.setUsername(_usernameController.text);
                      viewModel.setEmail(_emailController.text);
                      viewModel.setPassword(_passwordController.text);

                      // Attempt sign up if no errors
                      if (viewModel.usernameError == null &&
                          viewModel.emailError == null &&
                          viewModel.passwordError == null) {
                        viewModel.signUp(() => context.go('/sign-in'), ref);
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
                      'Create account',
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
