import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class SignUpUseCase implements UseCase<User, SignUpParams> {
  final AuthRepository repository;

  SignUpUseCase(this.repository);

  @override
  Future<Either<Failure, User>> call(SignUpParams params) {
    return repository.signUp(
        params.name, params.email, params.password, params.displayCurrency);
  }
}

class SignUpParams {
  final String name;
  final String email;
  final String password;
  final String displayCurrency;

  SignUpParams({
    required this.name,
    required this.email,
    required this.password,
    required this.displayCurrency,
  });
}
