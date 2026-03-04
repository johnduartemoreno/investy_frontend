import 'package:firebase_auth/firebase_auth.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';

abstract class UserProfileRepository {
  Future<Either<Failure, void>> upsertUserProfile(User firebaseUser);
}
