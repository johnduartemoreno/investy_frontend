import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:investy/core/errors/failures.dart';
import 'package:investy/features/auth/domain/repositories/auth_repository.dart';
import 'package:investy/features/auth/domain/usecases/forgot_password_usecase.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late ForgotPasswordUseCase useCase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    useCase = ForgotPasswordUseCase(mockAuthRepository);
  });

  const tEmail = 'test@example.com';

  test('should call repository.forgotPassword with email and return Right(null)',
      () async {
    when(() => mockAuthRepository.forgotPassword(any()))
        .thenAnswer((_) async => const Right(null));

    final result = await useCase(ForgotPasswordParams(email: tEmail));

    expect(result, const Right(null));
    verify(() => mockAuthRepository.forgotPassword(tEmail));
    verifyNoMoreInteractions(mockAuthRepository);
  });

  test('should return Left(Failure) when repository returns failure', () async {
    when(() => mockAuthRepository.forgotPassword(any()))
        .thenAnswer((_) async => Left(ServerFailure('Network error')));

    final result = await useCase(ForgotPasswordParams(email: tEmail));

    expect(result.isLeft(), true);
    verify(() => mockAuthRepository.forgotPassword(tEmail));
  });
}
