import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_sw.dart';

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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('ar'),
    Locale('en'),
    Locale('sw'),
  ];

  /// Application title
  ///
  /// In en, this message translates to:
  /// **'Emergency Health System'**
  String get appTitle;

  /// Settings screen title
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Language preference label
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  /// No description provided for @app.
  ///
  /// In en, this message translates to:
  /// **'App'**
  String get app;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @helpSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpSupport;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @role.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get role;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @specialtyProfession.
  ///
  /// In en, this message translates to:
  /// **'Specialty / Profession'**
  String get specialtyProfession;

  /// No description provided for @assignedFacility.
  ///
  /// In en, this message translates to:
  /// **'Assigned Facility'**
  String get assignedFacility;

  /// No description provided for @settlementCamp.
  ///
  /// In en, this message translates to:
  /// **'Settlement / Camp'**
  String get settlementCamp;

  /// About dialog content
  ///
  /// In en, this message translates to:
  /// **'HealthAlert\n\nVersion 1.0.0\n\nEmergency communication for front line health response.'**
  String get aboutMessage;

  /// No description provided for @failedToSaveLanguage.
  ///
  /// In en, this message translates to:
  /// **'Failed to save language preference'**
  String get failedToSaveLanguage;

  /// No description provided for @helpSupportComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Help & Support coming soon'**
  String get helpSupportComingSoon;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageSwahili.
  ///
  /// In en, this message translates to:
  /// **'Kiswahili'**
  String get languageSwahili;

  /// No description provided for @languageArabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get languageArabic;

  /// No description provided for @changeLanguageConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Change language?'**
  String get changeLanguageConfirmTitle;

  /// No description provided for @changeLanguageConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Change language to {language}? The app will update immediately.'**
  String changeLanguageConfirmMessage(String language);

  /// No description provided for @languageChangedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Language changed to {language}'**
  String languageChangedSuccess(String language);

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @reports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reports;

  /// No description provided for @analytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get analytics;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @menu.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menu;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @searchByPatientNameOrId.
  ///
  /// In en, this message translates to:
  /// **'Search by patient name or ID...'**
  String get searchByPatientNameOrId;

  /// No description provided for @searchByPatientNameOrType.
  ///
  /// In en, this message translates to:
  /// **'Search by patient name or emergency type...'**
  String get searchByPatientNameOrType;

  /// No description provided for @searchByPatientNameIdOrType.
  ///
  /// In en, this message translates to:
  /// **'Search by patient name, ID, or type...'**
  String get searchByPatientNameIdOrType;

  /// No description provided for @searchByPatientVhtOrType.
  ///
  /// In en, this message translates to:
  /// **'Search by patient, VHT, or type...'**
  String get searchByPatientVhtOrType;

  /// No description provided for @searchUsers.
  ///
  /// In en, this message translates to:
  /// **'Search users...'**
  String get searchUsers;

  /// No description provided for @tapToReview.
  ///
  /// In en, this message translates to:
  /// **'Tap to review'**
  String get tapToReview;

  /// No description provided for @voiceNote.
  ///
  /// In en, this message translates to:
  /// **'Voice note'**
  String get voiceNote;

  /// No description provided for @reviewPatient.
  ///
  /// In en, this message translates to:
  /// **'Review Patient'**
  String get reviewPatient;

  /// No description provided for @newEmergency.
  ///
  /// In en, this message translates to:
  /// **'New Emergency'**
  String get newEmergency;

  /// No description provided for @reportEmergency.
  ///
  /// In en, this message translates to:
  /// **'Report Emergency'**
  String get reportEmergency;

  /// No description provided for @selectTypeOfEmergency.
  ///
  /// In en, this message translates to:
  /// **'Select the type of emergency'**
  String get selectTypeOfEmergency;

  /// No description provided for @areaMap.
  ///
  /// In en, this message translates to:
  /// **'Area Map'**
  String get areaMap;

  /// No description provided for @navigationMap.
  ///
  /// In en, this message translates to:
  /// **'Navigation Map'**
  String get navigationMap;

  /// No description provided for @birth.
  ///
  /// In en, this message translates to:
  /// **'Birth'**
  String get birth;

  /// No description provided for @trauma.
  ///
  /// In en, this message translates to:
  /// **'Trauma'**
  String get trauma;

  /// No description provided for @infection.
  ///
  /// In en, this message translates to:
  /// **'Infection'**
  String get infection;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back!'**
  String get welcomeBack;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @pin.
  ///
  /// In en, this message translates to:
  /// **'PIN'**
  String get pin;

  /// No description provided for @enterPin.
  ///
  /// In en, this message translates to:
  /// **'Enter PIN'**
  String get enterPin;

  /// No description provided for @reenterPin.
  ///
  /// In en, this message translates to:
  /// **'Re-enter PIN'**
  String get reenterPin;

  /// No description provided for @setUpPin.
  ///
  /// In en, this message translates to:
  /// **'Set Up PIN'**
  String get setUpPin;

  /// No description provided for @confirmPin.
  ///
  /// In en, this message translates to:
  /// **'Confirm PIN'**
  String get confirmPin;

  /// No description provided for @verifyPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Verify Phone Number'**
  String get verifyPhoneNumber;

  /// No description provided for @verifyEmail.
  ///
  /// In en, this message translates to:
  /// **'Verify Email'**
  String get verifyEmail;

  /// No description provided for @getVerificationCode.
  ///
  /// In en, this message translates to:
  /// **'Get Verification Code'**
  String get getVerificationCode;

  /// No description provided for @codeSentResend.
  ///
  /// In en, this message translates to:
  /// **'Code Sent - Resend?'**
  String get codeSentResend;

  /// No description provided for @resendVerificationCode.
  ///
  /// In en, this message translates to:
  /// **'Resend Verification Code'**
  String get resendVerificationCode;

  /// No description provided for @verificationCode.
  ///
  /// In en, this message translates to:
  /// **'Verification Code'**
  String get verificationCode;

  /// No description provided for @goBack.
  ///
  /// In en, this message translates to:
  /// **'Go back'**
  String get goBack;

  /// No description provided for @goBackAndTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Go back and try again'**
  String get goBackAndTryAgain;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @registerNewAccount.
  ///
  /// In en, this message translates to:
  /// **'Register new account'**
  String get registerNewAccount;

  /// No description provided for @alreadyHaveAccountLogin.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Login'**
  String get alreadyHaveAccountLogin;

  /// No description provided for @forgotPinRegisterAgain.
  ///
  /// In en, this message translates to:
  /// **'Forgot PIN? Register again'**
  String get forgotPinRegisterAgain;

  /// No description provided for @vhtDetails.
  ///
  /// In en, this message translates to:
  /// **'VHT Details'**
  String get vhtDetails;

  /// No description provided for @ambulanceDriverDetails.
  ///
  /// In en, this message translates to:
  /// **'Ambulance Driver Details'**
  String get ambulanceDriverDetails;

  /// No description provided for @adminDetails.
  ///
  /// In en, this message translates to:
  /// **'Admin Details'**
  String get adminDetails;

  /// No description provided for @clinicianDetails.
  ///
  /// In en, this message translates to:
  /// **'Clinician Details'**
  String get clinicianDetails;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get lastName;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address *'**
  String get emailAddress;

  /// No description provided for @phoneNumberHint.
  ///
  /// In en, this message translates to:
  /// **'+256700000001'**
  String get phoneNumberHint;

  /// No description provided for @verificationCodeHint.
  ///
  /// In en, this message translates to:
  /// **'123456'**
  String get verificationCodeHint;

  /// No description provided for @adminVerificationCodeHint.
  ///
  /// In en, this message translates to:
  /// **'1234'**
  String get adminVerificationCodeHint;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'admin@example.com'**
  String get emailHint;

  /// No description provided for @iAmA.
  ///
  /// In en, this message translates to:
  /// **'I am a...'**
  String get iAmA;

  /// No description provided for @pinHelperText.
  ///
  /// In en, this message translates to:
  /// **'4-6 digits'**
  String get pinHelperText;

  /// No description provided for @pleaseEnterPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter your phone number'**
  String get pleaseEnterPhoneNumber;

  /// No description provided for @pleaseEnterPin.
  ///
  /// In en, this message translates to:
  /// **'Please enter your PIN'**
  String get pleaseEnterPin;

  /// No description provided for @pinMustBeDigits.
  ///
  /// In en, this message translates to:
  /// **'PIN must be 4-6 digits'**
  String get pinMustBeDigits;

  /// No description provided for @incorrectPinTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Incorrect PIN. Please try again.'**
  String get incorrectPinTryAgain;

  /// No description provided for @userDataNotLoaded.
  ///
  /// In en, this message translates to:
  /// **'User data not loaded. Please try again.'**
  String get userDataNotLoaded;

  /// No description provided for @noAccountFoundRegisterFirst.
  ///
  /// In en, this message translates to:
  /// **'No account found with this phone number. Please register first.'**
  String get noAccountFoundRegisterFirst;

  /// No description provided for @errorLoadingUserData.
  ///
  /// In en, this message translates to:
  /// **'Error loading user data'**
  String get errorLoadingUserData;

  /// No description provided for @pleaseEnterVerificationCode.
  ///
  /// In en, this message translates to:
  /// **'Please enter the verification code'**
  String get pleaseEnterVerificationCode;

  /// No description provided for @loginSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Login successful!'**
  String get loginSuccessful;

  /// No description provided for @verificationCodeSentToEmail.
  ///
  /// In en, this message translates to:
  /// **'Verification code sent to your email'**
  String get verificationCodeSentToEmail;

  /// No description provided for @verificationCodeResentToEmail.
  ///
  /// In en, this message translates to:
  /// **'Verification code resent to your email'**
  String get verificationCodeResentToEmail;

  /// No description provided for @pleaseEnterEmailAddress.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email address'**
  String get pleaseEnterEmailAddress;

  /// No description provided for @pleaseVerifyEmailFirst.
  ///
  /// In en, this message translates to:
  /// **'Please verify your email first by clicking \"Get Verification Code\"'**
  String get pleaseVerifyEmailFirst;

  /// No description provided for @failedToSendVerificationCode.
  ///
  /// In en, this message translates to:
  /// **'Failed to send verification code'**
  String get failedToSendVerificationCode;

  /// No description provided for @failedToResendCode.
  ///
  /// In en, this message translates to:
  /// **'Failed to resend code'**
  String get failedToResendCode;

  /// No description provided for @verificationFailed.
  ///
  /// In en, this message translates to:
  /// **'Verification failed'**
  String get verificationFailed;

  /// No description provided for @registrationFailed.
  ///
  /// In en, this message translates to:
  /// **'Registration failed'**
  String get registrationFailed;

  /// No description provided for @verificationError.
  ///
  /// In en, this message translates to:
  /// **'Verification error'**
  String get verificationError;

  /// No description provided for @phoneNumberMinDigits.
  ///
  /// In en, this message translates to:
  /// **'Phone number must be at least 9 digits'**
  String get phoneNumberMinDigits;

  /// No description provided for @userExistsPleaseLogin.
  ///
  /// In en, this message translates to:
  /// **'User with this phone number already exists. Please login instead.'**
  String get userExistsPleaseLogin;

  /// No description provided for @pleaseEnterFirstName.
  ///
  /// In en, this message translates to:
  /// **'Please enter your first name'**
  String get pleaseEnterFirstName;

  /// No description provided for @pleaseEnterLastName.
  ///
  /// In en, this message translates to:
  /// **'Please enter your last name'**
  String get pleaseEnterLastName;

  /// No description provided for @pleaseSelectProfession.
  ///
  /// In en, this message translates to:
  /// **'Please select your profession'**
  String get pleaseSelectProfession;

  /// No description provided for @pleaseSelectSettlementCamp.
  ///
  /// In en, this message translates to:
  /// **'Please select your settlement / camp'**
  String get pleaseSelectSettlementCamp;

  /// No description provided for @pleaseSelectHealthFacility.
  ///
  /// In en, this message translates to:
  /// **'Please select your health facility'**
  String get pleaseSelectHealthFacility;

  /// No description provided for @welcomeBackDr.
  ///
  /// In en, this message translates to:
  /// **'Welcome back, Dr. {name}'**
  String welcomeBackDr(String name);

  /// No description provided for @welcomeBackName.
  ///
  /// In en, this message translates to:
  /// **'Welcome back, {name}'**
  String welcomeBackName(String name);

  /// No description provided for @user.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get user;

  /// No description provided for @vht.
  ///
  /// In en, this message translates to:
  /// **'VHT'**
  String get vht;

  /// No description provided for @ambulance.
  ///
  /// In en, this message translates to:
  /// **'Ambulance'**
  String get ambulance;

  /// No description provided for @clinic.
  ///
  /// In en, this message translates to:
  /// **'Clinic'**
  String get clinic;

  /// No description provided for @admin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get admin;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @age.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get age;

  /// No description provided for @enterAgeInYears.
  ///
  /// In en, this message translates to:
  /// **'Enter age in years'**
  String get enterAgeInYears;

  /// No description provided for @typeImportantNotes.
  ///
  /// In en, this message translates to:
  /// **'Type any important notes…'**
  String get typeImportantNotes;

  /// No description provided for @selectTriageLevel.
  ///
  /// In en, this message translates to:
  /// **'Select triage level'**
  String get selectTriageLevel;

  /// No description provided for @selectFacility.
  ///
  /// In en, this message translates to:
  /// **'Select a facility…'**
  String get selectFacility;

  /// No description provided for @pleaseSelectPatientGender.
  ///
  /// In en, this message translates to:
  /// **'Please select patient gender.'**
  String get pleaseSelectPatientGender;

  /// No description provided for @pleaseEnterDobOrAge.
  ///
  /// In en, this message translates to:
  /// **'Please enter patient date of birth or age.'**
  String get pleaseEnterDobOrAge;

  /// No description provided for @pleaseSelectTriageLevel.
  ///
  /// In en, this message translates to:
  /// **'Please select a triage level.'**
  String get pleaseSelectTriageLevel;

  /// No description provided for @pleaseSelectHealthFacilityToNotify.
  ///
  /// In en, this message translates to:
  /// **'Please select the health facility to notify.'**
  String get pleaseSelectHealthFacilityToNotify;

  /// No description provided for @locationPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Location Permission Required'**
  String get locationPermissionRequired;

  /// No description provided for @pleaseEnableLocationInSettings.
  ///
  /// In en, this message translates to:
  /// **'Please open Settings and enable location for this app.'**
  String get pleaseEnableLocationInSettings;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get openSettings;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// No description provided for @critical.
  ///
  /// In en, this message translates to:
  /// **'Critical'**
  String get critical;

  /// No description provided for @high.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get high;

  /// No description provided for @moderate.
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get moderate;

  /// No description provided for @low.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get low;

  /// No description provided for @pleaseSelectAnotherFacilityOrContactSupervisor.
  ///
  /// In en, this message translates to:
  /// **'Please select another facility or contact your supervisor.'**
  String get pleaseSelectAnotherFacilityOrContactSupervisor;

  /// No description provided for @warningFailedUploadMedia.
  ///
  /// In en, this message translates to:
  /// **'Warning: Failed to upload {files}. Case will be submitted without media.'**
  String warningFailedUploadMedia(String files);

  /// No description provided for @warningMediaUploadFailed.
  ///
  /// In en, this message translates to:
  /// **'Warning: Media upload failed. Case will be submitted without media.'**
  String get warningMediaUploadFailed;

  /// No description provided for @errorSubmittingCase.
  ///
  /// In en, this message translates to:
  /// **'Error submitting case'**
  String get errorSubmittingCase;

  /// No description provided for @retryLocationCapture.
  ///
  /// In en, this message translates to:
  /// **'Retry Location Capture'**
  String get retryLocationCapture;

  /// No description provided for @failedToCaptureLocation.
  ///
  /// In en, this message translates to:
  /// **'Failed to capture location. Please try again.'**
  String get failedToCaptureLocation;

  /// No description provided for @errorCreatingEmergencyCase.
  ///
  /// In en, this message translates to:
  /// **'Error creating emergency case'**
  String get errorCreatingEmergencyCase;

  /// No description provided for @sendFollowUpUpdate.
  ///
  /// In en, this message translates to:
  /// **'Send Follow-up Update'**
  String get sendFollowUpUpdate;

  /// No description provided for @provideUpdateOnCondition.
  ///
  /// In en, this message translates to:
  /// **'Provide an update on the patient\'s current condition:'**
  String get provideUpdateOnCondition;

  /// No description provided for @sendUpdate.
  ///
  /// In en, this message translates to:
  /// **'Send Update'**
  String get sendUpdate;

  /// No description provided for @followUpUpdateSentSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Follow-up update sent successfully.'**
  String get followUpUpdateSentSuccessfully;

  /// No description provided for @failedToSendFollowUp.
  ///
  /// In en, this message translates to:
  /// **'Failed to send follow-up'**
  String get failedToSendFollowUp;

  /// No description provided for @caseNotFound.
  ///
  /// In en, this message translates to:
  /// **'Case not found.'**
  String get caseNotFound;

  /// No description provided for @noAdminContactFound.
  ///
  /// In en, this message translates to:
  /// **'No admin contact found.'**
  String get noAdminContactFound;

  /// No description provided for @couldNotOpenDialer.
  ///
  /// In en, this message translates to:
  /// **'Could not open dialer for {phone}'**
  String couldNotOpenDialer(String phone);

  /// No description provided for @errorFindingAdmin.
  ///
  /// In en, this message translates to:
  /// **'Error finding admin'**
  String get errorFindingAdmin;

  /// No description provided for @clinicianAdvice.
  ///
  /// In en, this message translates to:
  /// **'Clinician Advice'**
  String get clinicianAdvice;

  /// No description provided for @clinicianNotes.
  ///
  /// In en, this message translates to:
  /// **'Clinician Notes'**
  String get clinicianNotes;

  /// No description provided for @callClinician.
  ///
  /// In en, this message translates to:
  /// **'Call Clinician'**
  String get callClinician;

  /// No description provided for @callAmbulanceDriver.
  ///
  /// In en, this message translates to:
  /// **'Call Ambulance Driver'**
  String get callAmbulanceDriver;

  /// No description provided for @noContactsAvailableYet.
  ///
  /// In en, this message translates to:
  /// **'No contacts available yet.'**
  String get noContactsAvailableYet;

  /// No description provided for @couldNotLoadImage.
  ///
  /// In en, this message translates to:
  /// **'Could not load image'**
  String get couldNotLoadImage;

  /// No description provided for @tapImageToViewFullScreen.
  ///
  /// In en, this message translates to:
  /// **'Tap image to view full screen'**
  String get tapImageToViewFullScreen;

  /// No description provided for @videoAttached.
  ///
  /// In en, this message translates to:
  /// **'Video Attached'**
  String get videoAttached;

  /// No description provided for @tapToPlayVideo.
  ///
  /// In en, this message translates to:
  /// **'Tap to play video'**
  String get tapToPlayVideo;

  /// No description provided for @latestFollowUp.
  ///
  /// In en, this message translates to:
  /// **'Latest Follow-up'**
  String get latestFollowUp;

  /// No description provided for @needHelpWithDispatch.
  ///
  /// In en, this message translates to:
  /// **'Need help with dispatch?'**
  String get needHelpWithDispatch;

  /// No description provided for @contactAdminForDispatch.
  ///
  /// In en, this message translates to:
  /// **'Contact the admin to check on dispatch status.'**
  String get contactAdminForDispatch;

  /// No description provided for @callAdmin.
  ///
  /// In en, this message translates to:
  /// **'Call Admin'**
  String get callAdmin;

  /// No description provided for @message.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get message;

  /// No description provided for @followUpHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Patient condition worsening...'**
  String get followUpHint;

  /// No description provided for @caseClosed.
  ///
  /// In en, this message translates to:
  /// **'Case closed.'**
  String get caseClosed;

  /// No description provided for @pleaseAddNotesBeforeCallingClinic.
  ///
  /// In en, this message translates to:
  /// **'Please add some notes before calling the clinic.'**
  String get pleaseAddNotesBeforeCallingClinic;

  /// No description provided for @pendingReview.
  ///
  /// In en, this message translates to:
  /// **'Pending Review'**
  String get pendingReview;

  /// No description provided for @clinicianAdvised.
  ///
  /// In en, this message translates to:
  /// **'Clinician Advised'**
  String get clinicianAdvised;

  /// No description provided for @ambulanceRequested.
  ///
  /// In en, this message translates to:
  /// **'Ambulance Requested'**
  String get ambulanceRequested;

  /// No description provided for @ambulanceDispatched.
  ///
  /// In en, this message translates to:
  /// **'Ambulance Dispatched'**
  String get ambulanceDispatched;

  /// No description provided for @ambulanceEnRoute.
  ///
  /// In en, this message translates to:
  /// **'Ambulance En Route'**
  String get ambulanceEnRoute;

  /// No description provided for @ambulanceArrived.
  ///
  /// In en, this message translates to:
  /// **'Ambulance Arrived'**
  String get ambulanceArrived;

  /// No description provided for @patientInTransit.
  ///
  /// In en, this message translates to:
  /// **'Patient In Transit'**
  String get patientInTransit;

  /// No description provided for @patientDelivered.
  ///
  /// In en, this message translates to:
  /// **'Patient Delivered'**
  String get patientDelivered;

  /// No description provided for @inTreatment.
  ///
  /// In en, this message translates to:
  /// **'In Treatment'**
  String get inTreatment;

  /// No description provided for @admitted.
  ///
  /// In en, this message translates to:
  /// **'Admitted'**
  String get admitted;

  /// No description provided for @discharged.
  ///
  /// In en, this message translates to:
  /// **'Discharged'**
  String get discharged;

  /// No description provided for @caseCompleted.
  ///
  /// In en, this message translates to:
  /// **'Case Completed'**
  String get caseCompleted;

  /// No description provided for @caseCancelled.
  ///
  /// In en, this message translates to:
  /// **'Case Cancelled'**
  String get caseCancelled;

  /// No description provided for @adviceSent.
  ///
  /// In en, this message translates to:
  /// **'Advice Sent'**
  String get adviceSent;

  /// No description provided for @dispatched.
  ///
  /// In en, this message translates to:
  /// **'Dispatched'**
  String get dispatched;

  /// No description provided for @enRoute.
  ///
  /// In en, this message translates to:
  /// **'En Route'**
  String get enRoute;

  /// No description provided for @arrived.
  ///
  /// In en, this message translates to:
  /// **'Arrived'**
  String get arrived;

  /// No description provided for @awaitingStatusUpdate.
  ///
  /// In en, this message translates to:
  /// **'Awaiting status update.'**
  String get awaitingStatusUpdate;

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// No description provided for @minAgo.
  ///
  /// In en, this message translates to:
  /// **'{n} min ago'**
  String minAgo(int n);

  /// No description provided for @hrAgo.
  ///
  /// In en, this message translates to:
  /// **'{n} hr ago'**
  String hrAgo(int n);

  /// No description provided for @patientInformation.
  ///
  /// In en, this message translates to:
  /// **'Patient Information'**
  String get patientInformation;

  /// No description provided for @reportingVht.
  ///
  /// In en, this message translates to:
  /// **'Reporting VHT'**
  String get reportingVht;

  /// No description provided for @ambulanceDriver.
  ///
  /// In en, this message translates to:
  /// **'Ambulance Driver'**
  String get ambulanceDriver;

  /// No description provided for @vhtNotes.
  ///
  /// In en, this message translates to:
  /// **'VHT Notes'**
  String get vhtNotes;

  /// No description provided for @mediaFromVht.
  ///
  /// In en, this message translates to:
  /// **'Media from VHT'**
  String get mediaFromVht;

  /// No description provided for @attachments.
  ///
  /// In en, this message translates to:
  /// **'Attachments'**
  String get attachments;

  /// No description provided for @treatmentNotesDischarge.
  ///
  /// In en, this message translates to:
  /// **'Treatment Notes & Discharge'**
  String get treatmentNotesDischarge;

  /// No description provided for @noMediaAttachedByVht.
  ///
  /// In en, this message translates to:
  /// **'No media attached by VHT'**
  String get noMediaAttachedByVht;

  /// No description provided for @viewAttachment.
  ///
  /// In en, this message translates to:
  /// **'View attachment'**
  String get viewAttachment;

  /// No description provided for @takeAction.
  ///
  /// In en, this message translates to:
  /// **'Take Action'**
  String get takeAction;

  /// No description provided for @addNotesAndDecide.
  ///
  /// In en, this message translates to:
  /// **'Add notes and decide whether to dispatch an ambulance or advise the VHT.'**
  String get addNotesAndDecide;

  /// No description provided for @requestAmbulanceDispatch.
  ///
  /// In en, this message translates to:
  /// **'Request Ambulance Dispatch'**
  String get requestAmbulanceDispatch;

  /// No description provided for @sendAdviceToVht.
  ///
  /// In en, this message translates to:
  /// **'Send Advice to VHT'**
  String get sendAdviceToVht;

  /// No description provided for @closeCasePatientOk.
  ///
  /// In en, this message translates to:
  /// **'Close Case (Patient OK)'**
  String get closeCasePatientOk;

  /// No description provided for @receivePatient.
  ///
  /// In en, this message translates to:
  /// **'Receive Patient'**
  String get receivePatient;

  /// No description provided for @patientInTreatment.
  ///
  /// In en, this message translates to:
  /// **'Patient In Treatment'**
  String get patientInTreatment;

  /// No description provided for @admitPatientInpatientOrDischarge.
  ///
  /// In en, this message translates to:
  /// **'Admit the patient for inpatient care, or add treatment notes and discharge.'**
  String get admitPatientInpatientOrDischarge;

  /// No description provided for @admitPatient.
  ///
  /// In en, this message translates to:
  /// **'Admit Patient'**
  String get admitPatient;

  /// No description provided for @treatAndDischarge.
  ///
  /// In en, this message translates to:
  /// **'Treat & Discharge'**
  String get treatAndDischarge;

  /// No description provided for @patientAdmitted.
  ///
  /// In en, this message translates to:
  /// **'Patient Admitted'**
  String get patientAdmitted;

  /// No description provided for @addTreatmentNotesAndDischarge.
  ///
  /// In en, this message translates to:
  /// **'Add treatment notes and discharge when ready.'**
  String get addTreatmentNotesAndDischarge;

  /// No description provided for @dischargePatient.
  ///
  /// In en, this message translates to:
  /// **'Discharge Patient'**
  String get dischargePatient;

  /// No description provided for @dispatch.
  ///
  /// In en, this message translates to:
  /// **'Dispatch'**
  String get dispatch;

  /// No description provided for @closeCase.
  ///
  /// In en, this message translates to:
  /// **'Close Case'**
  String get closeCase;

  /// No description provided for @discharge.
  ///
  /// In en, this message translates to:
  /// **'Discharge'**
  String get discharge;

  /// No description provided for @ambulanceDispatchRequested.
  ///
  /// In en, this message translates to:
  /// **'Ambulance dispatch requested.'**
  String get ambulanceDispatchRequested;

  /// No description provided for @pleaseAddAdviceForVhtFirst.
  ///
  /// In en, this message translates to:
  /// **'Please add advice for the VHT first.'**
  String get pleaseAddAdviceForVhtFirst;

  /// No description provided for @adviceSentToVhtSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Advice sent to VHT successfully.'**
  String get adviceSentToVhtSuccessfully;

  /// No description provided for @caseClosedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Case closed successfully.'**
  String get caseClosedSuccessfully;

  /// No description provided for @patientReceivedAddTreatmentNotes.
  ///
  /// In en, this message translates to:
  /// **'Patient received. You can now add treatment notes.'**
  String get patientReceivedAddTreatmentNotes;

  /// No description provided for @patientAdmittedAddNotesWhenReady.
  ///
  /// In en, this message translates to:
  /// **'Patient admitted. Add treatment notes when ready to discharge.'**
  String get patientAdmittedAddNotesWhenReady;

  /// No description provided for @pleaseEnterTreatmentNotesBeforeDischarging.
  ///
  /// In en, this message translates to:
  /// **'Please enter treatment notes before discharging'**
  String get pleaseEnterTreatmentNotesBeforeDischarging;

  /// No description provided for @patientDischargedCaseCompleted.
  ///
  /// In en, this message translates to:
  /// **'Patient discharged. Case completed.'**
  String get patientDischargedCaseCompleted;

  /// No description provided for @couldNotOpenVideo.
  ///
  /// In en, this message translates to:
  /// **'Could not open video'**
  String get couldNotOpenVideo;

  /// No description provided for @callVht.
  ///
  /// In en, this message translates to:
  /// **'Call VHT'**
  String get callVht;

  /// No description provided for @callDriver.
  ///
  /// In en, this message translates to:
  /// **'Call Driver'**
  String get callDriver;

  /// No description provided for @addNotesAdviceForVhtHint.
  ///
  /// In en, this message translates to:
  /// **'Add your notes or advice for the VHT...'**
  String get addNotesAdviceForVhtHint;

  /// No description provided for @treatmentNotesHint.
  ///
  /// In en, this message translates to:
  /// **'Enter diagnosis, treatment given, medications...'**
  String get treatmentNotesHint;

  /// No description provided for @activeCases.
  ///
  /// In en, this message translates to:
  /// **'Active Cases'**
  String get activeCases;

  /// No description provided for @clinicNotifiedAboutArrival.
  ///
  /// In en, this message translates to:
  /// **'Clinic notified about arrival.'**
  String get clinicNotifiedAboutArrival;

  /// No description provided for @vhtNotifiedAboutArrival.
  ///
  /// In en, this message translates to:
  /// **'VHT notified about arrival.'**
  String get vhtNotifiedAboutArrival;

  /// No description provided for @failedToUpdateStatus.
  ///
  /// In en, this message translates to:
  /// **'Failed to update status: {error}'**
  String failedToUpdateStatus(String error);

  /// No description provided for @couldNotLaunchDialer.
  ///
  /// In en, this message translates to:
  /// **'Could not launch dialer for {phone}'**
  String couldNotLaunchDialer(String phone);

  /// No description provided for @errorAcceptingDispatch.
  ///
  /// In en, this message translates to:
  /// **'Error accepting dispatch'**
  String get errorAcceptingDispatch;

  /// No description provided for @dispatchAmbulance.
  ///
  /// In en, this message translates to:
  /// **'Dispatch Ambulance'**
  String get dispatchAmbulance;

  /// No description provided for @userDetails.
  ///
  /// In en, this message translates to:
  /// **'User Details'**
  String get userDetails;

  /// No description provided for @cannotRemoveAdminUsers.
  ///
  /// In en, this message translates to:
  /// **'Cannot remove admin users'**
  String get cannotRemoveAdminUsers;

  /// No description provided for @areYouSureRemoveUser.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove this user?'**
  String get areYouSureRemoveUser;

  /// No description provided for @userRemoved.
  ///
  /// In en, this message translates to:
  /// **'User removed'**
  String get userRemoved;

  /// No description provided for @failedToRemoveUser.
  ///
  /// In en, this message translates to:
  /// **'Failed to remove user'**
  String get failedToRemoveUser;

  /// No description provided for @casesByType.
  ///
  /// In en, this message translates to:
  /// **'Cases by Type'**
  String get casesByType;

  /// No description provided for @urgencyDistribution.
  ///
  /// In en, this message translates to:
  /// **'Urgency Distribution'**
  String get urgencyDistribution;

  /// No description provided for @staffCoverage.
  ///
  /// In en, this message translates to:
  /// **'Staff Coverage'**
  String get staffCoverage;

  /// No description provided for @caseLoadByFacility.
  ///
  /// In en, this message translates to:
  /// **'Case Load by Facility'**
  String get caseLoadByFacility;

  /// No description provided for @rankedByTotalCasesAssigned.
  ///
  /// In en, this message translates to:
  /// **'Ranked by total cases assigned'**
  String get rankedByTotalCasesAssigned;

  /// No description provided for @criticalUnresolvedCases.
  ///
  /// In en, this message translates to:
  /// **'Critical Unresolved Cases'**
  String get criticalUnresolvedCases;

  /// No description provided for @exportReports.
  ///
  /// In en, this message translates to:
  /// **'Export Reports'**
  String get exportReports;

  /// No description provided for @errorLoadingFacilityData.
  ///
  /// In en, this message translates to:
  /// **'Error loading facility data'**
  String get errorLoadingFacilityData;

  /// No description provided for @noFacilityDataYet.
  ///
  /// In en, this message translates to:
  /// **'No facility data yet.'**
  String get noFacilityDataYet;

  /// No description provided for @unassigned.
  ///
  /// In en, this message translates to:
  /// **'Unassigned'**
  String get unassigned;

  /// No description provided for @viewAndManageOngoingCases.
  ///
  /// In en, this message translates to:
  /// **'View and manage all ongoing cases.'**
  String get viewAndManageOngoingCases;

  /// No description provided for @addOrRemoveSystemUsers.
  ///
  /// In en, this message translates to:
  /// **'Add or remove system users.'**
  String get addOrRemoveSystemUsers;

  /// No description provided for @manageUsers.
  ///
  /// In en, this message translates to:
  /// **'Manage Users'**
  String get manageUsers;

  /// No description provided for @failedToGenerateReport.
  ///
  /// In en, this message translates to:
  /// **'Failed to generate report'**
  String get failedToGenerateReport;

  /// No description provided for @totalCases.
  ///
  /// In en, this message translates to:
  /// **'Total Cases'**
  String get totalCases;

  /// No description provided for @activeCasesCount.
  ///
  /// In en, this message translates to:
  /// **'Active Cases'**
  String get activeCasesCount;

  /// No description provided for @completedCases.
  ///
  /// In en, this message translates to:
  /// **'Completed Cases'**
  String get completedCases;

  /// No description provided for @ambulanceDispatchedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Ambulance dispatched successfully.'**
  String get ambulanceDispatchedSuccessfully;

  /// No description provided for @pleaseSignInToViewNotifications.
  ///
  /// In en, this message translates to:
  /// **'Please sign in to view notifications'**
  String get pleaseSignInToViewNotifications;

  /// No description provided for @markAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark All Read'**
  String get markAllRead;

  /// No description provided for @failedToMarkAsRead.
  ///
  /// In en, this message translates to:
  /// **'Failed to mark as read'**
  String get failedToMarkAsRead;

  /// No description provided for @allNotificationsMarkedAsRead.
  ///
  /// In en, this message translates to:
  /// **'All notifications marked as read'**
  String get allNotificationsMarkedAsRead;

  /// No description provided for @failedToMarkAllAsRead.
  ///
  /// In en, this message translates to:
  /// **'Failed to mark all as read'**
  String get failedToMarkAllAsRead;

  /// No description provided for @navigateWithGoogleMaps.
  ///
  /// In en, this message translates to:
  /// **'Navigate with Google Maps'**
  String get navigateWithGoogleMaps;

  /// No description provided for @couldNotOpenGoogleMaps.
  ///
  /// In en, this message translates to:
  /// **'Could not open Google Maps'**
  String get couldNotOpenGoogleMaps;

  /// No description provided for @ugandaClinicalGuidelines2023.
  ///
  /// In en, this message translates to:
  /// **'Uganda Clinical Guidelines 2023'**
  String get ugandaClinicalGuidelines2023;

  /// No description provided for @viewCaseHistory.
  ///
  /// In en, this message translates to:
  /// **'View Case History'**
  String get viewCaseHistory;

  /// No description provided for @learningResources.
  ///
  /// In en, this message translates to:
  /// **'Learning Resources'**
  String get learningResources;

  /// No description provided for @pickImage.
  ///
  /// In en, this message translates to:
  /// **'Pick Image'**
  String get pickImage;

  /// No description provided for @pickVideo.
  ///
  /// In en, this message translates to:
  /// **'Pick Video'**
  String get pickVideo;

  /// No description provided for @pickFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Pick from gallery'**
  String get pickFromGallery;

  /// No description provided for @switchCamera.
  ///
  /// In en, this message translates to:
  /// **'Switch camera'**
  String get switchCamera;

  /// No description provided for @imageSizeExceedsMax.
  ///
  /// In en, this message translates to:
  /// **'Image size ({size} KB) exceeds maximum ({max} KB)'**
  String imageSizeExceedsMax(String size, String max);

  /// No description provided for @videoSizeExceedsMax.
  ///
  /// In en, this message translates to:
  /// **'Video size ({size} MB) exceeds maximum ({max} MB)'**
  String videoSizeExceedsMax(String size, String max);

  /// No description provided for @microphonePermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Microphone permission is required to record voice notes'**
  String get microphonePermissionRequired;

  /// No description provided for @errorStartingRecording.
  ///
  /// In en, this message translates to:
  /// **'Error starting recording'**
  String get errorStartingRecording;

  /// No description provided for @errorStoppingRecording.
  ///
  /// In en, this message translates to:
  /// **'Error stopping recording'**
  String get errorStoppingRecording;

  /// No description provided for @errorPlayingAudio.
  ///
  /// In en, this message translates to:
  /// **'Error playing audio'**
  String get errorPlayingAudio;

  /// No description provided for @couldNotPlayVoiceNote.
  ///
  /// In en, this message translates to:
  /// **'Could not play voice note'**
  String get couldNotPlayVoiceNote;

  /// No description provided for @locationServicesDisabled.
  ///
  /// In en, this message translates to:
  /// **'Location services are disabled. Please enable GPS in your device settings.'**
  String get locationServicesDisabled;

  /// No description provided for @locationPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permission was denied. Please grant location access to report emergencies.'**
  String get locationPermissionDenied;

  /// No description provided for @locationPermissionPermanentlyDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permission is permanently denied. Please open Settings and enable location for this app.'**
  String get locationPermissionPermanentlyDenied;

  /// No description provided for @couldNotGetLocation.
  ///
  /// In en, this message translates to:
  /// **'Could not get location'**
  String get couldNotGetLocation;

  /// No description provided for @notificationNewEmergencyCase.
  ///
  /// In en, this message translates to:
  /// **'New Emergency Case'**
  String get notificationNewEmergencyCase;

  /// No description provided for @notificationNewEmergencyCaseMessage.
  ///
  /// In en, this message translates to:
  /// **'New {emergencyType} case from VHT {vhtName}. Patient: {patientName}. Urgency: {urgency}. Please review immediately.'**
  String notificationNewEmergencyCaseMessage(
    String emergencyType,
    String vhtName,
    String patientName,
    String urgency,
  );

  /// No description provided for @notificationCaseSubmittedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Case Submitted Successfully'**
  String get notificationCaseSubmittedSuccessfully;

  /// No description provided for @notificationCaseSubmittedMessage.
  ///
  /// In en, this message translates to:
  /// **'Your {emergencyType} case for {patientName} has been sent to {clinicName} for review.'**
  String notificationCaseSubmittedMessage(
    String emergencyType,
    String patientName,
    String clinicName,
  );

  /// No description provided for @notificationVhtFollowUpUpdate.
  ///
  /// In en, this message translates to:
  /// **'VHT Follow-up Update'**
  String get notificationVhtFollowUpUpdate;

  /// No description provided for @notificationVhtFollowUpMessage.
  ///
  /// In en, this message translates to:
  /// **'{vhtName} updated on {patientName}: \"{message}\"'**
  String notificationVhtFollowUpMessage(
    String vhtName,
    String patientName,
    String message,
  );

  /// No description provided for @notificationClinicianAdviceReceived.
  ///
  /// In en, this message translates to:
  /// **'Clinician Advice Received'**
  String get notificationClinicianAdviceReceived;

  /// No description provided for @notificationClinicianAdviceMessage.
  ///
  /// In en, this message translates to:
  /// **'Dr. {clinicianName} responded about {patientName}: \"{advice}\"'**
  String notificationClinicianAdviceMessage(
    String clinicianName,
    String patientName,
    String advice,
  );

  /// No description provided for @notificationAmbulanceDispatchRequired.
  ///
  /// In en, this message translates to:
  /// **'Ambulance Dispatch Required'**
  String get notificationAmbulanceDispatchRequired;

  /// No description provided for @notificationAmbulanceOnTheWay.
  ///
  /// In en, this message translates to:
  /// **'Ambulance On The Way'**
  String get notificationAmbulanceOnTheWay;

  /// No description provided for @notificationAmbulanceOnTheWayMessage.
  ///
  /// In en, this message translates to:
  /// **'An ambulance driven by {driverName} has been dispatched. Stay with {patientName}.'**
  String notificationAmbulanceOnTheWayMessage(
    String driverName,
    String patientName,
  );

  /// No description provided for @notificationAmbulanceDispatched.
  ///
  /// In en, this message translates to:
  /// **'Ambulance Dispatched'**
  String get notificationAmbulanceDispatched;

  /// No description provided for @notificationAmbulanceDispatchedMessage.
  ///
  /// In en, this message translates to:
  /// **'Ambulance driver {driverName} has been dispatched for the {emergencyType} case (Patient: {patientName}).'**
  String notificationAmbulanceDispatchedMessage(
    String driverName,
    String emergencyType,
    String patientName,
  );

  /// No description provided for @notificationNewDispatchAssignment.
  ///
  /// In en, this message translates to:
  /// **'New Dispatch Assignment'**
  String get notificationNewDispatchAssignment;

  /// No description provided for @notificationNewDispatchMessage.
  ///
  /// In en, this message translates to:
  /// **'You have been assigned to a {emergencyType} case. Collect patient from VHT {vhtName}, deliver to {clinicName}. Patient: {patientName}.'**
  String notificationNewDispatchMessage(
    String emergencyType,
    String vhtName,
    String clinicName,
    String patientName,
  );

  /// No description provided for @notificationPatientDelivered.
  ///
  /// In en, this message translates to:
  /// **'Patient Delivered'**
  String get notificationPatientDelivered;

  /// No description provided for @notificationPatientDeliveredMessage.
  ///
  /// In en, this message translates to:
  /// **'Your patient {patientName} ({emergencyType}) has been safely delivered to {clinicName} by {driverName}.'**
  String notificationPatientDeliveredMessage(
    String patientName,
    String emergencyType,
    String clinicName,
    String driverName,
  );

  /// No description provided for @notificationPatientArriving.
  ///
  /// In en, this message translates to:
  /// **'Patient Arriving'**
  String get notificationPatientArriving;

  /// No description provided for @notificationPatientArrivingMessage.
  ///
  /// In en, this message translates to:
  /// **'Patient {patientName} ({emergencyType}) delivered by {driverName}. Please receive the patient.'**
  String notificationPatientArrivingMessage(
    String patientName,
    String emergencyType,
    String driverName,
  );

  /// No description provided for @notificationPatientDischarged.
  ///
  /// In en, this message translates to:
  /// **'Patient Discharged'**
  String get notificationPatientDischarged;

  /// No description provided for @notificationPatientDischargedMessage.
  ///
  /// In en, this message translates to:
  /// **'Your patient {patientName} ({emergencyType}) has been treated and discharged from {clinicName}. Case complete.'**
  String notificationPatientDischargedMessage(
    String patientName,
    String emergencyType,
    String clinicName,
  );

  /// No description provided for @notificationCaseCompleted.
  ///
  /// In en, this message translates to:
  /// **'Case Completed'**
  String get notificationCaseCompleted;

  /// No description provided for @notificationCaseCompletedMessage.
  ///
  /// In en, this message translates to:
  /// **'{patientName} ({emergencyType}) has been discharged from {clinicName} by Dr. {clinicianName}. Case closed.'**
  String notificationCaseCompletedMessage(
    String patientName,
    String emergencyType,
    String clinicName,
    String clinicianName,
  );

  /// No description provided for @notificationCaseClosed.
  ///
  /// In en, this message translates to:
  /// **'Case Closed'**
  String get notificationCaseClosed;

  /// No description provided for @notificationCaseClosedMessage.
  ///
  /// In en, this message translates to:
  /// **'Dr. {clinicianName} has confirmed {patientName} ({emergencyType}) is OK and closed the case.'**
  String notificationCaseClosedMessage(
    String clinicianName,
    String patientName,
    String emergencyType,
  );

  /// No description provided for @notificationEmergencyAlerts.
  ///
  /// In en, this message translates to:
  /// **'Emergency Alerts'**
  String get notificationEmergencyAlerts;

  /// No description provided for @notificationEmergencyAlertsDescription.
  ///
  /// In en, this message translates to:
  /// **'Notifications for emergency cases and status updates'**
  String get notificationEmergencyAlertsDescription;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String errorGeneric(String error);

  /// No description provided for @reportedBy.
  ///
  /// In en, this message translates to:
  /// **'Reported by: {name}'**
  String reportedBy(String name);

  /// No description provided for @reportedAt.
  ///
  /// In en, this message translates to:
  /// **'Reported: {time}'**
  String reportedAt(String time);

  /// No description provided for @splashAppName.
  ///
  /// In en, this message translates to:
  /// **'HealthAlert'**
  String get splashAppName;

  /// No description provided for @splashTagline.
  ///
  /// In en, this message translates to:
  /// **'Emergency communication for front line health response'**
  String get splashTagline;

  /// No description provided for @noNotificationsYet.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get noNotificationsYet;

  /// No description provided for @notificationsWillAppearHere.
  ///
  /// In en, this message translates to:
  /// **'Notifications will appear here'**
  String get notificationsWillAppearHere;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @enterVerificationCode.
  ///
  /// In en, this message translates to:
  /// **'Enter Verification Code'**
  String get enterVerificationCode;

  /// No description provided for @weSentCodeTo.
  ///
  /// In en, this message translates to:
  /// **'We sent a code to {phone}'**
  String weSentCodeTo(String phone);

  /// No description provided for @forTestNumbersEnter.
  ///
  /// In en, this message translates to:
  /// **'For test numbers, enter: 123456'**
  String get forTestNumbersEnter;

  /// No description provided for @verifyButton.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verifyButton;

  /// No description provided for @enterYourPinToContinue.
  ///
  /// In en, this message translates to:
  /// **'Enter your PIN to continue'**
  String get enterYourPinToContinue;

  /// No description provided for @verifyPinButton.
  ///
  /// In en, this message translates to:
  /// **'Verify PIN'**
  String get verifyPinButton;

  /// No description provided for @setYourPin.
  ///
  /// In en, this message translates to:
  /// **'Set Your PIN'**
  String get setYourPin;

  /// No description provided for @enterPinBetween4And6.
  ///
  /// In en, this message translates to:
  /// **'Enter a PIN between 4 to 6 digits'**
  String get enterPinBetween4And6;

  /// No description provided for @enterButton.
  ///
  /// In en, this message translates to:
  /// **'Enter'**
  String get enterButton;

  /// No description provided for @pleaseEnterAPin.
  ///
  /// In en, this message translates to:
  /// **'Please enter a PIN'**
  String get pleaseEnterAPin;

  /// No description provided for @pleaseConfirmYourPin.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your PIN'**
  String get pleaseConfirmYourPin;

  /// No description provided for @pinsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'PINs do not match. Please try again.'**
  String get pinsDoNotMatch;

  /// No description provided for @confirmYourPin.
  ///
  /// In en, this message translates to:
  /// **'Confirm Your PIN'**
  String get confirmYourPin;

  /// No description provided for @pleaseReenterPinToConfirm.
  ///
  /// In en, this message translates to:
  /// **'Please re-enter your PIN to confirm'**
  String get pleaseReenterPinToConfirm;

  /// No description provided for @homeLabel.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeLabel;

  /// No description provided for @learnLabel.
  ///
  /// In en, this message translates to:
  /// **'Learn'**
  String get learnLabel;

  /// No description provided for @mapLabel.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get mapLabel;

  /// No description provided for @incomingLabel.
  ///
  /// In en, this message translates to:
  /// **'Incoming'**
  String get incomingLabel;

  /// No description provided for @welcomeName.
  ///
  /// In en, this message translates to:
  /// **'Welcome, {name}'**
  String welcomeName(String name);

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @ugandaClinicalGuidelinesDescription.
  ///
  /// In en, this message translates to:
  /// **'National clinical guidelines for health workers in Uganda'**
  String get ugandaClinicalGuidelinesDescription;

  /// No description provided for @patientIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Patient ID'**
  String get patientIdLabel;

  /// No description provided for @dateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get dateOfBirth;

  /// No description provided for @selectDateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Select Date of Birth'**
  String get selectDateOfBirth;

  /// No description provided for @ageYears.
  ///
  /// In en, this message translates to:
  /// **'{n} years'**
  String ageYears(int n);

  /// No description provided for @notesLabel.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notesLabel;

  /// No description provided for @patientDetailsHelp.
  ///
  /// In en, this message translates to:
  /// **'These details will help clinic and ambulance staff prepare.'**
  String get patientDetailsHelp;

  /// No description provided for @photoVideoOptional.
  ///
  /// In en, this message translates to:
  /// **'Photo / Video (optional)'**
  String get photoVideoOptional;

  /// No description provided for @noStaffAtFacility.
  ///
  /// In en, this message translates to:
  /// **'No available staff at {facility}. Please select another facility or contact your supervisor.'**
  String noStaffAtFacility(String facility);

  /// No description provided for @locationNeedsAccessMessage.
  ///
  /// In en, this message translates to:
  /// **'HealthAlert needs location access to report emergencies and help ambulances find patients.\n\nPlease open Settings and enable location for this app.'**
  String get locationNeedsAccessMessage;

  /// No description provided for @pendingOffline.
  ///
  /// In en, this message translates to:
  /// **'Pending (offline)'**
  String get pendingOffline;

  /// No description provided for @selectHealthFacility.
  ///
  /// In en, this message translates to:
  /// **'Select Health Facility'**
  String get selectHealthFacility;

  /// No description provided for @chooseClinicForPatient.
  ///
  /// In en, this message translates to:
  /// **'Choose the clinic best suited for this patient.'**
  String get chooseClinicForPatient;

  /// No description provided for @notifyClinic.
  ///
  /// In en, this message translates to:
  /// **'Notify Clinic'**
  String get notifyClinic;

  /// No description provided for @triageLevel.
  ///
  /// In en, this message translates to:
  /// **'Triage level'**
  String get triageLevel;

  /// No description provided for @caseSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Case Submitted'**
  String get caseSubmitted;

  /// No description provided for @clinicNotifiedOfEmergency.
  ///
  /// In en, this message translates to:
  /// **'The clinic has been notified of the emergency.'**
  String get clinicNotifiedOfEmergency;

  /// No description provided for @currentStatus.
  ///
  /// In en, this message translates to:
  /// **'Current Status'**
  String get currentStatus;

  /// No description provided for @returnToDashboard.
  ///
  /// In en, this message translates to:
  /// **'Return to Dashboard'**
  String get returnToDashboard;

  /// No description provided for @reportAnotherEmergency.
  ///
  /// In en, this message translates to:
  /// **'Report Another Emergency'**
  String get reportAnotherEmergency;

  /// No description provided for @caseTracking.
  ///
  /// In en, this message translates to:
  /// **'Case Tracking'**
  String get caseTracking;

  /// No description provided for @assignedClinician.
  ///
  /// In en, this message translates to:
  /// **'Assigned clinician'**
  String get assignedClinician;

  /// No description provided for @savedOffline.
  ///
  /// In en, this message translates to:
  /// **'Saved Offline'**
  String get savedOffline;

  /// No description provided for @caseSavedOfflineMessage.
  ///
  /// In en, this message translates to:
  /// **'Case data has been saved locally and will be sent to the clinic when you are back online.'**
  String get caseSavedOfflineMessage;

  /// No description provided for @lastUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last updated'**
  String get lastUpdated;

  /// No description provided for @caseDetails.
  ///
  /// In en, this message translates to:
  /// **'Case Details'**
  String get caseDetails;

  /// No description provided for @adviceProgress.
  ///
  /// In en, this message translates to:
  /// **'Advice Progress'**
  String get adviceProgress;

  /// No description provided for @caseProgress.
  ///
  /// In en, this message translates to:
  /// **'Case Progress'**
  String get caseProgress;

  /// No description provided for @sending.
  ///
  /// In en, this message translates to:
  /// **'Sending...'**
  String get sending;

  /// No description provided for @caseHistory.
  ///
  /// In en, this message translates to:
  /// **'Case History'**
  String get caseHistory;

  /// No description provided for @allCases.
  ///
  /// In en, this message translates to:
  /// **'All Cases'**
  String get allCases;

  /// No description provided for @allTypes.
  ///
  /// In en, this message translates to:
  /// **'All Types'**
  String get allTypes;

  /// No description provided for @activeFilter.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get activeFilter;

  /// No description provided for @allFilter.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allFilter;

  /// No description provided for @completedFilter.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completedFilter;

  /// No description provided for @errorLoadingCases.
  ///
  /// In en, this message translates to:
  /// **'Error loading cases'**
  String get errorLoadingCases;

  /// No description provided for @noActiveCases.
  ///
  /// In en, this message translates to:
  /// **'No active cases'**
  String get noActiveCases;

  /// No description provided for @noCompletedCases.
  ///
  /// In en, this message translates to:
  /// **'No completed cases'**
  String get noCompletedCases;

  /// No description provided for @noCasesFound.
  ///
  /// In en, this message translates to:
  /// **'No cases found'**
  String get noCasesFound;

  /// No description provided for @casesReportedAppearHere.
  ///
  /// In en, this message translates to:
  /// **'Cases you report will appear here.'**
  String get casesReportedAppearHere;

  /// No description provided for @casesAssignedToYouAppearHere.
  ///
  /// In en, this message translates to:
  /// **'Cases assigned to you will appear here.'**
  String get casesAssignedToYouAppearHere;

  /// No description provided for @clinicLabel.
  ///
  /// In en, this message translates to:
  /// **'Clinic'**
  String get clinicLabel;

  /// No description provided for @unknownClinic.
  ///
  /// In en, this message translates to:
  /// **'Unknown Clinic'**
  String get unknownClinic;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @clinicianLabel.
  ///
  /// In en, this message translates to:
  /// **'Clinician'**
  String get clinicianLabel;

  /// No description provided for @contactSection.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get contactSection;

  /// No description provided for @statusMsgPending.
  ///
  /// In en, this message translates to:
  /// **'The clinician is reviewing your case.'**
  String get statusMsgPending;

  /// No description provided for @statusMsgPendingSubmitted.
  ///
  /// In en, this message translates to:
  /// **'The clinician is reviewing your case. You will be updated when a decision is made.'**
  String get statusMsgPendingSubmitted;

  /// No description provided for @statusMsgAdvised.
  ///
  /// In en, this message translates to:
  /// **'The clinician has sent you advice. See below.'**
  String get statusMsgAdvised;

  /// No description provided for @statusMsgAmbRequested.
  ///
  /// In en, this message translates to:
  /// **'Clinician has requested an ambulance for this patient.'**
  String get statusMsgAmbRequested;

  /// No description provided for @statusMsgDispatched.
  ///
  /// In en, this message translates to:
  /// **'An ambulance has been dispatched to your location.'**
  String get statusMsgDispatched;

  /// No description provided for @statusMsgDispatchedStay.
  ///
  /// In en, this message translates to:
  /// **'An ambulance has been dispatched to your location. Stay with the patient.'**
  String get statusMsgDispatchedStay;

  /// No description provided for @statusMsgEnRoute.
  ///
  /// In en, this message translates to:
  /// **'The ambulance is on its way.'**
  String get statusMsgEnRoute;

  /// No description provided for @statusMsgEnRoutePrepare.
  ///
  /// In en, this message translates to:
  /// **'The ambulance is on its way. Prepare the patient for transport.'**
  String get statusMsgEnRoutePrepare;

  /// No description provided for @statusMsgArrived.
  ///
  /// In en, this message translates to:
  /// **'The ambulance has arrived.'**
  String get statusMsgArrived;

  /// No description provided for @statusMsgArrivedHandOver.
  ///
  /// In en, this message translates to:
  /// **'The ambulance has arrived. Hand over the patient to the ambulance crew.'**
  String get statusMsgArrivedHandOver;

  /// No description provided for @statusMsgInTransit.
  ///
  /// In en, this message translates to:
  /// **'The patient is being transported to the clinic.'**
  String get statusMsgInTransit;

  /// No description provided for @statusMsgDelivered.
  ///
  /// In en, this message translates to:
  /// **'The patient has been delivered to the clinic.'**
  String get statusMsgDelivered;

  /// No description provided for @statusMsgInTreatment.
  ///
  /// In en, this message translates to:
  /// **'Your patient is currently being treated at the clinic.'**
  String get statusMsgInTreatment;

  /// No description provided for @statusMsgAdmitted.
  ///
  /// In en, this message translates to:
  /// **'Patient has been admitted to the clinic'**
  String get statusMsgAdmitted;

  /// No description provided for @statusMsgDischarged.
  ///
  /// In en, this message translates to:
  /// **'Patient has been discharged'**
  String get statusMsgDischarged;

  /// No description provided for @statusMsgCompleted.
  ///
  /// In en, this message translates to:
  /// **'This case has been completed.'**
  String get statusMsgCompleted;

  /// No description provided for @statusMsgCompletedTreated.
  ///
  /// In en, this message translates to:
  /// **'This case has been completed. The patient has been treated.'**
  String get statusMsgCompletedTreated;

  /// No description provided for @statusMsgCancelled.
  ///
  /// In en, this message translates to:
  /// **'This case has been cancelled.'**
  String get statusMsgCancelled;

  /// No description provided for @viewAllIncomingCases.
  ///
  /// In en, this message translates to:
  /// **'View All Incoming Cases'**
  String get viewAllIncomingCases;

  /// No description provided for @needsYourReview.
  ///
  /// In en, this message translates to:
  /// **'Needs Your Review'**
  String get needsYourReview;

  /// No description provided for @allCaughtUp.
  ///
  /// In en, this message translates to:
  /// **'All caught up!'**
  String get allCaughtUp;

  /// No description provided for @noCasesPendingReview.
  ///
  /// In en, this message translates to:
  /// **'No cases pending your review right now.'**
  String get noCasesPendingReview;

  /// No description provided for @ambulanceEmergencyDispatch.
  ///
  /// In en, this message translates to:
  /// **'Ambulance — Emergency Dispatch'**
  String get ambulanceEmergencyDispatch;

  /// No description provided for @viewIncomingEmergencyRequests.
  ///
  /// In en, this message translates to:
  /// **'View incoming emergency requests from VHTs and clinics.'**
  String get viewIncomingEmergencyRequests;

  /// No description provided for @viewDispatch.
  ///
  /// In en, this message translates to:
  /// **'View Dispatch'**
  String get viewDispatch;

  /// No description provided for @viewActiveCases.
  ///
  /// In en, this message translates to:
  /// **'View Active Cases'**
  String get viewActiveCases;

  /// No description provided for @recentCases.
  ///
  /// In en, this message translates to:
  /// **'Recent Cases'**
  String get recentCases;

  /// No description provided for @noRecentCases.
  ///
  /// In en, this message translates to:
  /// **'No recent cases'**
  String get noRecentCases;

  /// No description provided for @chooseWhatToManageToday.
  ///
  /// In en, this message translates to:
  /// **'Choose what you want to manage today.'**
  String get chooseWhatToManageToday;

  /// No description provided for @dispatchNeeded.
  ///
  /// In en, this message translates to:
  /// **'Dispatch Needed'**
  String get dispatchNeeded;

  /// No description provided for @dispatchLabel.
  ///
  /// In en, this message translates to:
  /// **'Dispatch'**
  String get dispatchLabel;

  /// No description provided for @analyticsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'View ambulance dispatch and VHT report insights.'**
  String get analyticsSubtitle;

  /// No description provided for @manageUsersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add or remove system users.'**
  String get manageUsersSubtitle;

  /// No description provided for @caseSavedOfflineSyncWhenOnline.
  ///
  /// In en, this message translates to:
  /// **'Emergency case saved offline. Will sync when online.'**
  String get caseSavedOfflineSyncWhenOnline;

  /// No description provided for @emergencyCaseCreatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Emergency case created successfully!'**
  String get emergencyCaseCreatedSuccessfully;

  /// No description provided for @dispatchConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Dispatch Confirmation'**
  String get dispatchConfirmation;

  /// No description provided for @clinicAssigned.
  ///
  /// In en, this message translates to:
  /// **'Clinic assigned'**
  String get clinicAssigned;

  /// No description provided for @estimatedArrival.
  ///
  /// In en, this message translates to:
  /// **'Estimated arrival'**
  String get estimatedArrival;

  /// No description provided for @assigningNearestAmbulance.
  ///
  /// In en, this message translates to:
  /// **'Automatically assigning nearest ambulance…'**
  String get assigningNearestAmbulance;

  /// No description provided for @systemWillChooseClosestAmbulance.
  ///
  /// In en, this message translates to:
  /// **'The system will choose the closest available ambulance and update this screen in real time.'**
  String get systemWillChooseClosestAmbulance;

  /// No description provided for @emergencyTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Emergency type'**
  String get emergencyTypeLabel;

  /// VHT dispatch confirmation button
  ///
  /// In en, this message translates to:
  /// **'Confirm & Dispatch'**
  String get confirmAndDispatch;

  /// No description provided for @setLocation.
  ///
  /// In en, this message translates to:
  /// **'Set Location'**
  String get setLocation;

  /// No description provided for @automaticallyCapturingLocation.
  ///
  /// In en, this message translates to:
  /// **'Automatically capturing location…'**
  String get automaticallyCapturingLocation;

  /// No description provided for @locationCaptureHelp.
  ///
  /// In en, this message translates to:
  /// **'This will help responders find you faster.\nNo need to move the map or pin your position.'**
  String get locationCaptureHelp;

  /// No description provided for @clinicAssignedWithName.
  ///
  /// In en, this message translates to:
  /// **'Clinic assigned: {name}'**
  String clinicAssignedWithName(String name);

  /// No description provided for @estimatedArrivalValue.
  ///
  /// In en, this message translates to:
  /// **'Estimated arrival: {eta}'**
  String estimatedArrivalValue(String eta);

  /// No description provided for @locationCoordinates.
  ///
  /// In en, this message translates to:
  /// **'Location: {lat}, {lng}'**
  String locationCoordinates(String lat, String lng);

  /// No description provided for @trackAmbulance.
  ///
  /// In en, this message translates to:
  /// **'Track Ambulance'**
  String get trackAmbulance;

  /// No description provided for @mapPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Map Placeholder'**
  String get mapPlaceholder;

  /// No description provided for @notifyClinicPatientOnboard.
  ///
  /// In en, this message translates to:
  /// **'Notify clinic patient is onboard'**
  String get notifyClinicPatientOnboard;

  /// No description provided for @clinicNotifiedPatientOnboard.
  ///
  /// In en, this message translates to:
  /// **'Clinic notified that patient is onboard.'**
  String get clinicNotifiedPatientOnboard;

  /// No description provided for @caseClosedButton.
  ///
  /// In en, this message translates to:
  /// **'Case Closed'**
  String get caseClosedButton;

  /// No description provided for @onboardPatient.
  ///
  /// In en, this message translates to:
  /// **'Onboard Patient'**
  String get onboardPatient;

  /// No description provided for @callingClinicToDiscuss.
  ///
  /// In en, this message translates to:
  /// **'Calling clinic to discuss whether an ambulance is needed...'**
  String get callingClinicToDiscuss;

  /// No description provided for @callClinicToDiscussCase.
  ///
  /// In en, this message translates to:
  /// **'Call clinic to discuss case'**
  String get callClinicToDiscussCase;

  /// No description provided for @continueToDispatchAmbulance.
  ///
  /// In en, this message translates to:
  /// **'Continue to dispatch ambulance'**
  String get continueToDispatchAmbulance;

  /// No description provided for @errorCreatingEmergencyCaseWithError.
  ///
  /// In en, this message translates to:
  /// **'Error creating emergency case: {error}'**
  String errorCreatingEmergencyCaseWithError(String error);

  /// No description provided for @incomingCases.
  ///
  /// In en, this message translates to:
  /// **'Incoming Cases'**
  String get incomingCases;

  /// No description provided for @reviewEmergenciesSubmittedByVhts.
  ///
  /// In en, this message translates to:
  /// **'Review emergencies submitted by VHTs.'**
  String get reviewEmergenciesSubmittedByVhts;

  /// No description provided for @emergencyCasesAssignedToYourClinic.
  ///
  /// In en, this message translates to:
  /// **'Emergency cases assigned to your clinic will appear here.'**
  String get emergencyCasesAssignedToYourClinic;

  /// No description provided for @patientLabel.
  ///
  /// In en, this message translates to:
  /// **'Patient'**
  String get patientLabel;

  /// No description provided for @requestAmbulanceDispatchConfirm.
  ///
  /// In en, this message translates to:
  /// **'This will forward the case to dispatch to assign an ambulance. Do you want to proceed?'**
  String get requestAmbulanceDispatchConfirm;

  /// No description provided for @patientReceived.
  ///
  /// In en, this message translates to:
  /// **'Patient Received'**
  String get patientReceived;

  /// No description provided for @proceed.
  ///
  /// In en, this message translates to:
  /// **'Proceed'**
  String get proceed;

  /// No description provided for @caseSummary.
  ///
  /// In en, this message translates to:
  /// **'Case Summary'**
  String get caseSummary;

  /// No description provided for @patientArrival.
  ///
  /// In en, this message translates to:
  /// **'Patient Arrival'**
  String get patientArrival;

  /// No description provided for @assignStaff.
  ///
  /// In en, this message translates to:
  /// **'Assign Staff'**
  String get assignStaff;

  /// No description provided for @ambulanceTracking.
  ///
  /// In en, this message translates to:
  /// **'Ambulance Tracking'**
  String get ambulanceTracking;

  /// No description provided for @activeCasesTitle.
  ///
  /// In en, this message translates to:
  /// **'Active Cases'**
  String get activeCasesTitle;

  /// No description provided for @allIncomingRequests.
  ///
  /// In en, this message translates to:
  /// **'All Incoming Requests'**
  String get allIncomingRequests;

  /// No description provided for @incomingDispatch.
  ///
  /// In en, this message translates to:
  /// **'Incoming Dispatch'**
  String get incomingDispatch;

  /// No description provided for @arrival.
  ///
  /// In en, this message translates to:
  /// **'Arrival'**
  String get arrival;

  /// No description provided for @caseClosure.
  ///
  /// In en, this message translates to:
  /// **'Case Closure'**
  String get caseClosure;

  /// No description provided for @adminHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get adminHome;

  /// No description provided for @adminCases.
  ///
  /// In en, this message translates to:
  /// **'Cases'**
  String get adminCases;

  /// No description provided for @adminAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get adminAnalytics;

  /// No description provided for @adminUsers.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get adminUsers;

  /// No description provided for @caseDashboard.
  ///
  /// In en, this message translates to:
  /// **'Case Dashboard'**
  String get caseDashboard;

  /// No description provided for @caseAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Case Analytics'**
  String get caseAnalytics;

  /// No description provided for @manageUsersScreen.
  ///
  /// In en, this message translates to:
  /// **'Manage Users'**
  String get manageUsersScreen;

  /// No description provided for @userDetail.
  ///
  /// In en, this message translates to:
  /// **'User Detail'**
  String get userDetail;

  /// No description provided for @caseTimeline.
  ///
  /// In en, this message translates to:
  /// **'Case Timeline'**
  String get caseTimeline;

  /// No description provided for @allCasesList.
  ///
  /// In en, this message translates to:
  /// **'All Cases'**
  String get allCasesList;

  /// No description provided for @reportsExport.
  ///
  /// In en, this message translates to:
  /// **'Export Reports'**
  String get reportsExport;

  /// No description provided for @vhtDetailsForm.
  ///
  /// In en, this message translates to:
  /// **'VHT Details'**
  String get vhtDetailsForm;

  /// No description provided for @clinicianRegistrationForm.
  ///
  /// In en, this message translates to:
  /// **'Clinician Registration'**
  String get clinicianRegistrationForm;

  /// No description provided for @adminDetailsForm.
  ///
  /// In en, this message translates to:
  /// **'Admin Details'**
  String get adminDetailsForm;

  /// No description provided for @ambulanceDriverDetailsForm.
  ///
  /// In en, this message translates to:
  /// **'Ambulance Driver Details'**
  String get ambulanceDriverDetailsForm;

  /// No description provided for @adminEmailOtpScreen.
  ///
  /// In en, this message translates to:
  /// **'Admin Email Verification'**
  String get adminEmailOtpScreen;

  /// No description provided for @registrationForm.
  ///
  /// In en, this message translates to:
  /// **'Registration'**
  String get registrationForm;

  /// No description provided for @fullScreenCamera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get fullScreenCamera;

  /// No description provided for @voiceNoteWidget.
  ///
  /// In en, this message translates to:
  /// **'Voice note'**
  String get voiceNoteWidget;

  /// No description provided for @locationRequestTimeout.
  ///
  /// In en, this message translates to:
  /// **'Location request timed out'**
  String get locationRequestTimeout;

  /// No description provided for @couldNotGetLocationWithError.
  ///
  /// In en, this message translates to:
  /// **'Could not get location: {error}'**
  String couldNotGetLocationWithError(String error);

  /// No description provided for @reviewMediaTriageNextActions.
  ///
  /// In en, this message translates to:
  /// **'Review media, triage level, and next actions for this emergency.'**
  String get reviewMediaTriageNextActions;

  /// No description provided for @photoVoiceNotePreview.
  ///
  /// In en, this message translates to:
  /// **'Photo / Voice Note Preview'**
  String get photoVoiceNotePreview;

  /// No description provided for @triageLevelHighRed.
  ///
  /// In en, this message translates to:
  /// **'Triage Level: High (Red)'**
  String get triageLevelHighRed;

  /// No description provided for @seeStaff.
  ///
  /// In en, this message translates to:
  /// **'See Staff'**
  String get seeStaff;

  /// No description provided for @requestAdditionalInfo.
  ///
  /// In en, this message translates to:
  /// **'Request Additional Info'**
  String get requestAdditionalInfo;

  /// No description provided for @callingVhtPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Calling VHT (placeholder)...'**
  String get callingVhtPlaceholder;

  /// No description provided for @callingAmbulancePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Calling ambulance (placeholder)...'**
  String get callingAmbulancePlaceholder;

  /// No description provided for @confirmStaffAssignmentCloseCase.
  ///
  /// In en, this message translates to:
  /// **'Confirm staff assignment and close the case once the patient is received.'**
  String get confirmStaffAssignmentCloseCase;

  /// No description provided for @emergencyLabel.
  ///
  /// In en, this message translates to:
  /// **'Emergency'**
  String get emergencyLabel;

  /// No description provided for @staffAssigned.
  ///
  /// In en, this message translates to:
  /// **'Staff assigned'**
  String get staffAssigned;

  /// No description provided for @patientReceivedCloseCase.
  ///
  /// In en, this message translates to:
  /// **'Patient Received / Close Case'**
  String get patientReceivedCloseCase;

  /// No description provided for @confirmPersonnelEquipment.
  ///
  /// In en, this message translates to:
  /// **'Confirm available personnel and required equipment for this case.'**
  String get confirmPersonnelEquipment;

  /// No description provided for @nurseAvailable.
  ///
  /// In en, this message translates to:
  /// **'Nurse: Available'**
  String get nurseAvailable;

  /// No description provided for @clinicianAvailable.
  ///
  /// In en, this message translates to:
  /// **'Clinician: Available'**
  String get clinicianAvailable;

  /// No description provided for @checklistDeliveryKit.
  ///
  /// In en, this message translates to:
  /// **'Checklist: Delivery Kit, Trauma Kit, PPE'**
  String get checklistDeliveryKit;

  /// No description provided for @confirmStaff.
  ///
  /// In en, this message translates to:
  /// **'Confirm Staff'**
  String get confirmStaff;

  /// No description provided for @trackAmbulanceEtaStatus.
  ///
  /// In en, this message translates to:
  /// **'Track the assigned ambulance ETA and status for this case.'**
  String get trackAmbulanceEtaStatus;

  /// No description provided for @mapEtaPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Map / ETA Placeholder'**
  String get mapEtaPlaceholder;

  /// No description provided for @onTime.
  ///
  /// In en, this message translates to:
  /// **'On Time'**
  String get onTime;

  /// No description provided for @incomingDispatchRequests.
  ///
  /// In en, this message translates to:
  /// **'Incoming Dispatch Requests'**
  String get incomingDispatchRequests;

  /// No description provided for @acceptDispatchToStart.
  ///
  /// In en, this message translates to:
  /// **'Accept a dispatch to start your ride.'**
  String get acceptDispatchToStart;

  /// No description provided for @errorLoadingRequests.
  ///
  /// In en, this message translates to:
  /// **'Error loading requests'**
  String get errorLoadingRequests;

  /// No description provided for @noIncomingRequests.
  ///
  /// In en, this message translates to:
  /// **'No incoming requests'**
  String get noIncomingRequests;

  /// No description provided for @dispatchedCasesAppearHere.
  ///
  /// In en, this message translates to:
  /// **'Dispatched cases will appear here.'**
  String get dispatchedCasesAppearHere;

  /// No description provided for @dispatchRequest.
  ///
  /// In en, this message translates to:
  /// **'Dispatch Request'**
  String get dispatchRequest;

  /// No description provided for @emergencyDispatch.
  ///
  /// In en, this message translates to:
  /// **'Emergency Dispatch'**
  String get emergencyDispatch;

  /// No description provided for @reviewDetailsAcceptProceed.
  ///
  /// In en, this message translates to:
  /// **'Review details, then accept to proceed.'**
  String get reviewDetailsAcceptProceed;

  /// No description provided for @emergencyType.
  ///
  /// In en, this message translates to:
  /// **'Emergency Type'**
  String get emergencyType;

  /// No description provided for @destination.
  ///
  /// In en, this message translates to:
  /// **'Destination'**
  String get destination;

  /// No description provided for @quickContact.
  ///
  /// In en, this message translates to:
  /// **'Quick Contact'**
  String get quickContact;

  /// No description provided for @callClinic.
  ///
  /// In en, this message translates to:
  /// **'Call Clinic'**
  String get callClinic;

  /// No description provided for @acceptDispatch.
  ///
  /// In en, this message translates to:
  /// **'Accept Dispatch'**
  String get acceptDispatch;

  /// No description provided for @toBeDetermined.
  ///
  /// In en, this message translates to:
  /// **'To be determined'**
  String get toBeDetermined;

  /// No description provided for @statusUpdatedTo.
  ///
  /// In en, this message translates to:
  /// **'Status updated to {status}'**
  String statusUpdatedTo(String status);

  /// No description provided for @arrivedAtScene.
  ///
  /// In en, this message translates to:
  /// **'Arrived at Scene'**
  String get arrivedAtScene;

  /// No description provided for @arrivedAtVht.
  ///
  /// In en, this message translates to:
  /// **'Arrived at VHT'**
  String get arrivedAtVht;

  /// No description provided for @deliveredToClinic.
  ///
  /// In en, this message translates to:
  /// **'Delivered to Clinic'**
  String get deliveredToClinic;

  /// No description provided for @patientPickedUp.
  ///
  /// In en, this message translates to:
  /// **'Patient Picked Up'**
  String get patientPickedUp;

  /// No description provided for @patientDeliveredSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Patient Delivered Successfully'**
  String get patientDeliveredSuccessfully;

  /// No description provided for @deliveryCompleteClinicHandles.
  ///
  /// In en, this message translates to:
  /// **'Your delivery is complete. The clinic will handle the patient from here.'**
  String get deliveryCompleteClinicHandles;

  /// No description provided for @sortByTime.
  ///
  /// In en, this message translates to:
  /// **'Sort by time'**
  String get sortByTime;

  /// No description provided for @sortBySeverity.
  ///
  /// In en, this message translates to:
  /// **'Sort by severity'**
  String get sortBySeverity;

  /// No description provided for @sortByStatus.
  ///
  /// In en, this message translates to:
  /// **'Sort by status'**
  String get sortByStatus;

  /// No description provided for @viewAndManageSystemUsers.
  ///
  /// In en, this message translates to:
  /// **'View and manage system users by role.'**
  String get viewAndManageSystemUsers;

  /// No description provided for @noUsersFound.
  ///
  /// In en, this message translates to:
  /// **'No users found'**
  String get noUsersFound;

  /// No description provided for @unknownUser.
  ///
  /// In en, this message translates to:
  /// **'Unknown User'**
  String get unknownUser;

  /// No description provided for @tapToPlay.
  ///
  /// In en, this message translates to:
  /// **'Tap to play'**
  String get tapToPlay;

  /// No description provided for @tapToOpenCamera.
  ///
  /// In en, this message translates to:
  /// **'Tap to open camera'**
  String get tapToOpenCamera;

  /// No description provided for @notificationFallbackTitle.
  ///
  /// In en, this message translates to:
  /// **'Notification'**
  String get notificationFallbackTitle;

  /// No description provided for @locationPermissionDeniedForever.
  ///
  /// In en, this message translates to:
  /// **'Location permission is permanently denied. Please open Settings and enable location for this app.'**
  String get locationPermissionDeniedForever;

  /// No description provided for @locationUnknownError.
  ///
  /// In en, this message translates to:
  /// **'Could not get location'**
  String get locationUnknownError;

  /// No description provided for @tapToRecordVoiceNote.
  ///
  /// In en, this message translates to:
  /// **'Tap to record voice note'**
  String get tapToRecordVoiceNote;

  /// No description provided for @voiceNoteOptional.
  ///
  /// In en, this message translates to:
  /// **'Voice Note (optional)'**
  String get voiceNoteOptional;

  /// No description provided for @recordingWithDuration.
  ///
  /// In en, this message translates to:
  /// **'Recording: {duration}'**
  String recordingWithDuration(String duration);

  /// No description provided for @arrivedPatients.
  ///
  /// In en, this message translates to:
  /// **'Arrived Patients'**
  String get arrivedPatients;

  /// No description provided for @noPatientsArrivedYet.
  ///
  /// In en, this message translates to:
  /// **'No patients arrived yet'**
  String get noPatientsArrivedYet;

  /// No description provided for @patientsWillAppearHereOnceDelivered.
  ///
  /// In en, this message translates to:
  /// **'Patients will appear here once delivered by ambulance.'**
  String get patientsWillAppearHereOnceDelivered;

  /// No description provided for @notSpecified.
  ///
  /// In en, this message translates to:
  /// **'Not specified'**
  String get notSpecified;

  /// No description provided for @idLabel.
  ///
  /// In en, this message translates to:
  /// **'ID'**
  String get idLabel;

  /// No description provided for @patientInfo.
  ///
  /// In en, this message translates to:
  /// **'Patient info'**
  String get patientInfo;

  /// No description provided for @patientOnboard.
  ///
  /// In en, this message translates to:
  /// **'Patient onboard'**
  String get patientOnboard;

  /// No description provided for @inTreatmentStatus.
  ///
  /// In en, this message translates to:
  /// **'IN TREATMENT'**
  String get inTreatmentStatus;

  /// No description provided for @deliveredStatus.
  ///
  /// In en, this message translates to:
  /// **'DELIVERED'**
  String get deliveredStatus;

  /// No description provided for @resolutionRate.
  ///
  /// In en, this message translates to:
  /// **'Resolution Rate'**
  String get resolutionRate;

  /// No description provided for @doneLabel.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get doneLabel;

  /// No description provided for @resolutionLabel.
  ///
  /// In en, this message translates to:
  /// **'Resolution'**
  String get resolutionLabel;

  /// No description provided for @adultFemale.
  ///
  /// In en, this message translates to:
  /// **'Adult Female'**
  String get adultFemale;

  /// No description provided for @unknownPatient.
  ///
  /// In en, this message translates to:
  /// **'Unknown patient'**
  String get unknownPatient;

  /// No description provided for @yearsShort.
  ///
  /// In en, this message translates to:
  /// **'{n} yrs'**
  String yearsShort(int n);

  /// No description provided for @yourNotes.
  ///
  /// In en, this message translates to:
  /// **'Your Notes'**
  String get yourNotes;

  /// No description provided for @yourAdviceToVht.
  ///
  /// In en, this message translates to:
  /// **'Your Advice to VHT'**
  String get yourAdviceToVht;

  /// No description provided for @youAdvisedVhtCloseCase.
  ///
  /// In en, this message translates to:
  /// **'You advised the VHT. When the patient is OK, close the case.'**
  String get youAdvisedVhtCloseCase;

  /// No description provided for @patientDeliveredReceiveNow.
  ///
  /// In en, this message translates to:
  /// **'Patient has been delivered to the clinic. Receive the patient to begin treatment.'**
  String get patientDeliveredReceiveNow;

  /// No description provided for @dispatching.
  ///
  /// In en, this message translates to:
  /// **'Dispatching...'**
  String get dispatching;

  /// No description provided for @progressTimeline.
  ///
  /// In en, this message translates to:
  /// **'Progress Timeline'**
  String get progressTimeline;

  /// No description provided for @reviewEventsForCase.
  ///
  /// In en, this message translates to:
  /// **'Review events for this emergency case.'**
  String get reviewEventsForCase;

  /// No description provided for @liveMapCachedOffline.
  ///
  /// In en, this message translates to:
  /// **'Live map · Tiles cached for offline use'**
  String get liveMapCachedOffline;

  /// No description provided for @gettingYourLocation.
  ///
  /// In en, this message translates to:
  /// **'Getting your location...'**
  String get gettingYourLocation;

  /// No description provided for @openNavigationMap.
  ///
  /// In en, this message translates to:
  /// **'Open Navigation Map'**
  String get openNavigationMap;

  /// No description provided for @backToDashboard.
  ///
  /// In en, this message translates to:
  /// **'Back to Dashboard'**
  String get backToDashboard;

  /// No description provided for @vhtPhoneNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'VHT phone number not available'**
  String get vhtPhoneNotAvailable;

  /// No description provided for @clinicianPhoneNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Clinician phone number not available'**
  String get clinicianPhoneNotAvailable;

  /// No description provided for @urgencyWithLevel.
  ///
  /// In en, this message translates to:
  /// **'Urgency: {level}'**
  String urgencyWithLevel(String level);

  /// No description provided for @areYouSureCloseCasePatientOk.
  ///
  /// In en, this message translates to:
  /// **'Are you sure the patient is OK and this case can be closed?'**
  String get areYouSureCloseCasePatientOk;

  /// No description provided for @closeCaseConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Close Case'**
  String get closeCaseConfirmTitle;

  /// No description provided for @dischargePatientConfirmMsg.
  ///
  /// In en, this message translates to:
  /// **'This will mark the patient as discharged and close this case. Are you sure?'**
  String get dischargePatientConfirmMsg;

  /// No description provided for @errorLoadingCaseData.
  ///
  /// In en, this message translates to:
  /// **'Error loading case data'**
  String get errorLoadingCaseData;

  /// No description provided for @callsLabel.
  ///
  /// In en, this message translates to:
  /// **'Calls'**
  String get callsLabel;

  /// No description provided for @notificationAmbulanceRequestStandby.
  ///
  /// In en, this message translates to:
  /// **'Ambulance Request — Standby'**
  String get notificationAmbulanceRequestStandby;

  /// No description provided for @notificationAmbulanceRequestStandbyMessage.
  ///
  /// In en, this message translates to:
  /// **'Clinician {clinicianName} has requested an ambulance for a {emergencyType} case. Patient: {patientName}. Be ready for dispatch.'**
  String notificationAmbulanceRequestStandbyMessage(
    String clinicianName,
    String emergencyType,
    String patientName,
  );

  /// No description provided for @tapToViewCase.
  ///
  /// In en, this message translates to:
  /// **'Tap to view case'**
  String get tapToViewCase;

  /// No description provided for @latestDispatchRequest.
  ///
  /// In en, this message translates to:
  /// **'Latest Dispatch Request'**
  String get latestDispatchRequest;

  /// No description provided for @noNewDispatchRequests.
  ///
  /// In en, this message translates to:
  /// **'No new dispatch requests'**
  String get noNewDispatchRequests;

  /// No description provided for @viewAllRequests.
  ///
  /// In en, this message translates to:
  /// **'View All Requests'**
  String get viewAllRequests;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;
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
      <String>['ar', 'en', 'sw'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'sw':
      return AppLocalizationsSw();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
