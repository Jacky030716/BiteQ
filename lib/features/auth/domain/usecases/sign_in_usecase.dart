import 'package:firebase_auth/firebase_auth.dart';

import '../entities/user.dart' as domain;
import '../../data/repositories/auth_repository.dart';

class SignInUsecase {
  final AuthRepository repository;

  SignInUsecase(this.repository);

  Future<domain.User> signIn(String email, String password) async {
    final userModel = await repository.signIn(email, password);
    return domain.User(
      id: userModel.id,
      name: userModel.name,
      email: userModel.email,
    );
  }

  Future<UserCredential> signInWithGoogle() async {
    return await repository.signInWithGoogle();
  }
}
