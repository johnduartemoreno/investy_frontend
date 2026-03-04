import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

class CheckEmailVerificationUseCase implements UseCase<void, NoParams> {
  final AuthRepository repository;

  CheckEmailVerificationUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) {
    return repository.reloadUser();
  }
}
