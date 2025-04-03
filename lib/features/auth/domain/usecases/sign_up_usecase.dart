import '../entities/user.dart';
import '../../data/repositories/auth_repository.dart';

class SignUpUseCase {
  final AuthRepository repository;

  SignUpUseCase(this.repository);

  Future<User> execute(String email, String username, String password) async {
    final userModel = await repository.signUp(email, username, password);
    return User(id: userModel.id, name: userModel.name, email: userModel.email);
  }
}
