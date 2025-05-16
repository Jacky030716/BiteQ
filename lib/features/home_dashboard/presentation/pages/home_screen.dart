import 'package:biteq/features/auth/presentation/viewmodel/sign_out_view_model.dart';
import 'package:biteq/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final signOutViewModel = ref.watch(signOutViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Home Screen')),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            NavigateButton(route: '/sign-up', text: 'Go to Sign Up'),
            ElevatedButton(
              onPressed: () {
                signOutViewModel.signOut(() => context.go('/sign-in'), ref);
              },
              child: Text('Sign Out'),
            ),
            SizedBox(height: 20),
            NavigateButton(route: '/explore', text: 'Explore'),
          ],
        ),
      ),
    );
  }
}
