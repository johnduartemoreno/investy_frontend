import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> login(String email, String password);
  Future<Either<Failure, User>> signUp(
      String name, String email, String password, String displayCurrency);
  Future<Either<Failure, void>> sendVerificationEmail();
  Future<Either<Failure, void>> reloadUser();
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, User>> getCurrentUser();
  Future<Either<Failure, void>> forgotPassword(String email);
  Future<Either<Failure, User>> signInWithGoogle();
  Future<Either<Failure, void>> deleteAccountEmail(String currentPassword);
  Future<Either<Failure, void>> deleteAccountGoogle();
}
