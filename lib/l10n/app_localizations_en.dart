// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Emergency Health System';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get account => 'Account';

  @override
  String get preferences => 'Preferences';

  @override
  String get app => 'App';

  @override
  String get about => 'About';

  @override
  String get helpSupport => 'Help & Support';

  @override
  String get ok => 'OK';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get submit => 'Submit';

  @override
  String get confirm => 'Confirm';

  @override
  String get close => 'Close';

  @override
  String get done => 'Done';

  @override
  String get name => 'Name';

  @override
  String get role => 'Role';

  @override
  String get phone => 'Phone';

  @override
  String get email => 'Email';

  @override
  String get specialtyProfession => 'Specialty / Profession';

  @override
  String get assignedFacility => 'Assigned Facility';

  @override
  String get settlementCamp => 'Settlement / Camp';

  @override
  String get aboutMessage =>
      'HealthAlert\n\nVersion 1.0.0\n\nEmergency communication for front line health response.';

  @override
  String get failedToSaveLanguage => 'Failed to save language preference';

  @override
  String get helpSupportComingSoon => 'Help & Support coming soon';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageSwahili => 'Kiswahili';

  @override
  String get languageArabic => 'العربية';

  @override
  String get changeLanguageConfirmTitle => 'Change language?';

  @override
  String changeLanguageConfirmMessage(String language) {
    return 'Change language to $language? The app will update immediately.';
  }

  @override
  String languageChangedSuccess(String language) {
    return 'Language changed to $language';
  }

  @override
  String get dashboard => 'Dashboard';

  @override
  String get notifications => 'Notifications';

  @override
  String get reports => 'Reports';

  @override
  String get analytics => 'Analytics';

  @override
  String get logout => 'Logout';

  @override
  String get menu => 'Menu';

  @override
  String get viewAll => 'View All';

  @override
  String get searchByPatientNameOrId => 'Search by patient name or ID...';

  @override
  String get searchByPatientNameOrType =>
      'Search by patient name or emergency type...';

  @override
  String get searchByPatientNameIdOrType =>
      'Search by patient name, ID, or type...';

  @override
  String get searchByPatientVhtOrType => 'Search by patient, VHT, or type...';

  @override
  String get searchUsers => 'Search users...';

  @override
  String get tapToReview => 'Tap to review';

  @override
  String get voiceNote => 'Voice note';

  @override
  String get reviewPatient => 'Review Patient';

  @override
  String get newEmergency => 'New Emergency';

  @override
  String get reportEmergency => 'Report Emergency';

  @override
  String get selectTypeOfEmergency => 'Select the type of emergency';

  @override
  String get areaMap => 'Area Map';

  @override
  String get navigationMap => 'Navigation Map';

  @override
  String get birth => 'Birth';

  @override
  String get trauma => 'Trauma';

  @override
  String get infection => 'Infection';

  @override
  String get other => 'Other';

  @override
  String get login => 'Login';

  @override
  String get welcomeBack => 'Welcome back!';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get pin => 'PIN';

  @override
  String get enterPin => 'Enter PIN';

  @override
  String get reenterPin => 'Re-enter PIN';

  @override
  String get setUpPin => 'Set Up PIN';

  @override
  String get confirmPin => 'Confirm PIN';

  @override
  String get verifyPhoneNumber => 'Verify Phone Number';

  @override
  String get verifyEmail => 'Verify Email';

  @override
  String get getVerificationCode => 'Get Verification Code';

  @override
  String get codeSentResend => 'Code Sent - Resend?';

  @override
  String get resendVerificationCode => 'Resend Verification Code';

  @override
  String get verificationCode => 'Verification Code';

  @override
  String get goBack => 'Go back';

  @override
  String get goBackAndTryAgain => 'Go back and try again';

  @override
  String get register => 'Register';

  @override
  String get registerNewAccount => 'Register new account';

  @override
  String get alreadyHaveAccountLogin => 'Already have an account? Login';

  @override
  String get forgotPinRegisterAgain => 'Forgot PIN? Register again';

  @override
  String get vhtDetails => 'VHT Details';

  @override
  String get ambulanceDriverDetails => 'Ambulance Driver Details';

  @override
  String get adminDetails => 'Admin Details';

  @override
  String get clinicianDetails => 'Clinician Details';

  @override
  String get firstName => 'First Name';

  @override
  String get lastName => 'Last Name';

  @override
  String get emailAddress => 'Email Address *';

  @override
  String get phoneNumberHint => '+256700000001';

  @override
  String get verificationCodeHint => '123456';

  @override
  String get adminVerificationCodeHint => '1234';

  @override
  String get emailHint => 'admin@example.com';

  @override
  String get iAmA => 'I am a...';

  @override
  String get pinHelperText => '4-6 digits';

  @override
  String get pleaseEnterPhoneNumber => 'Please enter your phone number';

  @override
  String get pleaseEnterPin => 'Please enter your PIN';

  @override
  String get pinMustBeDigits => 'PIN must be 4-6 digits';

  @override
  String get incorrectPinTryAgain => 'Incorrect PIN. Please try again.';

  @override
  String get userDataNotLoaded => 'User data not loaded. Please try again.';

  @override
  String get noAccountFoundRegisterFirst =>
      'No account found with this phone number. Please register first.';

  @override
  String get errorLoadingUserData => 'Error loading user data';

  @override
  String get pleaseEnterVerificationCode =>
      'Please enter the verification code';

  @override
  String get loginSuccessful => 'Login successful!';

  @override
  String get verificationCodeSentToEmail =>
      'Verification code sent to your email';

  @override
  String get verificationCodeResentToEmail =>
      'Verification code resent to your email';

  @override
  String get pleaseEnterEmailAddress => 'Please enter your email address';

  @override
  String get pleaseVerifyEmailFirst =>
      'Please verify your email first by clicking \"Get Verification Code\"';

  @override
  String get failedToSendVerificationCode => 'Failed to send verification code';

  @override
  String get failedToResendCode => 'Failed to resend code';

  @override
  String get verificationFailed => 'Verification failed';

  @override
  String get registrationFailed => 'Registration failed';

  @override
  String get verificationError => 'Verification error';

  @override
  String get phoneNumberMinDigits => 'Phone number must be at least 9 digits';

  @override
  String get userExistsPleaseLogin =>
      'User with this phone number already exists. Please login instead.';

  @override
  String get pleaseEnterFirstName => 'Please enter your first name';

  @override
  String get pleaseEnterLastName => 'Please enter your last name';

  @override
  String get pleaseSelectProfession => 'Please select your profession';

  @override
  String get pleaseSelectSettlementCamp =>
      'Please select your settlement / camp';

  @override
  String get pleaseSelectHealthFacility => 'Please select your health facility';

  @override
  String welcomeBackDr(String name) {
    return 'Welcome back, Dr. $name';
  }

  @override
  String welcomeBackName(String name) {
    return 'Welcome back, $name';
  }

  @override
  String get user => 'User';

  @override
  String get vht => 'VHT';

  @override
  String get ambulance => 'Ambulance';

  @override
  String get clinic => 'Clinic';

  @override
  String get admin => 'Admin';

  @override
  String get gender => 'Gender';

  @override
  String get age => 'Age';

  @override
  String get enterAgeInYears => 'Enter age in years';

  @override
  String get typeImportantNotes => 'Type any important notes…';

  @override
  String get selectTriageLevel => 'Select triage level';

  @override
  String get selectFacility => 'Select a facility…';

  @override
  String get pleaseSelectPatientGender => 'Please select patient gender.';

  @override
  String get pleaseEnterDobOrAge =>
      'Please enter patient date of birth or age.';

  @override
  String get pleaseSelectTriageLevel => 'Please select a triage level.';

  @override
  String get pleaseSelectHealthFacilityToNotify =>
      'Please select the health facility to notify.';

  @override
  String get locationPermissionRequired => 'Location Permission Required';

  @override
  String get pleaseEnableLocationInSettings =>
      'Please open Settings and enable location for this app.';

  @override
  String get openSettings => 'Open Settings';

  @override
  String get male => 'Male';

  @override
  String get female => 'Female';

  @override
  String get critical => 'Critical';

  @override
  String get high => 'High';

  @override
  String get moderate => 'Moderate';

  @override
  String get low => 'Low';

  @override
  String get pleaseSelectAnotherFacilityOrContactSupervisor =>
      'Please select another facility or contact your supervisor.';

  @override
  String warningFailedUploadMedia(String files) {
    return 'Warning: Failed to upload $files. Case will be submitted without media.';
  }

  @override
  String get warningMediaUploadFailed =>
      'Warning: Media upload failed. Case will be submitted without media.';

  @override
  String get errorSubmittingCase => 'Error submitting case';

  @override
  String get retryLocationCapture => 'Retry Location Capture';

  @override
  String get failedToCaptureLocation =>
      'Failed to capture location. Please try again.';

  @override
  String get errorCreatingEmergencyCase => 'Error creating emergency case';

  @override
  String get sendFollowUpUpdate => 'Send Follow-up Update';

  @override
  String get provideUpdateOnCondition =>
      'Provide an update on the patient\'s current condition:';

  @override
  String get sendUpdate => 'Send Update';

  @override
  String get followUpUpdateSentSuccessfully =>
      'Follow-up update sent successfully.';

  @override
  String get failedToSendFollowUp => 'Failed to send follow-up';

  @override
  String get caseNotFound => 'Case not found.';

  @override
  String get noAdminContactFound => 'No admin contact found.';

  @override
  String couldNotOpenDialer(String phone) {
    return 'Could not open dialer for $phone';
  }

  @override
  String get errorFindingAdmin => 'Error finding admin';

  @override
  String get clinicianAdvice => 'Clinician Advice';

  @override
  String get clinicianNotes => 'Clinician Notes';

  @override
  String get callClinician => 'Call Clinician';

  @override
  String get callAmbulanceDriver => 'Call Ambulance Driver';

  @override
  String get noContactsAvailableYet => 'No contacts available yet.';

  @override
  String get couldNotLoadImage => 'Could not load image';

  @override
  String get tapImageToViewFullScreen => 'Tap image to view full screen';

  @override
  String get videoAttached => 'Video Attached';

  @override
  String get tapToPlayVideo => 'Tap to play video';

  @override
  String get latestFollowUp => 'Latest Follow-up';

  @override
  String get needHelpWithDispatch => 'Need help with dispatch?';

  @override
  String get contactAdminForDispatch =>
      'Contact the admin to check on dispatch status.';

  @override
  String get callAdmin => 'Call Admin';

  @override
  String get message => 'Message';

  @override
  String get followUpHint => 'e.g. Patient condition worsening...';

  @override
  String get caseClosed => 'Case closed.';

  @override
  String get pleaseAddNotesBeforeCallingClinic =>
      'Please add some notes before calling the clinic.';

  @override
  String get pendingReview => 'Pending Review';

  @override
  String get clinicianAdvised => 'Clinician Advised';

  @override
  String get ambulanceRequested => 'Ambulance Requested';

  @override
  String get ambulanceDispatched => 'Ambulance Dispatched';

  @override
  String get ambulanceEnRoute => 'Ambulance En Route';

  @override
  String get ambulanceArrived => 'Ambulance Arrived';

  @override
  String get patientInTransit => 'Patient In Transit';

  @override
  String get patientDelivered => 'Patient Delivered';

  @override
  String get inTreatment => 'In Treatment';

  @override
  String get admitted => 'Admitted';

  @override
  String get discharged => 'Discharged';

  @override
  String get caseCompleted => 'Case Completed';

  @override
  String get caseCancelled => 'Case Cancelled';

  @override
  String get adviceSent => 'Advice Sent';

  @override
  String get dispatched => 'Dispatched';

  @override
  String get enRoute => 'En Route';

  @override
  String get arrived => 'Arrived';

  @override
  String get awaitingStatusUpdate => 'Awaiting status update.';

  @override
  String get justNow => 'Just now';

  @override
  String minAgo(int n) {
    return '$n min ago';
  }

  @override
  String hrAgo(int n) {
    return '$n hr ago';
  }

  @override
  String get patientInformation => 'Patient Information';

  @override
  String get reportingVht => 'Reporting VHT';

  @override
  String get ambulanceDriver => 'Ambulance Driver';

  @override
  String get vhtNotes => 'VHT Notes';

  @override
  String get mediaFromVht => 'Media from VHT';

  @override
  String get attachments => 'Attachments';

  @override
  String get treatmentNotesDischarge => 'Treatment Notes & Discharge';

  @override
  String get noMediaAttachedByVht => 'No media attached by VHT';

  @override
  String get viewAttachment => 'View attachment';

  @override
  String get takeAction => 'Take Action';

  @override
  String get addNotesAndDecide =>
      'Add notes and decide whether to dispatch an ambulance or advise the VHT.';

  @override
  String get requestAmbulanceDispatch => 'Request Ambulance Dispatch';

  @override
  String get sendAdviceToVht => 'Send Advice to VHT';

  @override
  String get closeCasePatientOk => 'Close Case (Patient OK)';

  @override
  String get receivePatient => 'Receive Patient';

  @override
  String get patientInTreatment => 'Patient In Treatment';

  @override
  String get admitPatientInpatientOrDischarge =>
      'Admit the patient for inpatient care, or add treatment notes and discharge.';

  @override
  String get admitPatient => 'Admit Patient';

  @override
  String get treatAndDischarge => 'Treat & Discharge';

  @override
  String get patientAdmitted => 'Patient Admitted';

  @override
  String get addTreatmentNotesAndDischarge =>
      'Add treatment notes and discharge when ready.';

  @override
  String get dischargePatient => 'Discharge Patient';

  @override
  String get dispatch => 'Dispatch';

  @override
  String get closeCase => 'Close Case';

  @override
  String get discharge => 'Discharge';

  @override
  String get ambulanceDispatchRequested => 'Ambulance dispatch requested.';

  @override
  String get pleaseAddAdviceForVhtFirst =>
      'Please add advice for the VHT first.';

  @override
  String get adviceSentToVhtSuccessfully => 'Advice sent to VHT successfully.';

  @override
  String get caseClosedSuccessfully => 'Case closed successfully.';

  @override
  String get patientReceivedAddTreatmentNotes =>
      'Patient received. You can now add treatment notes.';

  @override
  String get patientAdmittedAddNotesWhenReady =>
      'Patient admitted. Add treatment notes when ready to discharge.';

  @override
  String get pleaseEnterTreatmentNotesBeforeDischarging =>
      'Please enter treatment notes before discharging';

  @override
  String get patientDischargedCaseCompleted =>
      'Patient discharged. Case completed.';

  @override
  String get couldNotOpenVideo => 'Could not open video';

  @override
  String get callVht => 'Call VHT';

  @override
  String get callDriver => 'Call Driver';

  @override
  String get addNotesAdviceForVhtHint =>
      'Add your notes or advice for the VHT...';

  @override
  String get treatmentNotesHint =>
      'Enter diagnosis, treatment given, medications...';

  @override
  String get activeCases => 'Active Cases';

  @override
  String get clinicNotifiedAboutArrival => 'Clinic notified about arrival.';

  @override
  String get vhtNotifiedAboutArrival => 'VHT notified about arrival.';

  @override
  String failedToUpdateStatus(String error) {
    return 'Failed to update status: $error';
  }

  @override
  String couldNotLaunchDialer(String phone) {
    return 'Could not launch dialer for $phone';
  }

  @override
  String get errorAcceptingDispatch => 'Error accepting dispatch';

  @override
  String get dispatchAmbulance => 'Dispatch Ambulance';

  @override
  String get userDetails => 'User Details';

  @override
  String get cannotRemoveAdminUsers => 'Cannot remove admin users';

  @override
  String get areYouSureRemoveUser =>
      'Are you sure you want to remove this user?';

  @override
  String get userRemoved => 'User removed';

  @override
  String get failedToRemoveUser => 'Failed to remove user';

  @override
  String get casesByType => 'Cases by Type';

  @override
  String get urgencyDistribution => 'Urgency Distribution';

  @override
  String get staffCoverage => 'Staff Coverage';

  @override
  String get caseLoadByFacility => 'Case Load by Facility';

  @override
  String get rankedByTotalCasesAssigned => 'Ranked by total cases assigned';

  @override
  String get criticalUnresolvedCases => 'Critical Unresolved Cases';

  @override
  String get exportReports => 'Export Reports';

  @override
  String get errorLoadingFacilityData => 'Error loading facility data';

  @override
  String get noFacilityDataYet => 'No facility data yet.';

  @override
  String get unassigned => 'Unassigned';

  @override
  String get viewAndManageOngoingCases => 'View and manage all ongoing cases.';

  @override
  String get addOrRemoveSystemUsers => 'Add or remove system users.';

  @override
  String get manageUsers => 'Manage Users';

  @override
  String get failedToGenerateReport => 'Failed to generate report';

  @override
  String get totalCases => 'Total Cases';

  @override
  String get activeCasesCount => 'Active Cases';

  @override
  String get completedCases => 'Completed Cases';

  @override
  String get ambulanceDispatchedSuccessfully =>
      'Ambulance dispatched successfully.';

  @override
  String get pleaseSignInToViewNotifications =>
      'Please sign in to view notifications';

  @override
  String get markAllRead => 'Mark All Read';

  @override
  String get failedToMarkAsRead => 'Failed to mark as read';

  @override
  String get allNotificationsMarkedAsRead => 'All notifications marked as read';

  @override
  String get failedToMarkAllAsRead => 'Failed to mark all as read';

  @override
  String get navigateWithGoogleMaps => 'Navigate with Google Maps';

  @override
  String get couldNotOpenGoogleMaps => 'Could not open Google Maps';

  @override
  String get ugandaClinicalGuidelines2023 => 'Uganda Clinical Guidelines 2023';

  @override
  String get viewCaseHistory => 'View Case History';

  @override
  String get learningResources => 'Learning Resources';

  @override
  String get pickImage => 'Pick Image';

  @override
  String get pickVideo => 'Pick Video';

  @override
  String get pickFromGallery => 'Pick from gallery';

  @override
  String get switchCamera => 'Switch camera';

  @override
  String imageSizeExceedsMax(String size, String max) {
    return 'Image size ($size KB) exceeds maximum ($max KB)';
  }

  @override
  String videoSizeExceedsMax(String size, String max) {
    return 'Video size ($size MB) exceeds maximum ($max MB)';
  }

  @override
  String get microphonePermissionRequired =>
      'Microphone permission is required to record voice notes';

  @override
  String get errorStartingRecording => 'Error starting recording';

  @override
  String get errorStoppingRecording => 'Error stopping recording';

  @override
  String get errorPlayingAudio => 'Error playing audio';

  @override
  String get couldNotPlayVoiceNote => 'Could not play voice note';

  @override
  String get locationServicesDisabled =>
      'Location services are disabled. Please enable GPS in your device settings.';

  @override
  String get locationPermissionDenied =>
      'Location permission was denied. Please grant location access to report emergencies.';

  @override
  String get locationPermissionPermanentlyDenied =>
      'Location permission is permanently denied. Please open Settings and enable location for this app.';

  @override
  String get couldNotGetLocation => 'Could not get location';

  @override
  String get notificationNewEmergencyCase => 'New Emergency Case';

  @override
  String notificationNewEmergencyCaseMessage(
    String emergencyType,
    String vhtName,
    String patientName,
    String urgency,
  ) {
    return 'New $emergencyType case from VHT $vhtName. Patient: $patientName. Urgency: $urgency. Please review immediately.';
  }

  @override
  String get notificationCaseSubmittedSuccessfully =>
      'Case Submitted Successfully';

  @override
  String notificationCaseSubmittedMessage(
    String emergencyType,
    String patientName,
    String clinicName,
  ) {
    return 'Your $emergencyType case for $patientName has been sent to $clinicName for review.';
  }

  @override
  String get notificationVhtFollowUpUpdate => 'VHT Follow-up Update';

  @override
  String notificationVhtFollowUpMessage(
    String vhtName,
    String patientName,
    String message,
  ) {
    return '$vhtName updated on $patientName: \"$message\"';
  }

  @override
  String get notificationClinicianAdviceReceived => 'Clinician Advice Received';

  @override
  String notificationClinicianAdviceMessage(
    String clinicianName,
    String patientName,
    String advice,
  ) {
    return 'Dr. $clinicianName responded about $patientName: \"$advice\"';
  }

  @override
  String get notificationAmbulanceDispatchRequired =>
      'Ambulance Dispatch Required';

  @override
  String get notificationAmbulanceOnTheWay => 'Ambulance On The Way';

  @override
  String notificationAmbulanceOnTheWayMessage(
    String driverName,
    String patientName,
  ) {
    return 'An ambulance driven by $driverName has been dispatched. Stay with $patientName.';
  }

  @override
  String get notificationAmbulanceDispatched => 'Ambulance Dispatched';

  @override
  String notificationAmbulanceDispatchedMessage(
    String driverName,
    String emergencyType,
    String patientName,
  ) {
    return 'Ambulance driver $driverName has been dispatched for the $emergencyType case (Patient: $patientName).';
  }

  @override
  String get notificationNewDispatchAssignment => 'New Dispatch Assignment';

  @override
  String notificationNewDispatchMessage(
    String emergencyType,
    String vhtName,
    String clinicName,
    String patientName,
  ) {
    return 'You have been assigned to a $emergencyType case. Collect patient from VHT $vhtName, deliver to $clinicName. Patient: $patientName.';
  }

  @override
  String get notificationPatientDelivered => 'Patient Delivered';

  @override
  String notificationPatientDeliveredMessage(
    String patientName,
    String emergencyType,
    String clinicName,
    String driverName,
  ) {
    return 'Your patient $patientName ($emergencyType) has been safely delivered to $clinicName by $driverName.';
  }

  @override
  String get notificationPatientArriving => 'Patient Arriving';

  @override
  String notificationPatientArrivingMessage(
    String patientName,
    String emergencyType,
    String driverName,
  ) {
    return 'Patient $patientName ($emergencyType) delivered by $driverName. Please receive the patient.';
  }

  @override
  String get notificationPatientDischarged => 'Patient Discharged';

  @override
  String notificationPatientDischargedMessage(
    String patientName,
    String emergencyType,
    String clinicName,
  ) {
    return 'Your patient $patientName ($emergencyType) has been treated and discharged from $clinicName. Case complete.';
  }

  @override
  String get notificationCaseCompleted => 'Case Completed';

  @override
  String notificationCaseCompletedMessage(
    String patientName,
    String emergencyType,
    String clinicName,
    String clinicianName,
  ) {
    return '$patientName ($emergencyType) has been discharged from $clinicName by Dr. $clinicianName. Case closed.';
  }

  @override
  String get notificationCaseClosed => 'Case Closed';

  @override
  String notificationCaseClosedMessage(
    String clinicianName,
    String patientName,
    String emergencyType,
  ) {
    return 'Dr. $clinicianName has confirmed $patientName ($emergencyType) is OK and closed the case.';
  }

  @override
  String get notificationEmergencyAlerts => 'Emergency Alerts';

  @override
  String get notificationEmergencyAlertsDescription =>
      'Notifications for emergency cases and status updates';

  @override
  String errorGeneric(String error) {
    return 'Error: $error';
  }

  @override
  String reportedBy(String name) {
    return 'Reported by: $name';
  }

  @override
  String reportedAt(String time) {
    return 'Reported: $time';
  }

  @override
  String get splashAppName => 'HealthAlert';

  @override
  String get splashTagline =>
      'Emergency communication for front line health response';

  @override
  String get noNotificationsYet => 'No notifications yet';

  @override
  String get notificationsWillAppearHere => 'Notifications will appear here';

  @override
  String get continueButton => 'Continue';

  @override
  String get enterVerificationCode => 'Enter Verification Code';

  @override
  String weSentCodeTo(String phone) {
    return 'We sent a code to $phone';
  }

  @override
  String get forTestNumbersEnter => 'For test numbers, enter: 123456';

  @override
  String get verifyButton => 'Verify';

  @override
  String get enterYourPinToContinue => 'Enter your PIN to continue';

  @override
  String get verifyPinButton => 'Verify PIN';

  @override
  String get setYourPin => 'Set Your PIN';

  @override
  String get enterPinBetween4And6 => 'Enter a PIN between 4 to 6 digits';

  @override
  String get enterButton => 'Enter';

  @override
  String get pleaseEnterAPin => 'Please enter a PIN';

  @override
  String get pleaseConfirmYourPin => 'Please confirm your PIN';

  @override
  String get pinsDoNotMatch => 'PINs do not match. Please try again.';

  @override
  String get confirmYourPin => 'Confirm Your PIN';

  @override
  String get pleaseReenterPinToConfirm => 'Please re-enter your PIN to confirm';

  @override
  String get homeLabel => 'Home';

  @override
  String get learnLabel => 'Learn';

  @override
  String get mapLabel => 'Map';

  @override
  String get incomingLabel => 'Incoming';

  @override
  String welcomeName(String name) {
    return 'Welcome, $name';
  }

  @override
  String get quickActions => 'Quick Actions';

  @override
  String get ugandaClinicalGuidelinesDescription =>
      'National clinical guidelines for health workers in Uganda';

  @override
  String get patientIdLabel => 'Patient ID';

  @override
  String get dateOfBirth => 'Date of Birth';

  @override
  String get selectDateOfBirth => 'Select Date of Birth';

  @override
  String ageYears(int n) {
    return '$n years';
  }

  @override
  String get notesLabel => 'Notes';

  @override
  String get patientDetailsHelp =>
      'These details will help clinic and ambulance staff prepare.';

  @override
  String get photoVideoOptional => 'Photo / Video (optional)';

  @override
  String noStaffAtFacility(String facility) {
    return 'No available staff at $facility. Please select another facility or contact your supervisor.';
  }

  @override
  String get locationNeedsAccessMessage =>
      'HealthAlert needs location access to report emergencies and help ambulances find patients.\n\nPlease open Settings and enable location for this app.';

  @override
  String get pendingOffline => 'Pending (offline)';

  @override
  String get selectHealthFacility => 'Select Health Facility';

  @override
  String get chooseClinicForPatient =>
      'Choose the clinic best suited for this patient.';

  @override
  String get notifyClinic => 'Notify Clinic';

  @override
  String get triageLevel => 'Triage level';

  @override
  String get caseSubmitted => 'Case Submitted';

  @override
  String get clinicNotifiedOfEmergency =>
      'The clinic has been notified of the emergency.';

  @override
  String get currentStatus => 'Current Status';

  @override
  String get returnToDashboard => 'Return to Dashboard';

  @override
  String get reportAnotherEmergency => 'Report Another Emergency';

  @override
  String get caseTracking => 'Case Tracking';

  @override
  String get assignedClinician => 'Assigned clinician';

  @override
  String get savedOffline => 'Saved Offline';

  @override
  String get caseSavedOfflineMessage =>
      'Case data has been saved locally and will be sent to the clinic when you are back online.';

  @override
  String get lastUpdated => 'Last updated';

  @override
  String get caseDetails => 'Case Details';

  @override
  String get adviceProgress => 'Advice Progress';

  @override
  String get caseProgress => 'Case Progress';

  @override
  String get sending => 'Sending...';

  @override
  String get caseHistory => 'Case History';

  @override
  String get allCases => 'All Cases';

  @override
  String get allTypes => 'All Types';

  @override
  String get activeFilter => 'Active';

  @override
  String get allFilter => 'All';

  @override
  String get completedFilter => 'Completed';

  @override
  String get errorLoadingCases => 'Error loading cases';

  @override
  String get noActiveCases => 'No active cases';

  @override
  String get noCompletedCases => 'No completed cases';

  @override
  String get noCasesFound => 'No cases found';

  @override
  String get casesReportedAppearHere => 'Cases you report will appear here.';

  @override
  String get casesAssignedToYouAppearHere =>
      'Cases assigned to you will appear here.';

  @override
  String get clinicLabel => 'Clinic';

  @override
  String get unknownClinic => 'Unknown Clinic';

  @override
  String get unknown => 'Unknown';

  @override
  String get clinicianLabel => 'Clinician';

  @override
  String get contactSection => 'Contact';

  @override
  String get statusMsgPending => 'The clinician is reviewing your case.';

  @override
  String get statusMsgPendingSubmitted =>
      'The clinician is reviewing your case. You will be updated when a decision is made.';

  @override
  String get statusMsgAdvised =>
      'The clinician has sent you advice. See below.';

  @override
  String get statusMsgAmbRequested =>
      'Clinician has requested an ambulance for this patient.';

  @override
  String get statusMsgDispatched =>
      'An ambulance has been dispatched to your location.';

  @override
  String get statusMsgDispatchedStay =>
      'An ambulance has been dispatched to your location. Stay with the patient.';

  @override
  String get statusMsgEnRoute => 'The ambulance is on its way.';

  @override
  String get statusMsgEnRoutePrepare =>
      'The ambulance is on its way. Prepare the patient for transport.';

  @override
  String get statusMsgArrived => 'The ambulance has arrived.';

  @override
  String get statusMsgArrivedHandOver =>
      'The ambulance has arrived. Hand over the patient to the ambulance crew.';

  @override
  String get statusMsgInTransit =>
      'The patient is being transported to the clinic.';

  @override
  String get statusMsgDelivered =>
      'The patient has been delivered to the clinic.';

  @override
  String get statusMsgInTreatment =>
      'Your patient is currently being treated at the clinic.';

  @override
  String get statusMsgAdmitted => 'Patient has been admitted to the clinic';

  @override
  String get statusMsgDischarged => 'Patient has been discharged';

  @override
  String get statusMsgCompleted => 'This case has been completed.';

  @override
  String get statusMsgCompletedTreated =>
      'This case has been completed. The patient has been treated.';

  @override
  String get statusMsgCancelled => 'This case has been cancelled.';

  @override
  String get viewAllIncomingCases => 'View All Incoming Cases';

  @override
  String get needsYourReview => 'Needs Your Review';

  @override
  String get allCaughtUp => 'All caught up!';

  @override
  String get noCasesPendingReview => 'No cases pending your review right now.';

  @override
  String get ambulanceEmergencyDispatch => 'Ambulance — Emergency Dispatch';

  @override
  String get viewIncomingEmergencyRequests =>
      'View incoming emergency requests from VHTs and clinics.';

  @override
  String get viewDispatch => 'View Dispatch';

  @override
  String get viewActiveCases => 'View Active Cases';

  @override
  String get recentCases => 'Recent Cases';

  @override
  String get noRecentCases => 'No recent cases';

  @override
  String get chooseWhatToManageToday => 'Choose what you want to manage today.';

  @override
  String get dispatchNeeded => 'Dispatch Needed';

  @override
  String get dispatchLabel => 'Dispatch';

  @override
  String get analyticsSubtitle =>
      'View ambulance dispatch and VHT report insights.';

  @override
  String get manageUsersSubtitle => 'Add or remove system users.';

  @override
  String get caseSavedOfflineSyncWhenOnline =>
      'Emergency case saved offline. Will sync when online.';

  @override
  String get emergencyCaseCreatedSuccessfully =>
      'Emergency case created successfully!';

  @override
  String get dispatchConfirmation => 'Dispatch Confirmation';

  @override
  String get clinicAssigned => 'Clinic assigned';

  @override
  String get estimatedArrival => 'Estimated arrival';

  @override
  String get assigningNearestAmbulance =>
      'Automatically assigning nearest ambulance…';

  @override
  String get systemWillChooseClosestAmbulance =>
      'The system will choose the closest available ambulance and update this screen in real time.';

  @override
  String get emergencyTypeLabel => 'Emergency type';

  @override
  String get confirmAndDispatch => 'Confirm & Dispatch';

  @override
  String get setLocation => 'Set Location';

  @override
  String get automaticallyCapturingLocation =>
      'Automatically capturing location…';

  @override
  String get locationCaptureHelp =>
      'This will help responders find you faster.\nNo need to move the map or pin your position.';

  @override
  String clinicAssignedWithName(String name) {
    return 'Clinic assigned: $name';
  }

  @override
  String estimatedArrivalValue(String eta) {
    return 'Estimated arrival: $eta';
  }

  @override
  String locationCoordinates(String lat, String lng) {
    return 'Location: $lat, $lng';
  }

  @override
  String get trackAmbulance => 'Track Ambulance';

  @override
  String get mapPlaceholder => 'Map Placeholder';

  @override
  String get notifyClinicPatientOnboard => 'Notify clinic patient is onboard';

  @override
  String get clinicNotifiedPatientOnboard =>
      'Clinic notified that patient is onboard.';

  @override
  String get caseClosedButton => 'Case Closed';

  @override
  String get onboardPatient => 'Onboard Patient';

  @override
  String get callingClinicToDiscuss =>
      'Calling clinic to discuss whether an ambulance is needed...';

  @override
  String get callClinicToDiscussCase => 'Call clinic to discuss case';

  @override
  String get continueToDispatchAmbulance => 'Continue to dispatch ambulance';

  @override
  String errorCreatingEmergencyCaseWithError(String error) {
    return 'Error creating emergency case: $error';
  }

  @override
  String get incomingCases => 'Incoming Cases';

  @override
  String get reviewEmergenciesSubmittedByVhts =>
      'Review emergencies submitted by VHTs.';

  @override
  String get emergencyCasesAssignedToYourClinic =>
      'Emergency cases assigned to your clinic will appear here.';

  @override
  String get patientLabel => 'Patient';

  @override
  String get requestAmbulanceDispatchConfirm =>
      'This will forward the case to dispatch to assign an ambulance. Do you want to proceed?';

  @override
  String get patientReceived => 'Patient Received';

  @override
  String get proceed => 'Proceed';

  @override
  String get caseSummary => 'Case Summary';

  @override
  String get patientArrival => 'Patient Arrival';

  @override
  String get assignStaff => 'Assign Staff';

  @override
  String get ambulanceTracking => 'Ambulance Tracking';

  @override
  String get activeCasesTitle => 'Active Cases';

  @override
  String get allIncomingRequests => 'All Incoming Requests';

  @override
  String get incomingDispatch => 'Incoming Dispatch';

  @override
  String get arrival => 'Arrival';

  @override
  String get caseClosure => 'Case Closure';

  @override
  String get adminHome => 'Home';

  @override
  String get adminCases => 'Cases';

  @override
  String get adminAnalytics => 'Analytics';

  @override
  String get adminUsers => 'Users';

  @override
  String get caseDashboard => 'Case Dashboard';

  @override
  String get caseAnalytics => 'Case Analytics';

  @override
  String get manageUsersScreen => 'Manage Users';

  @override
  String get userDetail => 'User Detail';

  @override
  String get caseTimeline => 'Case Timeline';

  @override
  String get allCasesList => 'All Cases';

  @override
  String get reportsExport => 'Export Reports';

  @override
  String get vhtDetailsForm => 'VHT Details';

  @override
  String get clinicianRegistrationForm => 'Clinician Registration';

  @override
  String get adminDetailsForm => 'Admin Details';

  @override
  String get ambulanceDriverDetailsForm => 'Ambulance Driver Details';

  @override
  String get adminEmailOtpScreen => 'Admin Email Verification';

  @override
  String get registrationForm => 'Registration';

  @override
  String get fullScreenCamera => 'Camera';

  @override
  String get voiceNoteWidget => 'Voice note';

  @override
  String get locationRequestTimeout => 'Location request timed out';

  @override
  String couldNotGetLocationWithError(String error) {
    return 'Could not get location: $error';
  }

  @override
  String get reviewMediaTriageNextActions =>
      'Review media, triage level, and next actions for this emergency.';

  @override
  String get photoVoiceNotePreview => 'Photo / Voice Note Preview';

  @override
  String get triageLevelHighRed => 'Triage Level: High (Red)';

  @override
  String get seeStaff => 'See Staff';

  @override
  String get requestAdditionalInfo => 'Request Additional Info';

  @override
  String get callingVhtPlaceholder => 'Calling VHT (placeholder)...';

  @override
  String get callingAmbulancePlaceholder =>
      'Calling ambulance (placeholder)...';

  @override
  String get confirmStaffAssignmentCloseCase =>
      'Confirm staff assignment and close the case once the patient is received.';

  @override
  String get emergencyLabel => 'Emergency';

  @override
  String get staffAssigned => 'Staff assigned';

  @override
  String get patientReceivedCloseCase => 'Patient Received / Close Case';

  @override
  String get confirmPersonnelEquipment =>
      'Confirm available personnel and required equipment for this case.';

  @override
  String get nurseAvailable => 'Nurse: Available';

  @override
  String get clinicianAvailable => 'Clinician: Available';

  @override
  String get checklistDeliveryKit => 'Checklist: Delivery Kit, Trauma Kit, PPE';

  @override
  String get confirmStaff => 'Confirm Staff';

  @override
  String get trackAmbulanceEtaStatus =>
      'Track the assigned ambulance ETA and status for this case.';

  @override
  String get mapEtaPlaceholder => 'Map / ETA Placeholder';

  @override
  String get onTime => 'On Time';

  @override
  String get incomingDispatchRequests => 'Incoming Dispatch Requests';

  @override
  String get acceptDispatchToStart => 'Accept a dispatch to start your ride.';

  @override
  String get errorLoadingRequests => 'Error loading requests';

  @override
  String get noIncomingRequests => 'No incoming requests';

  @override
  String get dispatchedCasesAppearHere => 'Dispatched cases will appear here.';

  @override
  String get dispatchRequest => 'Dispatch Request';

  @override
  String get emergencyDispatch => 'Emergency Dispatch';

  @override
  String get reviewDetailsAcceptProceed =>
      'Review details, then accept to proceed.';

  @override
  String get emergencyType => 'Emergency Type';

  @override
  String get destination => 'Destination';

  @override
  String get quickContact => 'Quick Contact';

  @override
  String get callClinic => 'Call Clinic';

  @override
  String get acceptDispatch => 'Accept Dispatch';

  @override
  String get toBeDetermined => 'To be determined';

  @override
  String statusUpdatedTo(String status) {
    return 'Status updated to $status';
  }

  @override
  String get arrivedAtScene => 'Arrived at Scene';

  @override
  String get arrivedAtVht => 'Arrived at VHT';

  @override
  String get deliveredToClinic => 'Delivered to Clinic';

  @override
  String get patientPickedUp => 'Patient Picked Up';

  @override
  String get patientDeliveredSuccessfully => 'Patient Delivered Successfully';

  @override
  String get deliveryCompleteClinicHandles =>
      'Your delivery is complete. The clinic will handle the patient from here.';

  @override
  String get sortByTime => 'Sort by time';

  @override
  String get sortBySeverity => 'Sort by severity';

  @override
  String get sortByStatus => 'Sort by status';

  @override
  String get viewAndManageSystemUsers =>
      'View and manage system users by role.';

  @override
  String get noUsersFound => 'No users found';

  @override
  String get unknownUser => 'Unknown User';

  @override
  String get tapToPlay => 'Tap to play';

  @override
  String get tapToOpenCamera => 'Tap to open camera';

  @override
  String get notificationFallbackTitle => 'Notification';

  @override
  String get locationPermissionDeniedForever =>
      'Location permission is permanently denied. Please open Settings and enable location for this app.';

  @override
  String get locationUnknownError => 'Could not get location';

  @override
  String get tapToRecordVoiceNote => 'Tap to record voice note';

  @override
  String get voiceNoteOptional => 'Voice Note (optional)';

  @override
  String recordingWithDuration(String duration) {
    return 'Recording: $duration';
  }

  @override
  String get arrivedPatients => 'Arrived Patients';

  @override
  String get noPatientsArrivedYet => 'No patients arrived yet';

  @override
  String get patientsWillAppearHereOnceDelivered =>
      'Patients will appear here once delivered by ambulance.';

  @override
  String get notSpecified => 'Not specified';

  @override
  String get idLabel => 'ID';

  @override
  String get patientInfo => 'Patient info';

  @override
  String get patientOnboard => 'Patient onboard';

  @override
  String get inTreatmentStatus => 'IN TREATMENT';

  @override
  String get deliveredStatus => 'DELIVERED';

  @override
  String get resolutionRate => 'Resolution Rate';

  @override
  String get doneLabel => 'Done';

  @override
  String get resolutionLabel => 'Resolution';

  @override
  String get adultFemale => 'Adult Female';

  @override
  String get unknownPatient => 'Unknown patient';

  @override
  String yearsShort(int n) {
    return '$n yrs';
  }

  @override
  String get yourNotes => 'Your Notes';

  @override
  String get yourAdviceToVht => 'Your Advice to VHT';

  @override
  String get youAdvisedVhtCloseCase =>
      'You advised the VHT. When the patient is OK, close the case.';

  @override
  String get patientDeliveredReceiveNow =>
      'Patient has been delivered to the clinic. Receive the patient to begin treatment.';

  @override
  String get dispatching => 'Dispatching...';

  @override
  String get progressTimeline => 'Progress Timeline';

  @override
  String get reviewEventsForCase => 'Review events for this emergency case.';

  @override
  String get liveMapCachedOffline => 'Live map · Tiles cached for offline use';

  @override
  String get gettingYourLocation => 'Getting your location...';

  @override
  String get openNavigationMap => 'Open Navigation Map';

  @override
  String get backToDashboard => 'Back to Dashboard';

  @override
  String get vhtPhoneNotAvailable => 'VHT phone number not available';

  @override
  String get clinicianPhoneNotAvailable =>
      'Clinician phone number not available';

  @override
  String urgencyWithLevel(String level) {
    return 'Urgency: $level';
  }

  @override
  String get areYouSureCloseCasePatientOk =>
      'Are you sure the patient is OK and this case can be closed?';

  @override
  String get closeCaseConfirmTitle => 'Close Case';

  @override
  String get dischargePatientConfirmMsg =>
      'This will mark the patient as discharged and close this case. Are you sure?';

  @override
  String get errorLoadingCaseData => 'Error loading case data';

  @override
  String get callsLabel => 'Calls';

  @override
  String get notificationAmbulanceRequestStandby =>
      'Ambulance Request — Standby';

  @override
  String notificationAmbulanceRequestStandbyMessage(
    String clinicianName,
    String emergencyType,
    String patientName,
  ) {
    return 'Clinician $clinicianName has requested an ambulance for a $emergencyType case. Patient: $patientName. Be ready for dispatch.';
  }

  @override
  String get tapToViewCase => 'Tap to view case';

  @override
  String get latestDispatchRequest => 'Latest Dispatch Request';

  @override
  String get noNewDispatchRequests => 'No new dispatch requests';

  @override
  String get viewAllRequests => 'View All Requests';

  @override
  String get time => 'Time';
}
