import 'package:fpdart/fpdart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/goal.dart';
import '../../domain/repositories/goals_repository.dart';

part 'goals_repository_impl.g.dart';

@riverpod
GoalsRepository goalsRepository(Ref ref) {
  return GoalsRepositoryImpl();
}

class GoalsRepositoryImpl implements GoalsRepository {
  final List<Goal> _mockGoals = [
    Goal(
      id: '1',
      name: 'New Car',
      targetAmount: 30000,
      currentAmount: 18500,
      deadline: DateTime(2025, 12, 31),
    ),
    Goal(
      id: '2',
      name: 'Emergency Fund',
      targetAmount: 10000,
      currentAmount: 4500,
      deadline: DateTime(2024, 6, 30),
    ),
    Goal(
      id: '3',
      name: 'Vacation',
      targetAmount: 5000,
      currentAmount: 1200,
      deadline: DateTime(2024, 8, 15),
    ),
  ];

  @override
  Future<Either<Failure, List<Goal>>> getGoals() async {
    await Future.delayed(const Duration(milliseconds: 800)); // Simulate latency
    return Right(_mockGoals);
  }

  @override
  Future<Either<Failure, Goal>> addGoal(
      String name, double targetAmount, DateTime deadline) async {
    await Future.delayed(const Duration(seconds: 1));
    final newGoal = Goal(
      id: DateTime.now().toString(),
      name: name,
      targetAmount: targetAmount,
      currentAmount: 0,
      deadline: deadline,
    );
    _mockGoals.add(newGoal);
    return Right(newGoal);
  }
}
