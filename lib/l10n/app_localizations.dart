import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('pt')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Investy'**
  String get appName;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navGoals.
  ///
  /// In en, this message translates to:
  /// **'Goals'**
  String get navGoals;

  /// No description provided for @navPortfolio.
  ///
  /// In en, this message translates to:
  /// **'Portfolio'**
  String get navPortfolio;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @commonConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get commonConfirm;

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// No description provided for @commonLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get commonLoading;

  /// No description provided for @commonEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get commonEmail;

  /// No description provided for @commonPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get commonPassword;

  /// No description provided for @commonName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get commonName;

  /// No description provided for @commonError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get commonError;

  /// No description provided for @commonLogOut.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get commonLogOut;

  /// No description provided for @errorRequiredField.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get errorRequiredField;

  /// No description provided for @errorInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get errorInvalidEmail;

  /// No description provided for @errorPasswordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get errorPasswordTooShort;

  /// No description provided for @errorPasswordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get errorPasswordMismatch;

  /// No description provided for @errorNetwork.
  ///
  /// In en, this message translates to:
  /// **'Network error. Check your connection.'**
  String get errorNetwork;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back!'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Securely access your investments.'**
  String get loginSubtitle;

  /// No description provided for @loginRememberEmail.
  ///
  /// In en, this message translates to:
  /// **'Remember email'**
  String get loginRememberEmail;

  /// No description provided for @loginOrContinueWith.
  ///
  /// In en, this message translates to:
  /// **'Or continue with'**
  String get loginOrContinueWith;

  /// No description provided for @loginEmailHint.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get loginEmailHint;

  /// No description provided for @loginPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get loginPasswordHint;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get loginButton;

  /// No description provided for @loginForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get loginForgotPassword;

  /// No description provided for @loginNoAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get loginNoAccount;

  /// No description provided for @loginSignUp.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get loginSignUp;

  /// No description provided for @loginWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get loginWithGoogle;

  /// No description provided for @signupTitle.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get signupTitle;

  /// No description provided for @signupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start investing today'**
  String get signupSubtitle;

  /// No description provided for @signupNameHint.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get signupNameHint;

  /// No description provided for @signupEmailHint.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get signupEmailHint;

  /// No description provided for @signupPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get signupPasswordHint;

  /// No description provided for @signupConfirmPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get signupConfirmPasswordHint;

  /// No description provided for @signupCurrencyLabel.
  ///
  /// In en, this message translates to:
  /// **'Display currency'**
  String get signupCurrencyLabel;

  /// No description provided for @signupButton.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get signupButton;

  /// No description provided for @signupHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get signupHaveAccount;

  /// No description provided for @signupLogIn.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get signupLogIn;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your email and we\'ll send you a reset link'**
  String get forgotPasswordSubtitle;

  /// No description provided for @forgotPasswordEmailHint.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get forgotPasswordEmailHint;

  /// No description provided for @forgotPasswordButton.
  ///
  /// In en, this message translates to:
  /// **'Send reset link'**
  String get forgotPasswordButton;

  /// No description provided for @forgotPasswordSuccess.
  ///
  /// In en, this message translates to:
  /// **'Reset link sent. Check your inbox.'**
  String get forgotPasswordSuccess;

  /// No description provided for @emailVerificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify your email'**
  String get emailVerificationTitle;

  /// No description provided for @emailVerificationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We sent a verification link to {email}. Check your inbox.'**
  String emailVerificationSubtitle(String email);

  /// No description provided for @emailVerificationResend.
  ///
  /// In en, this message translates to:
  /// **'Resend email'**
  String get emailVerificationResend;

  /// No description provided for @emailVerificationLogout.
  ///
  /// In en, this message translates to:
  /// **'Use a different account'**
  String get emailVerificationLogout;

  /// No description provided for @emailVerificationNotVerified.
  ///
  /// In en, this message translates to:
  /// **'Please verify your email first'**
  String get emailVerificationNotVerified;

  /// No description provided for @emailVerificationSent.
  ///
  /// In en, this message translates to:
  /// **'Verification email sent! Check your inbox'**
  String get emailVerificationSent;

  /// No description provided for @dashboardGreeting.
  ///
  /// In en, this message translates to:
  /// **'Hello, {name}'**
  String dashboardGreeting(String name);

  /// No description provided for @dashboardWelcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back,'**
  String get dashboardWelcomeBack;

  /// No description provided for @dashboardTotalBalance.
  ///
  /// In en, this message translates to:
  /// **'Total Balance'**
  String get dashboardTotalBalance;

  /// No description provided for @dashboardInvestedPortfolio.
  ///
  /// In en, this message translates to:
  /// **'Invested Portfolio'**
  String get dashboardInvestedPortfolio;

  /// No description provided for @dashboardCashToInvest.
  ///
  /// In en, this message translates to:
  /// **'Cash to Invest'**
  String get dashboardCashToInvest;

  /// No description provided for @dashboardInvestedValue.
  ///
  /// In en, this message translates to:
  /// **'Invested'**
  String get dashboardInvestedValue;

  /// No description provided for @dashboardRecentActivity.
  ///
  /// In en, this message translates to:
  /// **'Recent Activity'**
  String get dashboardRecentActivity;

  /// No description provided for @dashboardSeeAll.
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get dashboardSeeAll;

  /// No description provided for @dashboardNoActivity.
  ///
  /// In en, this message translates to:
  /// **'No recent activity'**
  String get dashboardNoActivity;

  /// No description provided for @dashboardBuy.
  ///
  /// In en, this message translates to:
  /// **'Buy'**
  String get dashboardBuy;

  /// No description provided for @dashboardSell.
  ///
  /// In en, this message translates to:
  /// **'Sell'**
  String get dashboardSell;

  /// No description provided for @dashboardTopUp.
  ///
  /// In en, this message translates to:
  /// **'Top Up'**
  String get dashboardTopUp;

  /// No description provided for @dashboardWithdraw.
  ///
  /// In en, this message translates to:
  /// **'Withdraw'**
  String get dashboardWithdraw;

  /// No description provided for @dashboardAvailableCash.
  ///
  /// In en, this message translates to:
  /// **'Available Cash'**
  String get dashboardAvailableCash;

  /// No description provided for @commonToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get commonToday;

  /// No description provided for @commonYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get commonYesterday;

  /// No description provided for @activityBought.
  ///
  /// In en, this message translates to:
  /// **'Bought {symbol}'**
  String activityBought(String symbol);

  /// No description provided for @activitySold.
  ///
  /// In en, this message translates to:
  /// **'Sold {symbol}'**
  String activitySold(String symbol);

  /// No description provided for @activityDeposit.
  ///
  /// In en, this message translates to:
  /// **'Deposit'**
  String get activityDeposit;

  /// No description provided for @activityWithdrawal.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal'**
  String get activityWithdrawal;

  /// No description provided for @activityUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get activityUnknown;

  /// No description provided for @portfolioTitle.
  ///
  /// In en, this message translates to:
  /// **'Portfolio'**
  String get portfolioTitle;

  /// No description provided for @portfolioNoHoldings.
  ///
  /// In en, this message translates to:
  /// **'No holdings yet.\nBuy your first asset to get started.'**
  String get portfolioNoHoldings;

  /// No description provided for @portfolioTotalInvested.
  ///
  /// In en, this message translates to:
  /// **'Total Invested'**
  String get portfolioTotalInvested;

  /// No description provided for @portfolioReturn.
  ///
  /// In en, this message translates to:
  /// **'Return'**
  String get portfolioReturn;

  /// No description provided for @portfolioQuantity.
  ///
  /// In en, this message translates to:
  /// **'Qty'**
  String get portfolioQuantity;

  /// No description provided for @portfolioAvgCost.
  ///
  /// In en, this message translates to:
  /// **'Avg cost'**
  String get portfolioAvgCost;

  /// No description provided for @portfolioCurrentPrice.
  ///
  /// In en, this message translates to:
  /// **'Current price'**
  String get portfolioCurrentPrice;

  /// No description provided for @portfolioAssetStock.
  ///
  /// In en, this message translates to:
  /// **'Stock'**
  String get portfolioAssetStock;

  /// No description provided for @portfolioAssetCrypto.
  ///
  /// In en, this message translates to:
  /// **'Crypto'**
  String get portfolioAssetCrypto;

  /// No description provided for @portfolioAssetEtf.
  ///
  /// In en, this message translates to:
  /// **'ETF'**
  String get portfolioAssetEtf;

  /// No description provided for @portfolioShares.
  ///
  /// In en, this message translates to:
  /// **'shares'**
  String get portfolioShares;

  /// No description provided for @goalsTitle.
  ///
  /// In en, this message translates to:
  /// **'Goals'**
  String get goalsTitle;

  /// No description provided for @goalsNoGoals.
  ///
  /// In en, this message translates to:
  /// **'No goals yet.\nCreate one to start saving.'**
  String get goalsNoGoals;

  /// No description provided for @goalsAddButton.
  ///
  /// In en, this message translates to:
  /// **'Add Goal'**
  String get goalsAddButton;

  /// No description provided for @goalProgress.
  ///
  /// In en, this message translates to:
  /// **'{percent}% funded'**
  String goalProgress(int percent);

  /// No description provided for @goalTarget.
  ///
  /// In en, this message translates to:
  /// **'Target'**
  String get goalTarget;

  /// No description provided for @goalSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get goalSaved;

  /// No description provided for @goalDeadline.
  ///
  /// In en, this message translates to:
  /// **'Deadline'**
  String get goalDeadline;

  /// No description provided for @goalCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get goalCategory;

  /// No description provided for @goalFormTitle.
  ///
  /// In en, this message translates to:
  /// **'New Goal'**
  String get goalFormTitle;

  /// No description provided for @goalFormNameHint.
  ///
  /// In en, this message translates to:
  /// **'Goal name'**
  String get goalFormNameHint;

  /// No description provided for @goalFormTargetHint.
  ///
  /// In en, this message translates to:
  /// **'Target amount'**
  String get goalFormTargetHint;

  /// No description provided for @goalFormDeadlineLabel.
  ///
  /// In en, this message translates to:
  /// **'Deadline'**
  String get goalFormDeadlineLabel;

  /// No description provided for @goalFormCategoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get goalFormCategoryLabel;

  /// No description provided for @goalFormSaveButton.
  ///
  /// In en, this message translates to:
  /// **'Save Goal'**
  String get goalFormSaveButton;

  /// No description provided for @goalFormSelectDate.
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get goalFormSelectDate;

  /// No description provided for @categoryCar.
  ///
  /// In en, this message translates to:
  /// **'Car'**
  String get categoryCar;

  /// No description provided for @categoryHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get categoryHome;

  /// No description provided for @categoryVacation.
  ///
  /// In en, this message translates to:
  /// **'Vacation'**
  String get categoryVacation;

  /// No description provided for @categoryTravel.
  ///
  /// In en, this message translates to:
  /// **'Travel'**
  String get categoryTravel;

  /// No description provided for @categoryEducation.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get categoryEducation;

  /// No description provided for @categoryEmergency.
  ///
  /// In en, this message translates to:
  /// **'Emergency'**
  String get categoryEmergency;

  /// No description provided for @categoryHealth.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get categoryHealth;

  /// No description provided for @categoryOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get categoryOther;

  /// No description provided for @buyAssetTitle.
  ///
  /// In en, this message translates to:
  /// **'Buy Asset'**
  String get buyAssetTitle;

  /// No description provided for @buySelectAsset.
  ///
  /// In en, this message translates to:
  /// **'Select an asset'**
  String get buySelectAsset;

  /// No description provided for @buyPerShare.
  ///
  /// In en, this message translates to:
  /// **'per share'**
  String get buyPerShare;

  /// No description provided for @buyEnterQuantity.
  ///
  /// In en, this message translates to:
  /// **'Enter quantity'**
  String get buyEnterQuantity;

  /// No description provided for @buyQuantityPositive.
  ///
  /// In en, this message translates to:
  /// **'Must be greater than 0'**
  String get buyQuantityPositive;

  /// No description provided for @buyConfirmButton.
  ///
  /// In en, this message translates to:
  /// **'Confirm Purchase'**
  String get buyConfirmButton;

  /// No description provided for @buyEstimatedTotal.
  ///
  /// In en, this message translates to:
  /// **'Estimated Total'**
  String get buyEstimatedTotal;

  /// No description provided for @buyTitle.
  ///
  /// In en, this message translates to:
  /// **'Buy {symbol}'**
  String buyTitle(String symbol);

  /// No description provided for @buyQuantityLabel.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get buyQuantityLabel;

  /// No description provided for @buyPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Price per unit'**
  String get buyPriceLabel;

  /// No description provided for @buyTotalLabel.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get buyTotalLabel;

  /// No description provided for @buyButton.
  ///
  /// In en, this message translates to:
  /// **'Buy'**
  String get buyButton;

  /// No description provided for @buySuccess.
  ///
  /// In en, this message translates to:
  /// **'Purchase successful'**
  String get buySuccess;

  /// No description provided for @sellAssetTitle.
  ///
  /// In en, this message translates to:
  /// **'Sell Asset'**
  String get sellAssetTitle;

  /// No description provided for @sellNoAssets.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have any assets yet'**
  String get sellNoAssets;

  /// No description provided for @sellNoAssetsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Buy your first asset to start building your portfolio.'**
  String get sellNoAssetsSubtitle;

  /// No description provided for @sellBuyFirstAsset.
  ///
  /// In en, this message translates to:
  /// **'Buy Your First Asset'**
  String get sellBuyFirstAsset;

  /// No description provided for @sellTitle.
  ///
  /// In en, this message translates to:
  /// **'Sell {symbol}'**
  String sellTitle(String symbol);

  /// No description provided for @sellQuantityLabel.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get sellQuantityLabel;

  /// No description provided for @sellSharesOwned.
  ///
  /// In en, this message translates to:
  /// **'{quantity} shares owned'**
  String sellSharesOwned(String quantity);

  /// No description provided for @sellPricePerShare.
  ///
  /// In en, this message translates to:
  /// **'Price per share (pre-filled from market)'**
  String get sellPricePerShare;

  /// No description provided for @sellEstimatedValue.
  ///
  /// In en, this message translates to:
  /// **'Estimated Value'**
  String get sellEstimatedValue;

  /// No description provided for @sellEnterQuantity.
  ///
  /// In en, this message translates to:
  /// **'Enter quantity'**
  String get sellEnterQuantity;

  /// No description provided for @sellQuantityPositive.
  ///
  /// In en, this message translates to:
  /// **'Must be greater than zero'**
  String get sellQuantityPositive;

  /// No description provided for @sellQuantityExceeds.
  ///
  /// In en, this message translates to:
  /// **'You only own {quantity} shares'**
  String sellQuantityExceeds(String quantity);

  /// No description provided for @sellEnterPrice.
  ///
  /// In en, this message translates to:
  /// **'Enter sell price'**
  String get sellEnterPrice;

  /// No description provided for @sellConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm Sale'**
  String get sellConfirm;

  /// No description provided for @sellButton.
  ///
  /// In en, this message translates to:
  /// **'Sell'**
  String get sellButton;

  /// No description provided for @sellSuccess.
  ///
  /// In en, this message translates to:
  /// **'Sale successful'**
  String get sellSuccess;

  /// No description provided for @sellMaxQuantity.
  ///
  /// In en, this message translates to:
  /// **'Max: {quantity}'**
  String sellMaxQuantity(String quantity);

  /// No description provided for @topUpTitle.
  ///
  /// In en, this message translates to:
  /// **'Top Up'**
  String get topUpTitle;

  /// No description provided for @topUpEnterAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter Amount'**
  String get topUpEnterAmount;

  /// No description provided for @topUpAmountRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter an amount'**
  String get topUpAmountRequired;

  /// No description provided for @topUpAmountInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid amount'**
  String get topUpAmountInvalid;

  /// No description provided for @topUpConfirmButton.
  ///
  /// In en, this message translates to:
  /// **'Confirm Deposit'**
  String get topUpConfirmButton;

  /// No description provided for @topUpAmountHint.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get topUpAmountHint;

  /// No description provided for @topUpButton.
  ///
  /// In en, this message translates to:
  /// **'Add funds'**
  String get topUpButton;

  /// No description provided for @topUpSuccess.
  ///
  /// In en, this message translates to:
  /// **'Funds added successfully'**
  String get topUpSuccess;

  /// No description provided for @withdrawTitle.
  ///
  /// In en, this message translates to:
  /// **'Withdraw'**
  String get withdrawTitle;

  /// No description provided for @withdrawCash.
  ///
  /// In en, this message translates to:
  /// **'Withdraw Cash'**
  String get withdrawCash;

  /// No description provided for @withdrawAvailableTo.
  ///
  /// In en, this message translates to:
  /// **'Available to Withdraw'**
  String get withdrawAvailableTo;

  /// No description provided for @withdrawConfirmButton.
  ///
  /// In en, this message translates to:
  /// **'Confirm Withdrawal'**
  String get withdrawConfirmButton;

  /// No description provided for @withdrawEnterAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount'**
  String get withdrawEnterAmount;

  /// No description provided for @withdrawAmountPositive.
  ///
  /// In en, this message translates to:
  /// **'Amount must be positive'**
  String get withdrawAmountPositive;

  /// No description provided for @withdrawAmountHint.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get withdrawAmountHint;

  /// No description provided for @withdrawButton.
  ///
  /// In en, this message translates to:
  /// **'Withdraw'**
  String get withdrawButton;

  /// No description provided for @withdrawSuccess.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal successful'**
  String get withdrawSuccess;

  /// No description provided for @withdrawInsufficientFunds.
  ///
  /// In en, this message translates to:
  /// **'Insufficient funds'**
  String get withdrawInsufficientFunds;

  /// No description provided for @assetSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search assets (e.g. AAPL, BTC)'**
  String get assetSearchHint;

  /// No description provided for @assetSearchEmpty.
  ///
  /// In en, this message translates to:
  /// **'No assets found'**
  String get assetSearchEmpty;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsCurrency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get settingsCurrency;

  /// No description provided for @settingsNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsNotifications;

  /// No description provided for @settingsPrivacySecurity.
  ///
  /// In en, this message translates to:
  /// **'Privacy & Security'**
  String get settingsPrivacySecurity;

  /// No description provided for @settingsAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearance;

  /// No description provided for @settingsAbout.
  ///
  /// In en, this message translates to:
  /// **'About Investy'**
  String get settingsAbout;

  /// No description provided for @settingsHelp.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get settingsHelp;

  /// No description provided for @securityTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy & Security'**
  String get securityTitle;

  /// No description provided for @securityAccountSection.
  ///
  /// In en, this message translates to:
  /// **'Account Security'**
  String get securityAccountSection;

  /// No description provided for @securityDangerSection.
  ///
  /// In en, this message translates to:
  /// **'Danger Zone'**
  String get securityDangerSection;

  /// No description provided for @securityChangePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get securityChangePassword;

  /// No description provided for @securityChangePasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Update your login password'**
  String get securityChangePasswordSubtitle;

  /// No description provided for @securityManagedByGoogle.
  ///
  /// In en, this message translates to:
  /// **'Managed by Google'**
  String get securityManagedByGoogle;

  /// No description provided for @securityDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get securityDeleteAccount;

  /// No description provided for @securityDeleteAccountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Permanently remove your account and all data'**
  String get securityDeleteAccountSubtitle;

  /// No description provided for @changePasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePasswordTitle;

  /// No description provided for @changePasswordCurrent.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get changePasswordCurrent;

  /// No description provided for @changePasswordNew.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get changePasswordNew;

  /// No description provided for @changePasswordConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm new password'**
  String get changePasswordConfirm;

  /// No description provided for @changePasswordButton.
  ///
  /// In en, this message translates to:
  /// **'Update password'**
  String get changePasswordButton;

  /// No description provided for @changePasswordSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password updated successfully'**
  String get changePasswordSuccess;

  /// No description provided for @changePasswordErrorWrongPassword.
  ///
  /// In en, this message translates to:
  /// **'Current password is incorrect.'**
  String get changePasswordErrorWrongPassword;

  /// No description provided for @changePasswordErrorRecentLogin.
  ///
  /// In en, this message translates to:
  /// **'Please sign out and sign back in before changing your password.'**
  String get changePasswordErrorRecentLogin;

  /// No description provided for @changePasswordErrorFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to change password. Please try again.'**
  String get changePasswordErrorFailed;

  /// No description provided for @deleteAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccountTitle;

  /// No description provided for @deleteAccountWarning.
  ///
  /// In en, this message translates to:
  /// **'This action is permanent and cannot be undone. All your data will be deleted.'**
  String get deleteAccountWarning;

  /// No description provided for @deleteAccountConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Deletion'**
  String get deleteAccountConfirmTitle;

  /// No description provided for @deleteAccountConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password to confirm'**
  String get deleteAccountConfirmPassword;

  /// No description provided for @deleteAccountConfirmEmail.
  ///
  /// In en, this message translates to:
  /// **'Type your email to confirm'**
  String get deleteAccountConfirmEmail;

  /// No description provided for @deleteAccountConfirmEmailText.
  ///
  /// In en, this message translates to:
  /// **'Type your account email to confirm deletion.'**
  String get deleteAccountConfirmEmailText;

  /// No description provided for @deleteAccountConfirmPasswordText.
  ///
  /// In en, this message translates to:
  /// **'Enter your password to confirm account deletion.'**
  String get deleteAccountConfirmPasswordText;

  /// No description provided for @deleteAccountEmailMismatch.
  ///
  /// In en, this message translates to:
  /// **'Email does not match. Please try again.'**
  String get deleteAccountEmailMismatch;

  /// No description provided for @deleteAccountEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password.'**
  String get deleteAccountEnterPassword;

  /// No description provided for @deleteAccountYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Your email: {email}'**
  String deleteAccountYourEmail(String email);

  /// No description provided for @deleteAccountButton.
  ///
  /// In en, this message translates to:
  /// **'Delete my account'**
  String get deleteAccountButton;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @notificationsPush.
  ///
  /// In en, this message translates to:
  /// **'Push Notifications'**
  String get notificationsPush;

  /// No description provided for @notificationsPushSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Receive alerts for goals and transactions'**
  String get notificationsPushSubtitle;

  /// No description provided for @notificationsGoalReminders.
  ///
  /// In en, this message translates to:
  /// **'Goal Reminders'**
  String get notificationsGoalReminders;

  /// No description provided for @notificationsGoalRemindersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Weekly progress reminders for your goals'**
  String get notificationsGoalRemindersSubtitle;

  /// No description provided for @notificationsEnable.
  ///
  /// In en, this message translates to:
  /// **'Enable notifications'**
  String get notificationsEnable;

  /// No description provided for @notificationsDescription.
  ///
  /// In en, this message translates to:
  /// **'You will be notified when:\n• A deposit or withdrawal is processed\n• A buy or sell order is confirmed\n• A financial goal deadline is approaching (30 days)'**
  String get notificationsDescription;

  /// No description provided for @appearanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearanceTitle;

  /// No description provided for @appearanceTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get appearanceTheme;

  /// No description provided for @appearanceThemeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get appearanceThemeSystem;

  /// No description provided for @appearanceThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get appearanceThemeLight;

  /// No description provided for @appearanceThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get appearanceThemeDark;

  /// No description provided for @appearanceLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get appearanceLanguage;

  /// No description provided for @languageEn.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEn;

  /// No description provided for @languageEs.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get languageEs;

  /// No description provided for @languagePt.
  ///
  /// In en, this message translates to:
  /// **'Portuguese (BR)'**
  String get languagePt;

  /// No description provided for @aboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About Investy'**
  String get aboutTitle;

  /// No description provided for @aboutVersion.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get aboutVersion;

  /// No description provided for @aboutDescription.
  ///
  /// In en, this message translates to:
  /// **'Investy helps you plan and track your investments toward your goals.'**
  String get aboutDescription;

  /// No description provided for @aboutTerms.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get aboutTerms;

  /// No description provided for @aboutPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get aboutPrivacy;

  /// No description provided for @helpTitle.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpTitle;

  /// No description provided for @helpFaq.
  ///
  /// In en, this message translates to:
  /// **'Frequently Asked Questions'**
  String get helpFaq;

  /// No description provided for @helpContact.
  ///
  /// In en, this message translates to:
  /// **'Contact Support'**
  String get helpContact;

  /// No description provided for @helpDocumentation.
  ///
  /// In en, this message translates to:
  /// **'Documentation'**
  String get helpDocumentation;

  /// No description provided for @helpReplyTime.
  ///
  /// In en, this message translates to:
  /// **'We reply within 24 hours'**
  String get helpReplyTime;

  /// No description provided for @helpFaq1Q.
  ///
  /// In en, this message translates to:
  /// **'How do I add money to my account?'**
  String get helpFaq1Q;

  /// No description provided for @helpFaq1A.
  ///
  /// In en, this message translates to:
  /// **'Tap \"Top-up\" on the home screen and enter the amount you want to deposit. The funds will be credited to your available cash balance.'**
  String get helpFaq1A;

  /// No description provided for @helpFaq2Q.
  ///
  /// In en, this message translates to:
  /// **'How do I buy an asset?'**
  String get helpFaq2Q;

  /// No description provided for @helpFaq2A.
  ///
  /// In en, this message translates to:
  /// **'Tap \"Buy\" on the home screen, search for the asset by name or ticker symbol, enter the quantity and confirm the purchase.'**
  String get helpFaq2A;

  /// No description provided for @helpFaq3Q.
  ///
  /// In en, this message translates to:
  /// **'How do I set a financial goal?'**
  String get helpFaq3Q;

  /// No description provided for @helpFaq3A.
  ///
  /// In en, this message translates to:
  /// **'Navigate to the Goals tab and tap the \"+\" button. Enter a name, target amount, category, and deadline. Your contributions will automatically count toward your goals.'**
  String get helpFaq3A;

  /// No description provided for @helpFaq4Q.
  ///
  /// In en, this message translates to:
  /// **'Can I withdraw my funds at any time?'**
  String get helpFaq4Q;

  /// No description provided for @helpFaq4A.
  ///
  /// In en, this message translates to:
  /// **'Yes. Tap \"Withdraw\" on the home screen and enter the amount. Withdrawals are processed from your available cash balance.'**
  String get helpFaq4A;

  /// No description provided for @helpFaq5Q.
  ///
  /// In en, this message translates to:
  /// **'What happens if I forget my password?'**
  String get helpFaq5Q;

  /// No description provided for @helpFaq5A.
  ///
  /// In en, this message translates to:
  /// **'On the login screen, tap \"Forgot password?\" and enter your email. We will send you a reset link within a few minutes.'**
  String get helpFaq5A;

  /// No description provided for @kycTitle.
  ///
  /// In en, this message translates to:
  /// **'Identity Verification'**
  String get kycTitle;

  /// No description provided for @kycIntroBody.
  ///
  /// In en, this message translates to:
  /// **'To start investing, we need to verify your identity. This is required by financial regulations and takes about 5 minutes.'**
  String get kycIntroBody;

  /// No description provided for @kycStartButton.
  ///
  /// In en, this message translates to:
  /// **'Start Verification'**
  String get kycStartButton;

  /// No description provided for @kycRetryButton.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get kycRetryButton;

  /// No description provided for @kycCameraPermissionTitle.
  ///
  /// In en, this message translates to:
  /// **'Camera Access Required'**
  String get kycCameraPermissionTitle;

  /// No description provided for @kycCameraPermissionBody.
  ///
  /// In en, this message translates to:
  /// **'Camera access was denied. Please enable it in Settings to complete identity verification.'**
  String get kycCameraPermissionBody;

  /// No description provided for @kycOpenSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get kycOpenSettings;

  /// No description provided for @kycApprovedTitle.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get kycApprovedTitle;

  /// No description provided for @kycApprovedBody.
  ///
  /// In en, this message translates to:
  /// **'Your identity has been verified. You can now buy and sell assets.'**
  String get kycApprovedBody;

  /// No description provided for @kycPendingTitle.
  ///
  /// In en, this message translates to:
  /// **'Under Review'**
  String get kycPendingTitle;

  /// No description provided for @kycPendingBody.
  ///
  /// In en, this message translates to:
  /// **'Your documents have been submitted. We typically complete verification within 24 hours.'**
  String get kycPendingBody;

  /// No description provided for @kycRejectedTitle.
  ///
  /// In en, this message translates to:
  /// **'Verification Failed'**
  String get kycRejectedTitle;

  /// No description provided for @kycRejectedBody.
  ///
  /// In en, this message translates to:
  /// **'We could not verify your identity. Please try again with a clear photo of your ID document.'**
  String get kycRejectedBody;

  /// No description provided for @kycBannerRequired.
  ///
  /// In en, this message translates to:
  /// **'Verify your identity to start trading. Tap here.'**
  String get kycBannerRequired;

  /// No description provided for @kycBannerPending.
  ///
  /// In en, this message translates to:
  /// **'Identity verification is under review. Trading will be enabled once approved.'**
  String get kycBannerPending;

  /// No description provided for @kycSettingsLabel.
  ///
  /// In en, this message translates to:
  /// **'Identity Verification'**
  String get kycSettingsLabel;

  /// No description provided for @kycReqLegalName.
  ///
  /// In en, this message translates to:
  /// **'Full legal name'**
  String get kycReqLegalName;

  /// No description provided for @kycReqDob.
  ///
  /// In en, this message translates to:
  /// **'Date of birth'**
  String get kycReqDob;

  /// No description provided for @kycReqAddress.
  ///
  /// In en, this message translates to:
  /// **'Residential address'**
  String get kycReqAddress;

  /// No description provided for @kycReqId.
  ///
  /// In en, this message translates to:
  /// **'Government-issued ID'**
  String get kycReqId;

  /// No description provided for @kycReqTaxId.
  ///
  /// In en, this message translates to:
  /// **'Tax identification number'**
  String get kycReqTaxId;

  /// No description provided for @brokerSettingsLabel.
  ///
  /// In en, this message translates to:
  /// **'Brokerage Account'**
  String get brokerSettingsLabel;

  /// No description provided for @brokerStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get brokerStatusPending;

  /// No description provided for @brokerStatusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get brokerStatusActive;

  /// No description provided for @brokerStatusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get brokerStatusRejected;

  /// No description provided for @brokerBannerPending.
  ///
  /// In en, this message translates to:
  /// **'Your brokerage account is being reviewed. Live trading will be enabled once approved.'**
  String get brokerBannerPending;

  /// No description provided for @brokerBannerNotActive.
  ///
  /// In en, this message translates to:
  /// **'Brokerage account not yet set up. Paper trading is active.'**
  String get brokerBannerNotActive;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
