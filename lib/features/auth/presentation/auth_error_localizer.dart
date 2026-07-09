import '../../../l10n/app_localizations.dart';
import '../domain/auth_exception.dart';

/// Maps any auth-flow error to a localized user-facing message.
/// Non-[AuthException] errors collapse to the generic unexpected copy.
String localizeAuthError(AppLocalizations l10n, Object? error) {
  final code = error is AuthException ? error.code : AuthErrorCode.unexpected;
  switch (code) {
    case AuthErrorCode.userNotFound:
      return l10n.authErrorUserNotFound;
    case AuthErrorCode.invalidCredentials:
      return l10n.authErrorInvalidCredentials;
    case AuthErrorCode.invalidEmail:
      return l10n.authErrorInvalidEmail;
    case AuthErrorCode.userDisabled:
      return l10n.authErrorUserDisabled;
    case AuthErrorCode.tooManyRequests:
      return l10n.authErrorTooManyRequests;
    case AuthErrorCode.network:
      return l10n.authErrorNetwork;
    case AuthErrorCode.emailInUse:
      return l10n.authErrorEmailInUse;
    case AuthErrorCode.weakPassword:
      return l10n.authErrorWeakPassword;
    case AuthErrorCode.operationNotAllowed:
      return l10n.authErrorOperationNotAllowed;
    case AuthErrorCode.accountExistsWithDifferentCredential:
      return l10n.authErrorAccountExistsDifferentMethod;
    case AuthErrorCode.googleCancelled:
      return l10n.authErrorGoogleCancelled;
    case AuthErrorCode.wrongPassword:
      return l10n.authErrorWrongPassword;
    case AuthErrorCode.requiresRecentLogin:
      return l10n.authErrorRequiresRecentLogin;
    case AuthErrorCode.noUserLoggedIn:
      return l10n.authErrorNoUser;
    case AuthErrorCode.verificationEmailFailed:
      return l10n.authErrorVerificationEmailFailed;
    case AuthErrorCode.refreshFailed:
      return l10n.authErrorRefreshFailed;
    case AuthErrorCode.deletionFailed:
      return l10n.authErrorDeletionFailed;
    case AuthErrorCode.unexpected:
      return l10n.authErrorUnexpected;
  }
}
