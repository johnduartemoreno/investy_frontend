import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/goal.dart';
import '../repositories/goals_repository.dart';

class GetGoalsUseCase implements UseCase<List<Goal>, NoParams> {
  final GoalsRepository repository;

  GetGoalsUseCase(this.repository);

  @override
  Future<Either<Failure, List<Goal>>> call(NoParams params) {
    return repository.getGoals();
  }
}
