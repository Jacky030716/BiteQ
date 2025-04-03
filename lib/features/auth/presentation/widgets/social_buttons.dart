import 'package:biteq/core/theme/_app.Palette.dart';
import 'package:biteq/features/auth/presentation/viewmodel/sign_in_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SocialButtons extends ConsumerWidget {
  const SocialButtons({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.read(signInViewModelProvider.notifier);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Palette.placeholder),
            borderRadius: BorderRadius.circular(100),
          ),
          child: IconButton(
            onPressed: () async {
              await viewModel.signInWithGoogle(() => context.go('/home'), ref);
            },
            icon: const Image(
              image: AssetImage('assets/images/google.png'),
              width: 20,
              height: 20,
            ),
          ),
        ),
      ],
    );
  }
}
