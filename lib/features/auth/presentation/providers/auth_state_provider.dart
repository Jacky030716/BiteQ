import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/auth_repository.dart';
import 'package:biteq/features/auth/data/models/user_model.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final authStateProvider = FutureProvider<UserModel?>((ref) async {
  final repository = ref.read(authRepositoryProvider);
  return await repository.attemptAutoLogin(); // or return current user if you store one
});
