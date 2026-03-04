import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../entities/goal.dart';

abstract class GoalsRepository {
  Future<Either<Failure, List<Goal>>> getGoals();
  Future<Either<Failure, Goal>> addGoal(
      String name, double targetAmount, DateTime deadline);
}
