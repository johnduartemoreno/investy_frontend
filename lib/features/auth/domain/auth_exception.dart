/// Typed auth error codes — the UI maps these to localized .arb strings.
/// Mirrors the backend rule: layers below presentation never produce
/// user-facing copy, only codes.
enum AuthErrorCode {
  userNotFound,
  invalidCredentials,
  invalidEmail,
  userDisabled,
  tooManyRequests,
  network,
  emailInUse,
  weakPassword,
  operationNotAllowed,
  accountExistsWithDifferentCredential,
  googleCancelled,
  wrongPassword,
  requiresRecentLogin,
  noUserLoggedIn,
  verificationEmailFailed,
  refreshFailed,
  deletionFailed,
  unexpected,
}

class AuthException implements Exception {
  final AuthErrorCode code;

  const AuthException(this.code);

  @override
  String toString() => 'AuthException(${code.name})';
}
