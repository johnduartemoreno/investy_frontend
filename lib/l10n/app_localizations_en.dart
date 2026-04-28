// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Investy';

  @override
  String get navHome => 'Home';

  @override
  String get navGoals => 'Goals';

  @override
  String get navPortfolio => 'Portfolio';

  @override
  String get navSettings => 'Settings';

  @override
  String get commonSave => 'Save';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonConfirm => 'Confirm';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonLoading => 'Loading...';

  @override
  String get commonEmail => 'Email';

  @override
  String get commonPassword => 'Password';

  @override
  String get commonName => 'Name';

  @override
  String get commonError => 'Something went wrong. Please try again.';

  @override
  String get commonLogOut => 'Log Out';

  @override
  String get errorRequiredField => 'This field is required';

  @override
  String get errorInvalidEmail => 'Enter a valid email address';

  @override
  String get errorPasswordTooShort => 'Password must be at least 6 characters';

  @override
  String get errorPasswordMismatch => 'Passwords do not match';

  @override
  String get errorNetwork => 'Network error. Check your connection.';

  @override
  String get loginTitle => 'Welcome Back!';

  @override
  String get loginSubtitle => 'Securely access your investments.';

  @override
  String get loginRememberEmail => 'Remember email';

  @override
  String get loginOrContinueWith => 'Or continue with';

  @override
  String get loginEmailHint => 'Email';

  @override
  String get loginPasswordHint => 'Password';

  @override
  String get loginButton => 'Sign In';

  @override
  String get loginForgotPassword => 'Forgot password?';

  @override
  String get loginNoAccount => 'Don\'t have an account?';

  @override
  String get loginSignUp => 'Sign up';

  @override
  String get loginWithGoogle => 'Continue with Google';

  @override
  String get signupTitle => 'Create account';

  @override
  String get signupSubtitle => 'Start investing today';

  @override
  String get signupNameHint => 'Full name';

  @override
  String get signupEmailHint => 'Email';

  @override
  String get signupPasswordHint => 'Password';

  @override
  String get signupConfirmPasswordHint => 'Confirm password';

  @override
  String get signupCurrencyLabel => 'Display currency';

  @override
  String get signupButton => 'Create account';

  @override
  String get signupHaveAccount => 'Already have an account?';

  @override
  String get signupLogIn => 'Log in';

  @override
  String get forgotPasswordTitle => 'Reset password';

  @override
  String get forgotPasswordSubtitle =>
      'Enter your email and we\'ll send you a reset link';

  @override
  String get forgotPasswordEmailHint => 'Email';

  @override
  String get forgotPasswordButton => 'Send reset link';

  @override
  String get forgotPasswordSuccess => 'Reset link sent. Check your inbox.';

  @override
  String get emailVerificationTitle => 'Verify your email';

  @override
  String emailVerificationSubtitle(String email) {
    return 'We sent a verification link to $email. Check your inbox.';
  }

  @override
  String get emailVerificationResend => 'Resend email';

  @override
  String get emailVerificationLogout => 'Use a different account';

  @override
  String dashboardGreeting(String name) {
    return 'Hello, $name';
  }

  @override
  String get dashboardTotalBalance => 'Total Balance';

  @override
  String get dashboardInvestedValue => 'Invested';

  @override
  String get dashboardRecentActivity => 'Recent Activity';

  @override
  String get dashboardNoActivity => 'No recent activity';

  @override
  String get dashboardBuy => 'Buy';

  @override
  String get dashboardSell => 'Sell';

  @override
  String get dashboardTopUp => 'Top Up';

  @override
  String get dashboardWithdraw => 'Withdraw';

  @override
  String get dashboardAvailableCash => 'Available Cash';

  @override
  String get portfolioTitle => 'Portfolio';

  @override
  String get portfolioNoHoldings =>
      'No holdings yet.\nBuy your first asset to get started.';

  @override
  String get portfolioTotalInvested => 'Total Invested';

  @override
  String get portfolioReturn => 'Return';

  @override
  String get portfolioQuantity => 'Qty';

  @override
  String get portfolioAvgCost => 'Avg cost';

  @override
  String get portfolioCurrentPrice => 'Current price';

  @override
  String get goalsTitle => 'Goals';

  @override
  String get goalsNoGoals => 'No goals yet.\nCreate one to start saving.';

  @override
  String get goalsAddButton => 'Add Goal';

  @override
  String goalProgress(int percent) {
    return '$percent% funded';
  }

  @override
  String get goalTarget => 'Target';

  @override
  String get goalSaved => 'Saved';

  @override
  String get goalDeadline => 'Deadline';

  @override
  String get goalCategory => 'Category';

  @override
  String get goalFormTitle => 'New Goal';

  @override
  String get goalFormNameHint => 'Goal name';

  @override
  String get goalFormTargetHint => 'Target amount';

  @override
  String get goalFormDeadlineLabel => 'Deadline';

  @override
  String get goalFormCategoryLabel => 'Category';

  @override
  String get goalFormSaveButton => 'Save Goal';

  @override
  String get goalFormSelectDate => 'Select date';

  @override
  String get categoryCar => 'Car';

  @override
  String get categoryHome => 'Home';

  @override
  String get categoryVacation => 'Vacation';

  @override
  String get categoryTravel => 'Travel';

  @override
  String get categoryEducation => 'Education';

  @override
  String get categoryEmergency => 'Emergency';

  @override
  String get categoryHealth => 'Health';

  @override
  String get categoryOther => 'Other';

  @override
  String buyTitle(String symbol) {
    return 'Buy $symbol';
  }

  @override
  String get buyQuantityLabel => 'Quantity';

  @override
  String get buyPriceLabel => 'Price per unit';

  @override
  String get buyTotalLabel => 'Total';

  @override
  String get buyButton => 'Buy';

  @override
  String get buySuccess => 'Purchase successful';

  @override
  String sellTitle(String symbol) {
    return 'Sell $symbol';
  }

  @override
  String get sellQuantityLabel => 'Quantity';

  @override
  String get sellButton => 'Sell';

  @override
  String get sellSuccess => 'Sale successful';

  @override
  String sellMaxQuantity(String quantity) {
    return 'Max: $quantity';
  }

  @override
  String get topUpTitle => 'Top Up';

  @override
  String get topUpAmountHint => 'Amount';

  @override
  String get topUpButton => 'Add funds';

  @override
  String get topUpSuccess => 'Funds added successfully';

  @override
  String get withdrawTitle => 'Withdraw';

  @override
  String get withdrawAmountHint => 'Amount';

  @override
  String get withdrawButton => 'Withdraw';

  @override
  String get withdrawSuccess => 'Withdrawal successful';

  @override
  String get withdrawInsufficientFunds => 'Insufficient funds';

  @override
  String get assetSearchHint => 'Search assets (e.g. AAPL, BTC)';

  @override
  String get assetSearchEmpty => 'No assets found';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsCurrency => 'Currency';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsPrivacySecurity => 'Privacy & Security';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsAbout => 'About Investy';

  @override
  String get settingsHelp => 'Help & Support';

  @override
  String get securityTitle => 'Privacy & Security';

  @override
  String get securityAccountSection => 'Account Security';

  @override
  String get securityDangerSection => 'Danger Zone';

  @override
  String get securityChangePassword => 'Change Password';

  @override
  String get securityChangePasswordSubtitle => 'Update your login password';

  @override
  String get securityManagedByGoogle => 'Managed by Google';

  @override
  String get securityDeleteAccount => 'Delete Account';

  @override
  String get securityDeleteAccountSubtitle =>
      'Permanently remove your account and all data';

  @override
  String get changePasswordTitle => 'Change Password';

  @override
  String get changePasswordCurrent => 'Current password';

  @override
  String get changePasswordNew => 'New password';

  @override
  String get changePasswordConfirm => 'Confirm new password';

  @override
  String get changePasswordButton => 'Update password';

  @override
  String get changePasswordSuccess => 'Password updated successfully';

  @override
  String get deleteAccountTitle => 'Delete Account';

  @override
  String get deleteAccountWarning =>
      'This action is permanent and cannot be undone. All your data will be deleted.';

  @override
  String get deleteAccountConfirmPassword => 'Enter your password to confirm';

  @override
  String get deleteAccountConfirmEmail => 'Type your email to confirm';

  @override
  String deleteAccountYourEmail(String email) {
    return 'Your email: $email';
  }

  @override
  String get deleteAccountButton => 'Delete my account';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get notificationsPush => 'Push Notifications';

  @override
  String get notificationsPushSubtitle =>
      'Receive alerts for goals and transactions';

  @override
  String get notificationsGoalReminders => 'Goal Reminders';

  @override
  String get notificationsGoalRemindersSubtitle =>
      'Weekly progress reminders for your goals';

  @override
  String get notificationsEnable => 'Enable notifications';

  @override
  String get appearanceTitle => 'Appearance';

  @override
  String get appearanceTheme => 'Theme';

  @override
  String get appearanceThemeSystem => 'System';

  @override
  String get appearanceThemeLight => 'Light';

  @override
  String get appearanceThemeDark => 'Dark';

  @override
  String get appearanceLanguage => 'Language';

  @override
  String get languageEn => 'English';

  @override
  String get languageEs => 'Spanish';

  @override
  String get languagePt => 'Portuguese (BR)';

  @override
  String get aboutTitle => 'About Investy';

  @override
  String get aboutVersion => 'Version';

  @override
  String get aboutDescription =>
      'Investy helps you plan and track your investments toward your goals.';

  @override
  String get aboutTerms => 'Terms of Service';

  @override
  String get aboutPrivacy => 'Privacy Policy';

  @override
  String get helpTitle => 'Help & Support';

  @override
  String get helpFaq => 'Frequently Asked Questions';

  @override
  String get helpContact => 'Contact Support';

  @override
  String get helpDocumentation => 'Documentation';
}
