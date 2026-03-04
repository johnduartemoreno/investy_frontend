import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:investy/features/auth/domain/entities/user.dart';
import 'package:investy/features/auth/domain/repositories/auth_repository.dart';
import 'package:investy/features/auth/domain/usecases/login_usecase.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late LoginUseCase useCase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    useCase = LoginUseCase(mockAuthRepository);
  });

  const tEmail = 'test@example.com';
  const tPassword = 'password';
  const tUser = User(id: '1', email: tEmail, name: 'Test User');

  test('should get user from repository when login is successful', () async {
    // Arrange
    when(() => mockAuthRepository.login(any(), any()))
        .thenAnswer((_) async => const Right(tUser));

    // Act
    final result =
        await useCase(LoginParams(email: tEmail, password: tPassword));

    // Assert
    expect(result, const Right(tUser));
    verify(() => mockAuthRepository.login(tEmail, tPassword));
    verifyNoMoreInteractions(mockAuthRepository);
  });
}
