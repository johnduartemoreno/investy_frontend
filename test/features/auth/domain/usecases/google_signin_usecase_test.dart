import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:investy/core/errors/failures.dart';
import 'package:investy/core/usecases/usecase.dart';
import 'package:investy/features/auth/domain/entities/user.dart';
import 'package:investy/features/auth/domain/repositories/auth_repository.dart';
import 'package:investy/features/auth/domain/usecases/google_signin_usecase.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late GoogleSignInUseCase useCase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    useCase = GoogleSignInUseCase(mockAuthRepository);
  });

  const tUser = User(
      id: 'google-uid-123',
      email: 'user@gmail.com',
      name: 'Google User');

  test('should return User when Google sign-in succeeds', () async {
    when(() => mockAuthRepository.signInWithGoogle())
        .thenAnswer((_) async => const Right(tUser));

    final result = await useCase(NoParams());

    expect(result, const Right(tUser));
    verify(() => mockAuthRepository.signInWithGoogle());
    verifyNoMoreInteractions(mockAuthRepository);
  });

  test('should return Left(Failure) when Google sign-in fails', () async {
    when(() => mockAuthRepository.signInWithGoogle())
        .thenAnswer((_) async => Left(ServerFailure('Google sign-in failed')));

    final result = await useCase(NoParams());

    expect(result.isLeft(), true);
    verify(() => mockAuthRepository.signInWithGoogle());
  });

  test('should return Left(Failure) when user cancels sign-in', () async {
    when(() => mockAuthRepository.signInWithGoogle()).thenAnswer(
        (_) async => Left(ServerFailure('Google sign-in cancelled')));

    final result = await useCase(NoParams());

    expect(result.isLeft(), true);
    result.fold(
      (failure) => expect(failure.message, contains('cancelled')),
      (_) => fail('Expected failure'),
    );
  });
}
