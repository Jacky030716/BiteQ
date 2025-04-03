import '../entities/user.dart';
import '../../data/repositories/auth_repository.dart';

class ForgotPasswordUsecase {
  final AuthRepository repository;

  ForgotPasswordUsecase(this.repository);

  Future<User> execute(String email) async {
    final userModel = await repository.forgotPassword(email);
    return User(id: userModel.id, name: userModel.name, email: userModel.email);
  }
}
