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
  String get signupNameRequired => 'Full name is required';

  @override
  String get signupEmailRequired => 'Email is required';

  @override
  String get signupPasswordRequired => 'Password is required';

  @override
  String get signupPasswordMinLength => 'Minimum 6 characters';

  @override
  String get signupConfirmPasswordRequired => 'Please confirm your password';

  @override
  String get signupPasswordMismatch => 'Passwords do not match';

  @override
  String get signupShowPassword => 'Show password';

  @override
  String get signupHidePassword => 'Hide password';

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
  String get forgotPasswordEmailRequired => 'Email is required';

  @override
  String forgotPasswordSentMessage(String email) {
    return 'We sent a reset link to $email. Check your inbox and follow the instructions.';
  }

  @override
  String get forgotPasswordBackToSignIn => 'Back to Sign In';

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
  String get dashboardToday => 'today';

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
  String get activityDetailQuantity => 'Quantity';

  @override
  String get activityDetailPricePerUnit => 'Price per unit';

  @override
  String get activityDetailTotal => 'Total';

  @override
  String get activityDetailAmount => 'Amount';

  @override
  String get activityDetailDate => 'Date';

  @override
  String get activityDetailRealizedPnl => 'Realized P&L';

  @override
  String get activityDetailGain => 'Gain';

  @override
  String get activityDetailLoss => 'Loss';

  @override
  String get portfolioTitle => 'Portfolio';

  @override
  String get portfolioEmptyTitle => 'No holdings yet';

  @override
  String get portfolioEmptySubtitle =>
      'Buy your first asset to start building your portfolio.';

  @override
  String get portfolioEmptyCta => 'Buy my first asset';

  @override
  String get portfolioTotalInvested => 'Total Invested';

  @override
  String get portfolioTotalLabel => 'Total';

  @override
  String get portfolioReturn => 'Return';

  @override
  String get assetDetailPosition => 'Your position';

  @override
  String get assetDetailMarketValue => 'Market value';

  @override
  String get assetDetailShowAvgCost => 'My avg cost';

  @override
  String get portfolioQuantity => 'Qty';

  @override
  String get portfolioAvgCost => 'Avg cost';

  @override
  String get portfolioCurrentPrice => 'Current price';

  @override
  String get portfolioAssetStock => 'Stock';

  @override
  String get portfolioAssetCash => 'Cash';

  @override
  String get portfolioAllocationTitle => 'Allocation';

  @override
  String get chartPortfolioValue => 'Portfolio value';

  @override
  String get chartNotEnoughData => 'Not enough data yet to draw a chart.';

  @override
  String get chartRange1W => '1W';

  @override
  String get chartRange1M => '1M';

  @override
  String get chartRange3M => '3M';

  @override
  String get chartRange1Y => '1Y';

  @override
  String get chartRangeAll => 'ALL';

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
  String get goalsEmptyTitle => 'No goals yet';

  @override
  String get goalsEmptySubtitle =>
      'Set a goal and track how your investments get you there.';

  @override
  String get goalsEmptyCta => 'Create my first goal';

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
  String get goalCash => 'Cash';

  @override
  String get goalInvested => 'Invested';

  @override
  String get goalDetailInvestmentsTitle => 'Investments toward this goal';

  @override
  String get goalDetailNoInvestments =>
      'No investments assigned to this goal yet.';

  @override
  String get goalDetailCashTitle => 'Cash saved';

  @override
  String goalDetailProjection(String date) {
    return 'At this pace, you\'ll reach it around $date';
  }

  @override
  String get goalDetailProjectionUnknown =>
      'Add funds to see an estimated completion date.';

  @override
  String get goalProjectionTitle => 'Projection';

  @override
  String get goalOnTrack => 'On track';

  @override
  String get goalBehind => 'Behind';

  @override
  String get goalInvestButton => 'Invest toward this goal';

  @override
  String get buyAssignGoalLabel => 'Assign to a goal? (optional)';

  @override
  String get buyNoGoalOption => 'No goal';

  @override
  String get goalFormTitle => 'New Goal';

  @override
  String get goalFormNameHint => 'Goal name';

  @override
  String get goalFormCategoryLabel => 'Category';

  @override
  String get categoryCar => 'Car';

  @override
  String get categoryHome => 'Home';

  @override
  String get categoryVacation => 'Vacation';

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
  String buyTitle(String symbol) {
    return 'Buy $symbol';
  }

  @override
  String get buyInsufficientFunds =>
      'Insufficient funds. Top up your account to continue.';

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
      'We could not verify your identity, and this decision is final. If you believe this is a mistake, contact support.';

  @override
  String get kycRetryTitle => 'Almost There';

  @override
  String get kycRetryBody =>
      'We could not read your documents, but nothing is lost — you can submit them again.';

  @override
  String get kycRejectReasonsTitle => 'What to fix';

  @override
  String get kycRejectLabelBadPhoto =>
      'The photo was blurry or hard to read. Try again in good light.';

  @override
  String get kycRejectLabelScreenshot =>
      'Screenshots and photocopies are not accepted. Photograph the original document.';

  @override
  String get kycRejectLabelSelfie =>
      'Your selfie could not be matched. Look straight at the camera, with your face uncovered.';

  @override
  String get kycRejectLabelDocumentMissing =>
      'A page of the document was missing. Include the front and the back.';

  @override
  String get kycRejectLabelExpired =>
      'The document is expired. Use a valid one.';

  @override
  String get kycRejectLabelDataMismatch =>
      'The data on the document does not match what you entered.';

  @override
  String get kycRejectLabelEdited =>
      'The image looks edited or damaged. Send the original photo, unretouched.';

  @override
  String get kycRejectLabelEnvironment =>
      'The surroundings made the check impossible. Try somewhere well lit, with a plain background.';

  @override
  String get kycRejectLabelGeneric =>
      'There was a problem with the documents you sent.';

  @override
  String get kycDoneButton => 'Done';

  @override
  String get kycBannerRequired =>
      'Verify your identity to start trading. Tap here.';

  @override
  String get kycBannerRetry => 'Your verification needs another try. Tap here.';

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

  @override
  String get owlAiName => 'Owl AI';

  @override
  String get owlAiTagline => 'Investment picks made for you';

  @override
  String get owlAiPoweredAdvisor => 'AI-powered advisor';

  @override
  String get owlAiAnalyzing => 'Analyzing your portfolio…';

  @override
  String get owlAiStrongBuy => 'Strong buy';

  @override
  String get owlAiModerateSignal => 'Moderate';

  @override
  String get owlAiSuggested => 'Suggested:';

  @override
  String get owlAiBuyButton => 'BUY →';

  @override
  String get owlAiRefresh => 'Refresh analysis';

  @override
  String get owlAiUnavailable => 'AI advisor is temporarily unavailable.';

  @override
  String get owlAiErrorRetry => 'Could not load recommendations. Tap to retry.';

  @override
  String get owlAiRefreshing => 'Updating your recommendations…';

  @override
  String get owlAiRefreshingSubtitle => 'Analyzing your portfolio and goals';

  @override
  String get owlAiAskNewRecs => 'Refresh';

  @override
  String get owlHistoryButton => 'History';

  @override
  String get owlHistoryTitle => 'Owl AI History';

  @override
  String get owlHistoryEmpty =>
      'No sessions yet. Ask Owl for recommendations to start your history.';

  @override
  String owlHistorySessionBanner(String date) {
    return 'Session from $date';
  }

  @override
  String owlHistoryDaysAgo(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days ago',
      one: 'Yesterday',
      zero: 'Today',
    );
    return '$_temp0';
  }

  @override
  String owlHistoryContext(String portfolio, String cash) {
    return 'Portfolio $portfolio · Cash $cash';
  }

  @override
  String get owlAiCashAvailable => 'Available to invest';

  @override
  String get portfolioActive => 'Portfolio active';

  @override
  String get greetingMorning => 'Good morning,';

  @override
  String get greetingAfternoon => 'Good afternoon,';

  @override
  String get greetingEvening => 'Good evening,';

  @override
  String get alertsTitle => 'Price alerts';

  @override
  String get alertsSettingsLabel => 'Price alerts';

  @override
  String get alertsEmpty => 'You have no price alerts yet.';

  @override
  String get alertsEmptyHint =>
      'Create one to get notified when an asset hits your target price.';

  @override
  String get alertsCreateTitle => 'New price alert';

  @override
  String get alertsAssetLabel => 'Asset';

  @override
  String get alertsConditionLabel => 'Condition';

  @override
  String get alertsSearchHint => 'Search by symbol or name';

  @override
  String get alertsSelectAssetFirst => 'Select an asset first';

  @override
  String alertsCurrentPrice(String price) {
    return 'Current: $price';
  }

  @override
  String get alertsDirectionAbove => 'Rises to or above';

  @override
  String get alertsDirectionBelow => 'Falls to or below';

  @override
  String get alertsTargetPriceHint => 'Target price (USD)';

  @override
  String get alertsCreateButton => 'Create alert';

  @override
  String get alertsCreated => 'Alert created';

  @override
  String get alertsDeleted => 'Alert deleted';

  @override
  String get alertsStatusActive => 'Active';

  @override
  String get alertsStatusTriggered => 'Triggered';

  @override
  String alertsConditionAbove(String price) {
    return 'Above $price';
  }

  @override
  String alertsConditionBelow(String price) {
    return 'Below $price';
  }

  @override
  String get alertsErrorAlreadyMet =>
      'The current price already meets this target. Choose a different one.';

  @override
  String get alertsErrorLimit =>
      'You\'ve reached the maximum of 20 active alerts.';

  @override
  String get alertsErrorDuplicate =>
      'You already have an identical alert for this asset.';

  @override
  String get alertsErrorUnknownSymbol => 'Unknown asset.';

  @override
  String get alertsDeleteTooltip => 'Delete alert';

  @override
  String get loginSessionTerminated =>
      'Your session was terminated. Please sign in again.';

  @override
  String get authErrorUserNotFound => 'No account found with this email';

  @override
  String get authErrorInvalidCredentials => 'Invalid email or password';

  @override
  String get authErrorInvalidEmail => 'Invalid email format';

  @override
  String get authErrorUserDisabled => 'This account has been disabled';

  @override
  String get authErrorTooManyRequests =>
      'Too many failed attempts. Please try again later';

  @override
  String get authErrorNetwork => 'Network error. Please check your connection';

  @override
  String get authErrorEmailInUse => 'An account with this email already exists';

  @override
  String get authErrorWeakPassword =>
      'Password is too weak. Use at least 6 characters';

  @override
  String get authErrorOperationNotAllowed =>
      'Email/password accounts are not enabled';

  @override
  String get authErrorAccountExistsDifferentMethod =>
      'An account already exists with this email using a different sign-in method';

  @override
  String get authErrorGoogleCancelled => 'Google sign-in was cancelled';

  @override
  String get authErrorWrongPassword => 'Password is incorrect';

  @override
  String get authErrorRequiresRecentLogin =>
      'Please sign out and sign back in first';

  @override
  String get authErrorNoUser => 'No user is logged in';

  @override
  String get authErrorVerificationEmailFailed =>
      'Failed to send verification email. Please try again';

  @override
  String get authErrorRefreshFailed =>
      'Failed to refresh status. Please try again';

  @override
  String get authErrorDeletionFailed =>
      'Account deletion failed. Please try again';

  @override
  String get authErrorUnexpected =>
      'An unexpected error occurred. Please try again';

  @override
  String get goalFormTargetLabel => 'Target Amount';

  @override
  String get goalFormDateLabel => 'Target Date';

  @override
  String get goalFormCreateButton => 'Create Goal';

  @override
  String get goalFormNameRequired => 'Enter a goal name';

  @override
  String get goalFormTargetRequired => 'Enter a target amount';

  @override
  String get goalFormTargetInvalid => 'Amount must be greater than zero';

  @override
  String get goalFormDateRequired => 'Select a target date';

  @override
  String get goalFormCustomDate => 'Custom';

  @override
  String get goalFormCreateFailed =>
      'Could not create the goal. Please try again.';

  @override
  String goalPresetMonths(int months) {
    return '${months}M';
  }

  @override
  String goalPresetYears(int years) {
    return '${years}Y';
  }

  @override
  String get withdrawMaxChip => 'MAX';

  @override
  String get currencyUSD => 'US Dollar';

  @override
  String get currencyEUR => 'Euro';

  @override
  String get currencyGBP => 'British Pound';

  @override
  String get currencyCOP => 'Colombian Peso';

  @override
  String get currencyBRL => 'Brazilian Real';

  @override
  String get currencyMXN => 'Mexican Peso';

  @override
  String get currencyCAD => 'Canadian Dollar';

  @override
  String get currencyARS => 'Argentine Peso';

  @override
  String get currencyCLP => 'Chilean Peso';

  @override
  String get currencyPEN => 'Peruvian Sol';

  @override
  String get currencyCHF => 'Swiss Franc';

  @override
  String get currencyJPY => 'Japanese Yen';

  @override
  String get currencyAUD => 'Australian Dollar';

  @override
  String get tradingSubtotal => 'Subtotal';

  @override
  String get tradingCommission => 'Investy commission';

  @override
  String get tradingFeeSec31 => 'SEC fee';

  @override
  String get tradingFeeFinraTaf => 'FINRA activity fee';

  @override
  String get tradingFeeFinraCat => 'FINRA CAT fee';

  @override
  String get tradingFeeBrokerSpread => 'Broker fee';

  @override
  String get tradingTotalToPay => 'Total to pay';

  @override
  String get tradingYouReceive => 'You receive';

  @override
  String get tradingQuoteUnavailable =>
      'Couldn\'t calculate the cost. Try again.';

  @override
  String tradingOrderTooSmall(String min) {
    return 'The minimum order is $min';
  }

  @override
  String get tradingSellTooSmall =>
      'This sale doesn\'t cover its fees. Sell a bit more.';

  @override
  String get onboardCurrencyTitle => 'Choose your display currency';

  @override
  String get onboardCurrencyBody =>
      'You\'ll see your balances and prices in this currency. It can\'t be changed later.';

  @override
  String get fitTitle => 'How well this fits you';

  @override
  String get fitWhy => 'See why';

  @override
  String get fitHide => 'Hide';

  @override
  String fitScoreOutOf(int score) {
    return '$score out of 100';
  }

  @override
  String fitConfidence(int pct) {
    return 'Confidence: $pct%';
  }

  @override
  String fitForGoal(String goal) {
    return 'Assessed against your goal “$goal”';
  }

  @override
  String get fitNoGoal => 'Not tied to any goal';

  @override
  String get fitCantAssessTitle => 'We can’t assess this yet';

  @override
  String get fitCantAssessBody =>
      'A fit score is a claim about your situation, and we don’t know enough about it to make one.';

  @override
  String get fitAboutYouTitle => 'What would help';

  @override
  String get fitAboutOurDataTitle => 'On our side';

  @override
  String get fitDisclaimer =>
      'This describes how a purchase relates to what you’ve told us. It is not financial advice.';

  @override
  String get fitLevelHigh => 'Good fit';

  @override
  String get fitLevelMedium => 'Partial fit';

  @override
  String get fitLevelLow => 'Poor fit';

  @override
  String get fitCappedConcentration =>
      'Held down because this would be a large part of everything you own — this applies whatever your risk profile says.';

  @override
  String get fitCappedHorizon =>
      'Held down because your deadline arrives sooner than this kind of asset usually needs — this applies whatever your risk profile says.';

  @override
  String get fitComponentProfile => 'Fits your profile';

  @override
  String get fitComponentHorizon => 'Time until your deadline';

  @override
  String get fitComponentDiversification => 'Effect on your mix';

  @override
  String get fitComponentConcentration => 'Share of your portfolio';

  @override
  String get fitComponentVolatility => 'How much it moved';

  @override
  String get fitUnmeasured => 'Not measured';

  @override
  String fitVolatilityObserved(String pct) {
    return 'Moved $pct% a year';
  }

  @override
  String get fitCaveatShortWindow =>
      'Measured over a short window — we don’t have much price history yet.';

  @override
  String get fitReasonNoProfile =>
      'You haven’t answered the risk questionnaire yet.';

  @override
  String get fitReasonClassNotInPlan =>
      'Your profile doesn’t allocate anything to this kind of asset.';

  @override
  String get fitReasonClassNotInPlanMix =>
      'It moves you away from the mix you chose: your plan allocates nothing to this kind of asset.';

  @override
  String get fitReasonClassCore =>
      'This is the kind of asset your profile leans on most.';

  @override
  String get fitReasonClassSupporting =>
      'This kind of asset has a place in your plan, with a smaller weight.';

  @override
  String get fitReasonNoGoal =>
      'This purchase isn’t tied to a goal, so there’s no deadline to measure against.';

  @override
  String get fitReasonHorizonComfortable =>
      'There’s plenty of time before your deadline.';

  @override
  String get fitReasonHorizonTight =>
      'There’s enough time, but not much margin.';

  @override
  String get fitReasonHorizonTooShort =>
      'Your deadline arrives before this kind of asset usually has time to recover.';

  @override
  String get fitReasonNoPortfolio =>
      'You don’t hold anything yet, so there’s no mix to compare against.';

  @override
  String get fitReasonFillsGap =>
      'This purchase moves you toward the mix you chose.';

  @override
  String get fitReasonNearTarget =>
      'This lands a little above your target for this kind of asset.';

  @override
  String get fitReasonOverTarget =>
      'This pushes you well past your target for this kind of asset.';

  @override
  String get fitReasonConcentrationLow =>
      'This stays a small part of everything you own.';

  @override
  String get fitReasonConcentrationMid =>
      'This position would be big enough to move your portfolio on its own.';

  @override
  String get fitReasonConcentrationHigh =>
      'Much of what you own would ride on this one asset.';

  @override
  String get fitReasonNoHistory =>
      'We don’t have enough price history to measure this yet.';

  @override
  String get fitReasonVolCalm =>
      'It moved less than others of its kind usually do.';

  @override
  String get fitReasonVolTypical =>
      'It moved about as much as others of its kind usually do.';

  @override
  String get fitReasonVolElevated =>
      'It moved noticeably more than others of its kind.';

  @override
  String get fitReasonVolExtreme =>
      'It moved so much that its category understates the risk.';

  @override
  String get fitUnavailable => 'We couldn’t assess this purchase right now.';

  @override
  String get fitCappedClassNotInPlan =>
      'Held down because your profile allocates nothing to this kind of asset — that is how you set it.';
}
