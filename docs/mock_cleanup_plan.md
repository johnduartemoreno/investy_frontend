# Mock Cleanup Plan

## Files to be Deleted

1. `lib/features/goals/data/repositories/goals_repository_impl.dart`
2. `lib/features/goals/data/repositories/goals_repository_mock.dart`
3. `lib/features/goals/data/repositories/goals_repository_test.dart`
4. `lib/features/goals/domain/repositories/goals_repository_mock.dart`
5. `lib/features/goals/domain/repositories/goals_repository_test.dart`

## Lines of Code to be Removed

1. In `lib/features/goals/data/repositories/goals_repository.dart`, remove any references to the mock repository.
2. In `lib/features/goals/domain/repositories/goals_repository.dart`, remove any references to the mock repository.
3. In `lib/features/goals/presentation/goals_screen.dart`, remove any references to the mock repository.
4. In `lib/features/goals/presentation/goals_screen_test.dart`, remove any references to the mock repository.
