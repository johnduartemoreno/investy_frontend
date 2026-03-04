import 'package:firebase_auth/firebase_auth.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/user_profile_repository.dart';

class UpsertUserProfileUseCase implements UseCase<void, User> {
  final UserProfileRepository repository;

  UpsertUserProfileUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(User params) async {
    return await repository.upsertUserProfile(params);
  }
}
