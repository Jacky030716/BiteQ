import 'package:biteq/core/theme/_app.Palette.dart';
import 'package:biteq/features/auth/presentation/widgets/sign_in_form.dart';
import 'package:biteq/features/auth/presentation/widgets/top_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopBar(),
      backgroundColor: Palette.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/auth.png', height: 250, width: 350),
              const Text(
                'Welcome Back',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800),
              ),
              Text(
                'How was your day?',
                style: TextStyle(fontSize: 16, color: Palette.placeholder),
              ),
              const SizedBox(height: 50),
              const SignInForm(),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account? "),
                  GestureDetector(
                    onTap: () {
                      // Navigate to login screen
                      context.go('/sign-up');
                    },
                    child: Text(
                      'Register',
                      style: TextStyle(
                        color: Palette.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
