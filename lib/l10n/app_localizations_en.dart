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
  String get commonDone => 'Done';

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
  String get emailVerificationNotVerified => 'Please verify your email first';

  @override
  String get emailVerificationSent =>
      'Verification email sent! Check your inbox';

  @override
  String dashboardGreeting(String name) {
    return 'Hello, $name';
  }

  @override
  String get dashboardWelcomeBack => 'Welcome back,';

  @override
  String get dashboardTotalBalance => 'Total Balance';

  @override
  String get dashboardInvestedPortfolio => 'Invested Portfolio';

  @override
  String get dashboardCashToInvest => 'Cash to Invest';

  @override
  String get dashboardInvestedValue => 'Invested';

  @override
  String get dashboardRecentActivity => 'Recent Activity';

  @override
  String get dashboardSeeAll => 'See All';

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
  String get commonToday => 'Today';

  @override
  String get commonYesterday => 'Yesterday';

  @override
  String activityBought(String symbol) {
    return 'Bought $symbol';
  }

  @override
  String activitySold(String symbol) {
    return 'Sold $symbol';
  }

  @override
  String get activityDeposit => 'Deposit';

  @override
  String get activityWithdrawal => 'Withdrawal';

  @override
  String get activityUnknown => 'Unknown';

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
  String get portfolioAssetStock => 'Stock';

  @override
  String get portfolioAssetCrypto => 'Crypto';

  @override
  String get portfolioAssetEtf => 'ETF';

  @override
  String get portfolioShares => 'shares';

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
  String get buyAssetTitle => 'Buy Asset';

  @override
  String get buySelectAsset => 'Select an asset';

  @override
  String get buyPerShare => 'per share';

  @override
  String get buyEnterQuantity => 'Enter quantity';

  @override
  String get buyQuantityPositive => 'Must be greater than 0';

  @override
  String get buyConfirmButton => 'Confirm Purchase';

  @override
  String get buyEstimatedTotal => 'Estimated Total';

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
  String get sellAssetTitle => 'Sell Asset';

  @override
  String get sellNoAssets => 'You don\'t have any assets yet';

  @override
  String get sellNoAssetsSubtitle =>
      'Buy your first asset to start building your portfolio.';

  @override
  String get sellBuyFirstAsset => 'Buy Your First Asset';

  @override
  String sellTitle(String symbol) {
    return 'Sell $symbol';
  }

  @override
  String get sellQuantityLabel => 'Quantity';

  @override
  String sellSharesOwned(String quantity) {
    return '$quantity shares owned';
  }

  @override
  String get sellPricePerShare => 'Price per share (pre-filled from market)';

  @override
  String get sellEstimatedValue => 'Estimated Value';

  @override
  String get sellEnterQuantity => 'Enter quantity';

  @override
  String get sellQuantityPositive => 'Must be greater than zero';

  @override
  String sellQuantityExceeds(String quantity) {
    return 'You only own $quantity shares';
  }

  @override
  String get sellEnterPrice => 'Enter sell price';

  @override
  String get sellConfirm => 'Confirm Sale';

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
  String get topUpEnterAmount => 'Enter Amount';

  @override
  String get topUpAmountRequired => 'Please enter an amount';

  @override
  String get topUpAmountInvalid => 'Please enter a valid amount';

  @override
  String get topUpConfirmButton => 'Confirm Deposit';

  @override
  String get topUpAmountHint => 'Amount';

  @override
  String get topUpButton => 'Add funds';

  @override
  String get topUpSuccess => 'Funds added successfully';

  @override
  String get withdrawTitle => 'Withdraw';

  @override
  String get withdrawCash => 'Withdraw Cash';

  @override
  String get withdrawAvailableTo => 'Available to Withdraw';

  @override
  String get withdrawConfirmButton => 'Confirm Withdrawal';

  @override
  String get withdrawEnterAmount => 'Enter an amount';

  @override
  String get withdrawAmountPositive => 'Amount must be positive';

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
  String get changePasswordErrorWrongPassword =>
      'Current password is incorrect.';

  @override
  String get changePasswordErrorRecentLogin =>
      'Please sign out and sign back in before changing your password.';

  @override
  String get changePasswordErrorFailed =>
      'Failed to change password. Please try again.';

  @override
  String get deleteAccountTitle => 'Delete Account';

  @override
  String get deleteAccountWarning =>
      'This action is permanent and cannot be undone. All your data will be deleted.';

  @override
  String get deleteAccountConfirmTitle => 'Confirm Deletion';

  @override
  String get deleteAccountConfirmPassword => 'Enter your password to confirm';

  @override
  String get deleteAccountConfirmEmail => 'Type your email to confirm';

  @override
  String get deleteAccountConfirmEmailText =>
      'Type your account email to confirm deletion.';

  @override
  String get deleteAccountConfirmPasswordText =>
      'Enter your password to confirm account deletion.';

  @override
  String get deleteAccountEmailMismatch =>
      'Email does not match. Please try again.';

  @override
  String get deleteAccountEnterPassword => 'Please enter your password.';

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
  String get notificationsDescription =>
      'You will be notified when:\n• A deposit or withdrawal is processed\n• A buy or sell order is confirmed\n• A financial goal deadline is approaching (30 days)';

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

  @override
  String get helpReplyTime => 'We reply within 24 hours';

  @override
  String get helpFaq1Q => 'How do I add money to my account?';

  @override
  String get helpFaq1A =>
      'Tap \"Top-up\" on the home screen and enter the amount you want to deposit. The funds will be credited to your available cash balance.';

  @override
  String get helpFaq2Q => 'How do I buy an asset?';

  @override
  String get helpFaq2A =>
      'Tap \"Buy\" on the home screen, search for the asset by name or ticker symbol, enter the quantity and confirm the purchase.';

  @override
  String get helpFaq3Q => 'How do I set a financial goal?';

  @override
  String get helpFaq3A =>
      'Navigate to the Goals tab and tap the \"+\" button. Enter a name, target amount, category, and deadline. Your contributions will automatically count toward your goals.';

  @override
  String get helpFaq4Q => 'Can I withdraw my funds at any time?';

  @override
  String get helpFaq4A =>
      'Yes. Tap \"Withdraw\" on the home screen and enter the amount. Withdrawals are processed from your available cash balance.';

  @override
  String get helpFaq5Q => 'What happens if I forget my password?';

  @override
  String get helpFaq5A =>
      'On the login screen, tap \"Forgot password?\" and enter your email. We will send you a reset link within a few minutes.';

  @override
  String get kycTitle => 'Identity Verification';

  @override
  String get kycIntroBody =>
      'To start investing, we need to verify your identity. This is required by financial regulations and takes about 5 minutes.';

  @override
  String get kycStartButton => 'Start Verification';

  @override
  String get kycRetryButton => 'Try Again';

  @override
  String get kycCameraPermissionTitle => 'Camera Access Required';

  @override
  String get kycCameraPermissionBody =>
      'Camera access was denied. Please enable it in Settings to complete identity verification.';

  @override
  String get kycOpenSettings => 'Open Settings';

  @override
  String get kycApprovedTitle => 'Verified';

  @override
  String get kycApprovedBody =>
      'Your identity has been verified. You can now buy and sell assets.';

  @override
  String get kycPendingTitle => 'Under Review';

  @override
  String get kycPendingBody =>
      'Your documents have been submitted. We typically complete verification within 24 hours.';

  @override
  String get kycRejectedTitle => 'Verification Failed';

  @override
  String get kycRejectedBody =>
      'We could not verify your identity. Please try again with a clear photo of your ID document.';

  @override
  String get kycBannerRequired =>
      'Verify your identity to start trading. Tap here.';

  @override
  String get kycBannerPending =>
      'Identity verification is under review. Trading will be enabled once approved.';

  @override
  String get kycSettingsLabel => 'Identity Verification';

  @override
  String get kycReqLegalName => 'Full legal name';

  @override
  String get kycReqDob => 'Date of birth';

  @override
  String get kycReqAddress => 'Residential address';

  @override
  String get kycReqId => 'Government-issued ID';

  @override
  String get kycReqTaxId => 'Tax identification number';

  @override
  String get brokerSettingsLabel => 'Brokerage Account';

  @override
  String get brokerStatusPending => 'Pending';

  @override
  String get brokerStatusActive => 'Active';

  @override
  String get brokerStatusRejected => 'Rejected';

  @override
  String get brokerBannerPending =>
      'Your brokerage account is being reviewed. Live trading will be enabled once approved.';

  @override
  String get brokerBannerNotActive =>
      'Brokerage account not yet set up. Paper trading is active.';

  @override
  String get riskProfileSettingsLabel => 'Risk Profile';

  @override
  String get riskProfileTitle => 'Risk Profile';

  @override
  String riskProfileQuestionOf(int current, int total) {
    return '$current of $total';
  }

  @override
  String get riskProfileQ1 => 'What is your investment time horizon?';

  @override
  String get riskProfileQ1A1 => 'Less than 1 year';

  @override
  String get riskProfileQ1A2 => '1 to 3 years';

  @override
  String get riskProfileQ1A3 => '3 to 7 years';

  @override
  String get riskProfileQ1A4 => 'More than 7 years';

  @override
  String get riskProfileQ2 =>
      'If your portfolio dropped 20%, what would you do?';

  @override
  String get riskProfileQ2A1 => 'Sell everything';

  @override
  String get riskProfileQ2A2 => 'Sell some positions';

  @override
  String get riskProfileQ2A3 => 'Hold and wait';

  @override
  String get riskProfileQ2A4 => 'Buy more';

  @override
  String get riskProfileQ3 =>
      'How would you describe your investment experience?';

  @override
  String get riskProfileQ3A1 => 'None';

  @override
  String get riskProfileQ3A2 => 'Basic';

  @override
  String get riskProfileQ3A3 => 'Moderate';

  @override
  String get riskProfileQ3A4 => 'Advanced';

  @override
  String get riskProfileQ4 => 'How stable is your income?';

  @override
  String get riskProfileQ4A1 => 'Very unstable';

  @override
  String get riskProfileQ4A2 => 'Unstable';

  @override
  String get riskProfileQ4A3 => 'Stable';

  @override
  String get riskProfileQ4A4 => 'Very stable';

  @override
  String get riskProfileQ5 => 'What is your primary investment goal?';

  @override
  String get riskProfileQ5A1 => 'Preserve capital';

  @override
  String get riskProfileQ5A2 => 'Regular income';

  @override
  String get riskProfileQ5A3 => 'Moderate growth';

  @override
  String get riskProfileQ5A4 => 'Maximum growth';

  @override
  String get riskProfileNext => 'Next';

  @override
  String get riskProfileSubmit => 'See My Profile';

  @override
  String get riskProfileConservative => 'Conservative';

  @override
  String get riskProfileModerate => 'Moderate';

  @override
  String get riskProfileAggressive => 'Aggressive';

  @override
  String get riskProfileConservativeDesc =>
      'You prefer stability. Your portfolio prioritizes capital preservation with low-risk assets.';

  @override
  String get riskProfileModerateDesc =>
      'You seek balanced growth. Your portfolio mixes stable assets with moderate growth opportunities.';

  @override
  String get riskProfileAggressiveDesc =>
      'You seek maximum growth. Your portfolio focuses on high-growth assets and can handle volatility.';

  @override
  String get riskProfileRetake => 'Retake Questionnaire';

  @override
  String get riskProfileNotCompleted => 'Not completed';

  @override
  String get riskProfileLoadError => 'Could not load risk profile.';
}
