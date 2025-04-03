import 'package:biteq/core/navigation/app_router.dart';
import 'package:biteq/features/auth/domain/usecases/sign_out.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/user.dart';
import '../../data/repositories/auth_repository.dart';

class SignOutViewModel extends StateNotifier<AsyncValue<User?>> {
  final SignOutUsecase signOutUsecase;

  SignOutViewModel(this.signOutUsecase) : super(const AsyncValue.data(null));

  Future<void> signOut(Function onSuccess, WidgetRef ref) async {
    state = const AsyncValue.loading();
    try {
      await signOutUsecase.execute();
      state = const AsyncData(null);

      ref.invalidate(authStateProvider);

      onSuccess();
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  // Reset state to initial data
  void resetError() {
    if (state is AsyncError) {
      state = const AsyncValue.data(null);
    }
  }
}

// Provider for the ViewModel
final signOutViewModelProvider =
    StateNotifierProvider<SignOutViewModel, AsyncValue<User?>>((ref) {
      final repository = AuthRepository();
      final useCase = SignOutUsecase(repository);
      return SignOutViewModel(useCase);
    });
