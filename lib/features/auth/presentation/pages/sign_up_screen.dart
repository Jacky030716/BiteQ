import 'package:biteq/core/theme/_app.Palette.dart';
import 'package:biteq/features/auth/presentation/widgets/top_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/sign_up_form.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopBar(),
      backgroundColor: Palette.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(left: 24.0, right: 24.0, bottom: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/auth.png', height: 250, width: 350),
              const SizedBox(height: 15),
              const Text(
                'New to BiteQ?',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800),
              ),
              Text(
                'Create an account to start tracking your daily meals',
                style: TextStyle(fontSize: 16, color: Palette.placeholder),
              ),
              const SizedBox(height: 30),
              const SignUpForm(), // Separate widget for the form
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Already have an account? '),
                  GestureDetector(
                    onTap: () {
                      // Navigate to login screen
                      context.go('/sign-in');
                    },
                    child: Text(
                      'Log in',
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
