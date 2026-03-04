import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/usecases/usecase.dart';
import '../../data/repositories/goals_repository_impl.dart';
import '../../domain/entities/goal.dart';
import '../../domain/usecases/get_goals_usecase.dart';

part 'goals_provider.g.dart';

@riverpod
class GoalsNotifier extends _$GoalsNotifier {
  @override
  FutureOr<List<Goal>> build() async {
    return _fetchGoals();
  }

  Future<List<Goal>> _fetchGoals() async {
    final repository = ref.read(goalsRepositoryProvider);
    final useCase = GetGoalsUseCase(repository);
    final result = await useCase(NoParams());
    return result.fold(
      (failure) => throw Exception(failure.message),
      (goals) => goals,
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchGoals());
  }

  // Future<void> addGoal(...) // To be implemented for the FAB
}
