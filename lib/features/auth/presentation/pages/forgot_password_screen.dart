import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:biteq/core/theme/_app.Palette.dart';
import 'package:biteq/features/auth/presentation/widgets/forgot_password_form.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Palette.background,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Forgot Password?',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Palette.blackText,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black38, size: 18),
          onPressed: () {
            context.go('/sign-in');
          },
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(0),
          child: Divider(color: Colors.black12, height: 1),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(left: 24.0, right: 24.0, bottom: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/auth.png', height: 250, width: 350),
              const SizedBox(height: 15),
              const Text(
                'Forgot Password?',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800),
              ),
              Text(
                'Forgot your password? No worries, we got you! Fill in your email and we will send you a link to reset it.',
                style: TextStyle(fontSize: 16, color: Palette.placeholder),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              const ForgotPasswordForm(), // Separate widget for the form
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
