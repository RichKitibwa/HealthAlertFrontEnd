// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Swahili (`sw`).
class AppLocalizationsSw extends AppLocalizations {
  AppLocalizationsSw([String locale = 'sw']) : super(locale);

  @override
  String get appTitle => 'Mfumo wa Afya ya Dharura';

  @override
  String get settings => 'Mipangilio';

  @override
  String get language => 'Lugha';

  @override
  String get account => 'Akaunti';

  @override
  String get preferences => 'Mapendeleo';

  @override
  String get app => 'Programu';

  @override
  String get about => 'Kuhusu';

  @override
  String get helpSupport => 'Msaada na Usaidizi';

  @override
  String get ok => 'Sawa';

  @override
  String get save => 'Hifadhi';

  @override
  String get cancel => 'Ghairi';

  @override
  String get submit => 'Wasilisha';

  @override
  String get confirm => 'Thibitisha';

  @override
  String get close => 'Funga';

  @override
  String get done => 'Imekamilika';

  @override
  String get name => 'Jina';

  @override
  String get role => 'Jukumu';

  @override
  String get phone => 'Simu';

  @override
  String get email => 'Barua pepe';

  @override
  String get specialtyProfession => 'Utaalamu / Kazi';

  @override
  String get assignedFacility => 'Kituo Kilichotolewa';

  @override
  String get settlementCamp => 'Makazi / Kambi';

  @override
  String get aboutMessage =>
      'HealthAlert\n\nToleo 1.0.0\n\nMawasiliano ya dharura kwa majibu ya afya ya mstari wa mbele.';

  @override
  String get failedToSaveLanguage => 'Imeshindwa kuhifadhi mapendeleo ya lugha';

  @override
  String get helpSupportComingSoon =>
      'Msaada na Usaidizi inakuja hivi karibuni';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageSwahili => 'Kiswahili';

  @override
  String get languageArabic => 'Kiarabu';

  @override
  String get changeLanguageConfirmTitle => 'Badilisha lugha?';

  @override
  String changeLanguageConfirmMessage(String language) {
    return 'Badilisha lugha kuwa $language? Programu itasasishwa mara moja.';
  }

  @override
  String languageChangedSuccess(String language) {
    return 'Lugha imebadilishwa kuwa $language';
  }

  @override
  String get dashboard => 'Dashibodi';

  @override
  String get notifications => 'Arifa';

  @override
  String get reports => 'Ripoti';

  @override
  String get analytics => 'Uchambuzi';

  @override
  String get logout => 'Ondoka';

  @override
  String get menu => 'Menyu';

  @override
  String get viewAll => 'Angalia Zote';

  @override
  String get searchByPatientNameOrId =>
      'Tafuta kwa jina au kitambulisho cha mgonjwa...';

  @override
  String get searchByPatientNameOrType =>
      'Tafuta kwa jina la mgonjwa au aina ya dharura...';

  @override
  String get searchByPatientNameIdOrType =>
      'Tafuta kwa jina, kitambulisho au aina ya mgonjwa...';

  @override
  String get searchByPatientVhtOrType => 'Tafuta kwa mgonjwa, VHT au aina...';

  @override
  String get searchUsers => 'Tafuta watumiaji...';

  @override
  String get tapToReview => 'Gusa kukagua';

  @override
  String get voiceNote => 'Noti ya sauti';

  @override
  String get reviewPatient => 'Kagua Mgonjwa';

  @override
  String get newEmergency => 'Dharura Mpya';

  @override
  String get reportEmergency => 'Ripoti Dharura';

  @override
  String get selectTypeOfEmergency => 'Chagua aina ya dharura';

  @override
  String get areaMap => 'Ramani ya Eneo';

  @override
  String get navigationMap => 'Ramani ya Uelekezi';

  @override
  String get birth => 'Uzazi';

  @override
  String get trauma => 'Jeraha';

  @override
  String get infection => 'Maambukizo';

  @override
  String get other => 'Nyingine';

  @override
  String get login => 'Ingia';

  @override
  String get welcomeBack => 'Karibu tena!';

  @override
  String get phoneNumber => 'Nambari ya Simu';

  @override
  String get pin => 'Nambari ya Siri';

  @override
  String get enterPin => 'Ingiza Nambari ya Siri';

  @override
  String get reenterPin => 'Ingiza tena Nambari ya Siri';

  @override
  String get setUpPin => 'Weka Nambari ya Siri';

  @override
  String get confirmPin => 'Thibitisha Nambari ya Siri';

  @override
  String get verifyPhoneNumber => 'Thibitisha Nambari ya Simu';

  @override
  String get verifyEmail => 'Thibitisha Barua pepe';

  @override
  String get getVerificationCode => 'Pata Msimbo wa Uthibitishaji';

  @override
  String get codeSentResend => 'Msimbo Umetumwa - Tuma Tena?';

  @override
  String get resendVerificationCode => 'Tuma Tena Msimbo wa Uthibitishaji';

  @override
  String get verificationCode => 'Msimbo wa Uthibitishaji';

  @override
  String get goBack => 'Rudi';

  @override
  String get goBackAndTryAgain => 'Rudi na jaribu tena';

  @override
  String get register => 'Jisajili';

  @override
  String get registerNewAccount => 'Jisajili akaunti mpya';

  @override
  String get alreadyHaveAccountLogin => 'Una akaunti? Ingia';

  @override
  String get forgotPinRegisterAgain =>
      'Umesahau Nambari ya Siri? Jisajili tena';

  @override
  String get vhtDetails => 'Maelezo ya VHT';

  @override
  String get ambulanceDriverDetails => 'Maelezo ya Dereva wa Ambulensi';

  @override
  String get adminDetails => 'Maelezo ya Msimamizi';

  @override
  String get clinicianDetails => 'Maelezo ya Kliniki';

  @override
  String get firstName => 'Jina la Kwanza';

  @override
  String get lastName => 'Jina la Mwisho';

  @override
  String get emailAddress => 'Barua pepe *';

  @override
  String get phoneNumberHint => '+256700000001';

  @override
  String get verificationCodeHint => '123456';

  @override
  String get adminVerificationCodeHint => '1234';

  @override
  String get emailHint => 'admin@example.com';

  @override
  String get iAmA => 'Mimi ni...';

  @override
  String get pinHelperText => 'Tarakimu 4-6';

  @override
  String get pleaseEnterPhoneNumber => 'Tafadhali ingiza nambari yako ya simu';

  @override
  String get pleaseEnterPin => 'Tafadhali ingiza nambari yako ya siri';

  @override
  String get pinMustBeDigits => 'Nambari ya siri lazima iwe tarakimu 4-6';

  @override
  String get incorrectPinTryAgain =>
      'Nambari ya siri si sahihi. Tafadhali jaribu tena.';

  @override
  String get userDataNotLoaded =>
      'Data ya mtumiaji haijapakiwa. Tafadhali jaribu tena.';

  @override
  String get noAccountFoundRegisterFirst =>
      'Hakuna akaunti iliyopatikana na nambari hii ya simu. Tafadhali jisajili kwanza.';

  @override
  String get errorLoadingUserData => 'Hitilafu katika kupakia data ya mtumiaji';

  @override
  String get pleaseEnterVerificationCode =>
      'Tafadhali ingiza msimbo wa uthibitishaji';

  @override
  String get loginSuccessful => 'Umefanikiwa kuingia!';

  @override
  String get verificationCodeSentToEmail =>
      'Msimbo wa uthibitishaji umetumwa kwa barua pepe yako';

  @override
  String get verificationCodeResentToEmail =>
      'Msimbo wa uthibitishaji umetumwa tena kwa barua pepe yako';

  @override
  String get pleaseEnterEmailAddress =>
      'Tafadhali ingiza anwani yako ya barua pepe';

  @override
  String get pleaseVerifyEmailFirst =>
      'Tafadhali thibitisha barua pepe yako kwanza kwa kubofya \"Pata Msimbo wa Uthibitishaji\"';

  @override
  String get failedToSendVerificationCode =>
      'Imeshindwa kutuma msimbo wa uthibitishaji';

  @override
  String get failedToResendCode => 'Imeshindwa kutuma tena msimbo';

  @override
  String get verificationFailed => 'Uthibitishaji umeshindwa';

  @override
  String get registrationFailed => 'Usajili umeshindwa';

  @override
  String get verificationError => 'Hitilafu ya uthibitishaji';

  @override
  String get phoneNumberMinDigits =>
      'Nambari ya simu lazima iwe angalau tarakimu 9';

  @override
  String get userExistsPleaseLogin =>
      'Mtumiaji na nambari hii ya simu tayari yupo. Tafadhali ingia.';

  @override
  String get pleaseEnterFirstName => 'Tafadhali ingiza jina lako la kwanza';

  @override
  String get pleaseEnterLastName => 'Tafadhali ingiza jina lako la mwisho';

  @override
  String get pleaseSelectProfession => 'Tafadhali chagua taaluma yako';

  @override
  String get pleaseSelectSettlementCamp =>
      'Tafadhali chagua makazi / kambi yako';

  @override
  String get pleaseSelectHealthFacility =>
      'Tafadhali chagua kituo chako cha afya';

  @override
  String welcomeBackDr(String name) {
    return 'Karibu tena, Dk. $name';
  }

  @override
  String welcomeBackName(String name) {
    return 'Karibu tena, $name';
  }

  @override
  String get user => 'Mtumiaji';

  @override
  String get vht => 'VHT';

  @override
  String get ambulance => 'Ambulensi';

  @override
  String get clinic => 'Kliniki';

  @override
  String get admin => 'Msimamizi';

  @override
  String get gender => 'Jinsia';

  @override
  String get age => 'Umri';

  @override
  String get enterAgeInYears => 'Ingiza umri kwa miaka';

  @override
  String get typeImportantNotes => 'Andika maelezo muhimu…';

  @override
  String get selectTriageLevel => 'Chagua kiwango cha uchambuzi';

  @override
  String get selectFacility => 'Chagua kituo…';

  @override
  String get pleaseSelectPatientGender => 'Tafadhali chagua jinsia ya mgonjwa.';

  @override
  String get pleaseEnterDobOrAge =>
      'Tafadhali ingiza tarehe ya kuzaliwa au umri wa mgonjwa.';

  @override
  String get pleaseSelectTriageLevel =>
      'Tafadhali chagua kiwango cha uchambuzi.';

  @override
  String get pleaseSelectHealthFacilityToNotify =>
      'Tafadhali chagua kituo cha afya cha kuarifu.';

  @override
  String get locationPermissionRequired => 'Ruhusa ya Mahali Inahitajika';

  @override
  String get pleaseEnableLocationInSettings =>
      'Tafadhali fungua Mipangilio na wezesha mahali kwa programu hii.';

  @override
  String get openSettings => 'Fungua Mipangilio';

  @override
  String get male => 'Mwanaume';

  @override
  String get female => 'Mwanamke';

  @override
  String get critical => 'Kritiki';

  @override
  String get high => 'Juu';

  @override
  String get moderate => 'Wastani';

  @override
  String get low => 'Chini';

  @override
  String get pleaseSelectAnotherFacilityOrContactSupervisor =>
      'Tafadhali chagua kituo kingine au wasiliana na msimamizi wako.';

  @override
  String warningFailedUploadMedia(String files) {
    return 'Onyo: Imeshindwa kupakia $files. Kesi itawasilishwa bila vyombo.';
  }

  @override
  String get warningMediaUploadFailed =>
      'Onyo: Upakiaji wa vyombo umeshindwa. Kesi itawasilishwa bila vyombo.';

  @override
  String get errorSubmittingCase => 'Hitilafu katika kuwasilisha kesi';

  @override
  String get retryLocationCapture => 'Jaribu Tena Kupata Mahali';

  @override
  String get failedToCaptureLocation =>
      'Imeshindwa kupata mahali. Tafadhali jaribu tena.';

  @override
  String get errorCreatingEmergencyCase =>
      'Hitilafu katika kuunda kesi ya dharura';

  @override
  String get sendFollowUpUpdate => 'Tuma Sasisho la Fuatilio';

  @override
  String get provideUpdateOnCondition =>
      'Toa sasisho juu ya hali ya sasa ya mgonjwa:';

  @override
  String get sendUpdate => 'Tuma Sasisho';

  @override
  String get followUpUpdateSentSuccessfully =>
      'Sasisho la fuatilio limetumwa kikamilifu.';

  @override
  String get failedToSendFollowUp => 'Imeshindwa kutuma sasisho la fuatilio';

  @override
  String get caseNotFound => 'Kesi haijapatikana.';

  @override
  String get noAdminContactFound => 'Mawasiliano ya msimamizi hayakupatikana.';

  @override
  String couldNotOpenDialer(String phone) {
    return 'Hakuweza kufungua simu kwa $phone';
  }

  @override
  String get errorFindingAdmin => 'Hitilafu katika kupata msimamizi';

  @override
  String get clinicianAdvice => 'Ushauri wa Kliniki';

  @override
  String get clinicianNotes => 'Maelezo ya Kliniki';

  @override
  String get callClinician => 'Piga Kliniki';

  @override
  String get callAmbulanceDriver => 'Piga Dereva wa Ambulensi';

  @override
  String get noContactsAvailableYet => 'Mawasiliano bado hayapo.';

  @override
  String get couldNotLoadImage => 'Hakuweza kupakia picha';

  @override
  String get tapImageToViewFullScreen => 'Gusa picha kuona ukubwa kamili';

  @override
  String get videoAttached => 'Video Imeshikamana';

  @override
  String get tapToPlayVideo => 'Gusa kucheza video';

  @override
  String get latestFollowUp => 'Fuatilio la Hivi Karibuni';

  @override
  String get needHelpWithDispatch => 'Unahitaji msaada wa kutuma?';

  @override
  String get contactAdminForDispatch =>
      'Wasiliana na msimamizi kuangalia hali ya kutuma.';

  @override
  String get callAdmin => 'Piga Msimamizi';

  @override
  String get message => 'Ujumbe';

  @override
  String get followUpHint => 'Mfano: Hali ya mgonjwa inazidi...';

  @override
  String get caseClosed => 'Kesi imefungwa.';

  @override
  String get pleaseAddNotesBeforeCallingClinic =>
      'Tafadhali ongeza maelezo kabla ya kupiga kliniki.';

  @override
  String get pendingReview => 'Inasubiri Ukaguzi';

  @override
  String get clinicianAdvised => 'Kliniki Imeshauri';

  @override
  String get ambulanceRequested => 'Ambulensi Iliombwa';

  @override
  String get ambulanceDispatched => 'Ambulensi Imetumwa';

  @override
  String get ambulanceEnRoute => 'Ambulensi Inaenda';

  @override
  String get ambulanceArrived => 'Ambulensi Imefika';

  @override
  String get patientInTransit => 'Mgonjwa Anasafiri';

  @override
  String get patientDelivered => 'Mgonjwa Amewasilishwa';

  @override
  String get inTreatment => 'Anapatiwa Matibabu';

  @override
  String get admitted => 'Amekubaliwa';

  @override
  String get discharged => 'Amesafirishwa';

  @override
  String get caseCompleted => 'Kesi Imekamilika';

  @override
  String get caseCancelled => 'Kesi Imefutwa';

  @override
  String get adviceSent => 'Ushauri Umetumwa';

  @override
  String get dispatched => 'Imetumwa';

  @override
  String get enRoute => 'Njiani';

  @override
  String get arrived => 'Imefika';

  @override
  String get awaitingStatusUpdate => 'Inasubiri sasisho la hali.';

  @override
  String get justNow => 'Sasa hivi';

  @override
  String minAgo(int n) {
    return 'Dakika $n zilizopita';
  }

  @override
  String hrAgo(int n) {
    return 'Saa $n zilizopita';
  }

  @override
  String get patientInformation => 'Maelezo ya Mgonjwa';

  @override
  String get reportingVht => 'VHT Anayeripoti';

  @override
  String get ambulanceDriver => 'Dereva wa Ambulensi';

  @override
  String get vhtNotes => 'Maelezo ya VHT';

  @override
  String get mediaFromVht => 'Vyombo kutoka VHT';

  @override
  String get attachments => 'Viambatanisho';

  @override
  String get treatmentNotesDischarge => 'Maelezo ya Matibabu na Kusafirisha';

  @override
  String get noMediaAttachedByVht => 'Hakuna vyombo vilivyoshikamana na VHT';

  @override
  String get viewAttachment => 'Angalia kiambatanisho';

  @override
  String get takeAction => 'Chukua Hatua';

  @override
  String get addNotesAndDecide =>
      'Ongeza maelezo na uamue kama kutuma ambulensi au kushauri VHT.';

  @override
  String get requestAmbulanceDispatch => 'Omba Kutuma Ambulensi';

  @override
  String get sendAdviceToVht => 'Tuma Ushauri kwa VHT';

  @override
  String get closeCasePatientOk => 'Funga Kesi (Mgonjwa Salama)';

  @override
  String get receivePatient => 'Pokee Mgonjwa';

  @override
  String get patientInTreatment => 'Mgonjwa Anapatiwa Matibabu';

  @override
  String get admitPatientInpatientOrDischarge =>
      'Kubali mgonjwa kwa matibabu ya ndani, au ongeza maelezo na msafirishe.';

  @override
  String get admitPatient => 'Kubali Mgonjwa';

  @override
  String get treatAndDischarge => 'Treat na Msafirishe';

  @override
  String get patientAdmitted => 'Mgonjwa Amekubaliwa';

  @override
  String get addTreatmentNotesAndDischarge =>
      'Ongeza maelezo ya matibabu na msafirishe unapokuwa tayari.';

  @override
  String get dischargePatient => 'Msafirishe Mgonjwa';

  @override
  String get dispatch => 'Tuma';

  @override
  String get closeCase => 'Funga Kesi';

  @override
  String get discharge => 'Safirisha';

  @override
  String get ambulanceDispatchRequested => 'Kutuma ambulensi kumeombwa.';

  @override
  String get pleaseAddAdviceForVhtFirst =>
      'Tafadhali ongeza ushauri kwa VHT kwanza.';

  @override
  String get adviceSentToVhtSuccessfully =>
      'Ushauri umetumwa kwa VHT kikamilifu.';

  @override
  String get caseClosedSuccessfully => 'Kesi imefungwa kikamilifu.';

  @override
  String get patientReceivedAddTreatmentNotes =>
      'Mgonjwa amepokelewa. Unaweza sasa kuongeza maelezo ya matibabu.';

  @override
  String get patientAdmittedAddNotesWhenReady =>
      'Mgonjwa amekubaliwa. Ongeza maelezo ya matibabu unapokuwa tayari kumsafirisha.';

  @override
  String get pleaseEnterTreatmentNotesBeforeDischarging =>
      'Tafadhali ingiza maelezo ya matibabu kabla ya kumsafirisha';

  @override
  String get patientDischargedCaseCompleted =>
      'Mgonjwa amesafirishwa. Kesi imekamilika.';

  @override
  String get couldNotOpenVideo => 'Hakuweza kufungua video';

  @override
  String get callVht => 'Piga VHT';

  @override
  String get callDriver => 'Piga Dereva';

  @override
  String get addNotesAdviceForVhtHint =>
      'Ongeza maelezo yako au ushauri kwa VHT...';

  @override
  String get treatmentNotesHint =>
      'Ingiza utambuzi, matibabu yaliyotolewa, dawa...';

  @override
  String get activeCases => 'Kesi Zinazoendelea';

  @override
  String get clinicNotifiedAboutArrival => 'Kliniki imearifiwa kuhusu kufika.';

  @override
  String get vhtNotifiedAboutArrival => 'VHT imearifiwa kuhusu kufika.';

  @override
  String failedToUpdateStatus(String error) {
    return 'Imeshindwa kusasisha hali: $error';
  }

  @override
  String couldNotLaunchDialer(String phone) {
    return 'Hakuweza kufungua simu kwa $phone';
  }

  @override
  String get errorAcceptingDispatch => 'Hitilafu katika kukubali kutuma';

  @override
  String get dispatchAmbulance => 'Tuma Ambulensi';

  @override
  String get userDetails => 'Maelezo ya Mtumiaji';

  @override
  String get cannotRemoveAdminUsers => 'Hawezi kuondoa watumiaji wa msimamizi';

  @override
  String get areYouSureRemoveUser =>
      'Una uhakika unataka kuondoa mtumiaji huyu?';

  @override
  String get userRemoved => 'Mtumiaji ameondolewa';

  @override
  String get failedToRemoveUser => 'Imeshindwa kuondoa mtumiaji';

  @override
  String get casesByType => 'Kesi kwa Aina';

  @override
  String get urgencyDistribution => 'Usambazaji wa Dharura';

  @override
  String get staffCoverage => 'Ufuniko wa Wafanyakazi';

  @override
  String get caseLoadByFacility => 'Mizigo ya Kesi kwa Kituo';

  @override
  String get rankedByTotalCasesAssigned =>
      'Yameorodheshwa kwa jumla ya kesi zilizotolewa';

  @override
  String get criticalUnresolvedCases => 'Kesi Muhimu Zisizotatuliwa';

  @override
  String get exportReports => 'Hamisha Ripoti';

  @override
  String get errorLoadingFacilityData =>
      'Hitilafu katika kupakia data ya kituo';

  @override
  String get noFacilityDataYet => 'Bado hakuna data ya kituo.';

  @override
  String get unassigned => 'Haijatolewa';

  @override
  String get viewAndManageOngoingCases =>
      'Tazama na simamia kesi zote zinazoendelea.';

  @override
  String get addOrRemoveSystemUsers => 'Ongeza au ondoa watumiaji wa mfumo.';

  @override
  String get manageUsers => 'Simamia Watumiaji';

  @override
  String get failedToGenerateReport => 'Imeshindwa kutengeneza ripoti';

  @override
  String get totalCases => 'Jumla ya Kesi';

  @override
  String get activeCasesCount => 'Kesi Zinazoendelea';

  @override
  String get completedCases => 'Kesi Zilizokamilika';

  @override
  String get ambulanceDispatchedSuccessfully =>
      'Ambulensi imetumwa kikamilifu.';

  @override
  String get pleaseSignInToViewNotifications => 'Tafadhali ingia kuona arifa';

  @override
  String get markAllRead => 'Alama Zote Kusomwa';

  @override
  String get failedToMarkAsRead => 'Imeshindwa kualama kama kusomwa';

  @override
  String get allNotificationsMarkedAsRead =>
      'Arifa zote zimealama kama kusomwa';

  @override
  String get failedToMarkAllAsRead => 'Imeshindwa kualama zote kama kusomwa';

  @override
  String get navigateWithGoogleMaps => 'Elekea na Google Maps';

  @override
  String get couldNotOpenGoogleMaps => 'Hakuweza kufungua Google Maps';

  @override
  String get ugandaClinicalGuidelines2023 =>
      'Miongozo ya Kliniki ya Uganda 2023';

  @override
  String get viewCaseHistory => 'Angalia Historia ya Kesi';

  @override
  String get learningResources => 'Rasilimali za Kujifunzia';

  @override
  String get pickImage => 'Chagua Picha';

  @override
  String get pickVideo => 'Chagua Video';

  @override
  String get pickFromGallery => 'Chagua kutoka galari';

  @override
  String get switchCamera => 'Badilisha kamera';

  @override
  String imageSizeExceedsMax(String size, String max) {
    return 'Ukubwa wa picha ($size KB) unazidi upeo ($max KB)';
  }

  @override
  String videoSizeExceedsMax(String size, String max) {
    return 'Ukubwa wa video ($size MB) unazidi upeo ($max MB)';
  }

  @override
  String get microphonePermissionRequired =>
      'Ruhusa ya kipaza sauti inahitajika kurekodi noti za sauti';

  @override
  String get errorStartingRecording => 'Hitilafu katika kuanza kurekodi';

  @override
  String get errorStoppingRecording => 'Hitilafu katika kusimamisha kurekodi';

  @override
  String get errorPlayingAudio => 'Hitilafu katika kucheza sauti';

  @override
  String get couldNotPlayVoiceNote => 'Hakuweza kucheza noti ya sauti';

  @override
  String get locationServicesDisabled =>
      'Huduma za mahali zimezima. Tafadhali wezesha GPS katika mipangilio ya kifaa chako.';

  @override
  String get locationPermissionDenied =>
      'Ruhusa ya mahali ilikataliwa. Tafadhali toa ufikiaji wa mahali ili kuripoti dharura.';

  @override
  String get locationPermissionPermanentlyDenied =>
      'Ruhusa ya mahali imekataliwa kabisa. Tafadhali fungua Mipangilio na wezesha mahali kwa programu hii.';

  @override
  String get couldNotGetLocation => 'Hakuweza kupata mahali';

  @override
  String get notificationNewEmergencyCase => 'Kesi Mpya ya Dharura';

  @override
  String notificationNewEmergencyCaseMessage(
    String emergencyType,
    String vhtName,
    String patientName,
    String urgency,
  ) {
    return 'Kesi mpya ya $emergencyType kutoka VHT $vhtName. Mgonjwa: $patientName. Dharura: $urgency. Tafadhali kagua mara moja.';
  }

  @override
  String get notificationCaseSubmittedSuccessfully =>
      'Kesi Imewasilishwa Kikamilifu';

  @override
  String notificationCaseSubmittedMessage(
    String emergencyType,
    String patientName,
    String clinicName,
  ) {
    return 'Kesi yako ya $emergencyType kwa $patientName imetumwa kwa $clinicName kukaguliwa.';
  }

  @override
  String get notificationVhtFollowUpUpdate => 'Sasisho la Fuatilio la VHT';

  @override
  String notificationVhtFollowUpMessage(
    String vhtName,
    String patientName,
    String message,
  ) {
    return '$vhtName amesasisha kuhusu $patientName: \"$message\"';
  }

  @override
  String get notificationClinicianAdviceReceived =>
      'Ushauri wa Kliniki Umepokelewa';

  @override
  String notificationClinicianAdviceMessage(
    String clinicianName,
    String patientName,
    String advice,
  ) {
    return 'Dk. $clinicianName amejibu kuhusu $patientName: \"$advice\"';
  }

  @override
  String get notificationAmbulanceDispatchRequired =>
      'Kutuma Ambulensi Kunahitajika';

  @override
  String get notificationAmbulanceOnTheWay => 'Ambulensi Inaenda';

  @override
  String notificationAmbulanceOnTheWayMessage(
    String driverName,
    String patientName,
  ) {
    return 'Ambulensi inayoendeshwa na $driverName imetumwa. Kaa na $patientName.';
  }

  @override
  String get notificationAmbulanceDispatched => 'Ambulensi Imetumwa';

  @override
  String notificationAmbulanceDispatchedMessage(
    String driverName,
    String emergencyType,
    String patientName,
  ) {
    return 'Dereva wa ambulensi $driverName ametumwa kwa kesi ya $emergencyType (Mgonjwa: $patientName).';
  }

  @override
  String get notificationNewDispatchAssignment => 'Mgawo Mpya wa Kutuma';

  @override
  String notificationNewDispatchMessage(
    String emergencyType,
    String vhtName,
    String clinicName,
    String patientName,
  ) {
    return 'Umepangiwa kesi ya $emergencyType. Kusanya mgonjwa kutoka VHT $vhtName, wasilisha kwa $clinicName. Mgonjwa: $patientName.';
  }

  @override
  String get notificationPatientDelivered => 'Mgonjwa Amewasilishwa';

  @override
  String notificationPatientDeliveredMessage(
    String patientName,
    String emergencyType,
    String clinicName,
    String driverName,
  ) {
    return 'Mgonjwa wako $patientName ($emergencyType) amewasilishwa salama kwa $clinicName na $driverName.';
  }

  @override
  String get notificationPatientArriving => 'Mgonjwa Anafika';

  @override
  String notificationPatientArrivingMessage(
    String patientName,
    String emergencyType,
    String driverName,
  ) {
    return 'Mgonjwa $patientName ($emergencyType) amewasilishwa na $driverName. Tafadhali pokea mgonjwa.';
  }

  @override
  String get notificationPatientDischarged => 'Mgonjwa Amesafirishwa';

  @override
  String notificationPatientDischargedMessage(
    String patientName,
    String emergencyType,
    String clinicName,
  ) {
    return 'Mgonjwa wako $patientName ($emergencyType) amepatwa na kusafirishwa kutoka $clinicName. Kesi imekamilika.';
  }

  @override
  String get notificationCaseCompleted => 'Kesi Imekamilika';

  @override
  String notificationCaseCompletedMessage(
    String patientName,
    String emergencyType,
    String clinicName,
    String clinicianName,
  ) {
    return '$patientName ($emergencyType) amesafirishwa kutoka $clinicName na Dk. $clinicianName. Kesi imefungwa.';
  }

  @override
  String get notificationCaseClosed => 'Kesi Imefungwa';

  @override
  String notificationCaseClosedMessage(
    String clinicianName,
    String patientName,
    String emergencyType,
  ) {
    return 'Dk. $clinicianName amethibitisha $patientName ($emergencyType) ni salama na amefunga kesi.';
  }

  @override
  String get notificationEmergencyAlerts => 'Arifa za Dharura';

  @override
  String get notificationEmergencyAlertsDescription =>
      'Arifa kwa kesi za dharura na sasisho za hali';

  @override
  String errorGeneric(String error) {
    return 'Hitilafu: $error';
  }

  @override
  String reportedBy(String name) {
    return 'Imeripotiwa na: $name';
  }

  @override
  String reportedAt(String time) {
    return 'Imeripotiwa: $time';
  }

  @override
  String get splashAppName => 'HealthAlert';

  @override
  String get splashTagline =>
      'Mawasiliano ya dharura kwa majibu ya afya ya mstari wa mbele';

  @override
  String get noNotificationsYet => 'Bado hakuna arifa';

  @override
  String get notificationsWillAppearHere => 'Arifa zitaonekana hapa';

  @override
  String get continueButton => 'Endelea';

  @override
  String get enterVerificationCode => 'Ingiza Msimbo wa Uthibitishaji';

  @override
  String weSentCodeTo(String phone) {
    return 'Tumetuma msimbo kwa $phone';
  }

  @override
  String get forTestNumbersEnter => 'Kwa nambari za majaribio, ingiza: 123456';

  @override
  String get verifyButton => 'Thibitisha';

  @override
  String get enterYourPinToContinue => 'Ingiza Nambari yako ya Siri kuendelea';

  @override
  String get verifyPinButton => 'Thibitisha Nambari ya Siri';

  @override
  String get setYourPin => 'Weka Nambari yako ya Siri';

  @override
  String get enterPinBetween4And6 =>
      'Ingiza Nambari ya Siri ya tarakimu 4 hadi 6';

  @override
  String get enterButton => 'Ingiza';

  @override
  String get pleaseEnterAPin => 'Tafadhali ingiza Nambari ya Siri';

  @override
  String get pleaseConfirmYourPin =>
      'Tafadhali thibitisha Nambari yako ya Siri';

  @override
  String get pinsDoNotMatch =>
      'Nambari za Siri hazilingani. Tafadhali jaribu tena.';

  @override
  String get confirmYourPin => 'Thibitisha Nambari yako ya Siri';

  @override
  String get pleaseReenterPinToConfirm =>
      'Tafadhali ingiza tena Nambari yako ya Siri kuthibitisha';

  @override
  String get homeLabel => 'Nyumbani';

  @override
  String get learnLabel => 'Jifunze';

  @override
  String get mapLabel => 'Ramani';

  @override
  String get incomingLabel => 'Inayokuja';

  @override
  String welcomeName(String name) {
    return 'Karibu, $name';
  }

  @override
  String get quickActions => 'Vitendo vya Haraka';

  @override
  String get ugandaClinicalGuidelinesDescription =>
      'Miongozo ya kitaifa ya kliniki kwa wafanyakazi wa afya nchini Uganda';

  @override
  String get patientIdLabel => 'Kitambulisho cha Mgonjwa';

  @override
  String get dateOfBirth => 'Tarehe ya Kuzaliwa';

  @override
  String get selectDateOfBirth => 'Chagua Tarehe ya Kuzaliwa';

  @override
  String ageYears(int n) {
    return 'Miaka $n';
  }

  @override
  String get notesLabel => 'Maelezo';

  @override
  String get patientDetailsHelp =>
      'Maelezo haya yatawasaidia wafanyakazi wa kliniki na ambulensi kujiandaa.';

  @override
  String get photoVideoOptional => 'Picha / Video (si lazima)';

  @override
  String noStaffAtFacility(String facility) {
    return 'Hakuna wafanyakazi waliyosajiliwa kwenye $facility. Tafadhali chagua kituo kingine au wasiliana na msimamizi wako.';
  }

  @override
  String get locationNeedsAccessMessage =>
      'HealthAlert inahitaji ruhusa ya mahali kuripoti dharura na kusaidia ambulensi kupata wagonjwa.\n\nTafadhali fungua Mipangilio na wezesha mahali kwa programu hii.';

  @override
  String get pendingOffline => 'Inasubiri (nje ya mtandao)';

  @override
  String get selectHealthFacility => 'Chagua Kituo cha Afya';

  @override
  String get chooseClinicForPatient =>
      'Chagua kliniki inayofaa zaidi kwa mgonjwa huyu.';

  @override
  String get notifyClinic => 'Arifu Kliniki';

  @override
  String get triageLevel => 'Kiwango cha Uainishaji';

  @override
  String get caseSubmitted => 'Kesi Imetumwa';

  @override
  String get clinicNotifiedOfEmergency => 'Kliniki imearifiwa kuhusu dharura.';

  @override
  String get currentStatus => 'Hali ya Sasa';

  @override
  String get returnToDashboard => 'Rudi kwa Dashibodi';

  @override
  String get reportAnotherEmergency => 'Ripoti Dharura Nyingine';

  @override
  String get caseTracking => 'Ufuatiliaji wa Kesi';

  @override
  String get assignedClinician => 'Daktari aliyepewa';

  @override
  String get savedOffline => 'Imehifadhiwa Nje ya Mtandao';

  @override
  String get caseSavedOfflineMessage =>
      'Data ya kesi imehifadhiwa ndani na itatumwa kwenye kliniki utakapokuwa mtandaoni.';

  @override
  String get lastUpdated => 'Imesasishwa mwisho';

  @override
  String get caseDetails => 'Maelezo ya Kesi';

  @override
  String get adviceProgress => 'Maendeleo ya Ushauri';

  @override
  String get caseProgress => 'Maendeleo ya Kesi';

  @override
  String get sending => 'Inatumwa...';

  @override
  String get caseHistory => 'Historia ya Kesi';

  @override
  String get allCases => 'Kesi Zote';

  @override
  String get allTypes => 'Aina Zote';

  @override
  String get activeFilter => 'Inayoendelea';

  @override
  String get allFilter => 'Zote';

  @override
  String get completedFilter => 'Imekamilika';

  @override
  String get errorLoadingCases => 'Hitilafu kupakia kesi';

  @override
  String get noActiveCases => 'Hakuna kesi zinazoendelea';

  @override
  String get noCompletedCases => 'Hakuna kesi zilizokamilika';

  @override
  String get noCasesFound => 'Hakuna kesi zilizopatikana';

  @override
  String get casesReportedAppearHere => 'Kesi unazoripoti zitaonekana hapa.';

  @override
  String get casesAssignedToYouAppearHere =>
      'Kesi zilizokupangiwa zitaonekana hapa.';

  @override
  String get clinicLabel => 'Kliniki';

  @override
  String get unknownClinic => 'Kliniki Isiyojulikana';

  @override
  String get unknown => 'Isiyojulikana';

  @override
  String get clinicianLabel => 'Daktari';

  @override
  String get contactSection => 'Mawasiliano';

  @override
  String get statusMsgPending => 'Daktari anakagua kesi yako.';

  @override
  String get statusMsgPendingSubmitted =>
      'Daktari anakagua kesi yako. Utawasilishwa wakati uamuzi utakapofanywa.';

  @override
  String get statusMsgAdvised =>
      'Daktari amekutumia ushauri. Tazama hapa chini.';

  @override
  String get statusMsgAmbRequested =>
      'Daktari ameomba ambulansi kwa mgonjwa huyu.';

  @override
  String get statusMsgDispatched => 'Ambulansi imetumwa mahali pako.';

  @override
  String get statusMsgDispatchedStay =>
      'Ambulansi imetumwa mahali pako. Kaa na mgonjwa.';

  @override
  String get statusMsgEnRoute => 'Ambulansi iko njiani.';

  @override
  String get statusMsgEnRoutePrepare =>
      'Ambulansi iko njiani. Andaa mgonjwa kusafirishwa.';

  @override
  String get statusMsgArrived => 'Ambulansi imefika.';

  @override
  String get statusMsgArrivedHandOver =>
      'Ambulansi imefika. Wasilisha mgonjwa kwa wafanyakazi wa ambulansi.';

  @override
  String get statusMsgInTransit => 'Mgonjwa anasafirishwa kwenye kliniki.';

  @override
  String get statusMsgDelivered => 'Mgonjwa amewasilishwa kwenye kliniki.';

  @override
  String get statusMsgInTreatment =>
      'Mgonjwa wako anasaguliwa sasa kwenye kliniki.';

  @override
  String get statusMsgAdmitted => 'Mgonjwa ameingia hospitalini';

  @override
  String get statusMsgDischarged => 'Mgonjwa amesafirishwa nje';

  @override
  String get statusMsgCompleted => 'Kesi hii imekamilika.';

  @override
  String get statusMsgCompletedTreated =>
      'Kesi hii imekamilika. Mgonjwa amesaguliwa.';

  @override
  String get statusMsgCancelled => 'Kesi hii imefutwa.';

  @override
  String get viewAllIncomingCases => 'Tazama Kesi Zote zinazoingia';

  @override
  String get needsYourReview => 'Inahitaji Mapitio yako';

  @override
  String get allCaughtUp => 'Umekamilika!';

  @override
  String get noCasesPendingReview =>
      'Hakuna kesi zinazosubiri mapitio yako sasa.';

  @override
  String get ambulanceEmergencyDispatch =>
      'Ambulansi — Usafirishaji wa Dharura';

  @override
  String get viewIncomingEmergencyRequests =>
      'Tazama maombi ya dharura yanayoingia kutoka kwa VHT na kliniki.';

  @override
  String get viewDispatch => 'Tazama Usafirishaji';

  @override
  String get viewActiveCases => 'Tazama Kesi Zinazoendelea';

  @override
  String get recentCases => 'Kesi za Hivi Karibuni';

  @override
  String get noRecentCases => 'Hakuna kesi za hivi karibuni';

  @override
  String get chooseWhatToManageToday => 'Chagua unachotaka kusimamia leo.';

  @override
  String get dispatchNeeded => 'Usafirishaji Unahitajika';

  @override
  String get dispatchLabel => 'Safirisha';

  @override
  String get analyticsSubtitle =>
      'Tazama usafirishaji wa ambulansi na maelezo ya ripoti za VHT.';

  @override
  String get manageUsersSubtitle => 'Ongeza au ondoa watumiaji wa mfumo.';

  @override
  String get caseSavedOfflineSyncWhenOnline =>
      'Kesi ya dharura imehifadhiwa nje ya mtandao. Itasawazishwa utakapokuwa mtandaoni.';

  @override
  String get emergencyCaseCreatedSuccessfully =>
      'Kesi ya dharura imeundwa kikamilifu!';

  @override
  String get dispatchConfirmation => 'Uthibitishaji wa Kusafirisha';

  @override
  String get clinicAssigned => 'Kliniki iliyopewa';

  @override
  String get estimatedArrival => 'Muda unaotarajiwa wa kufika';

  @override
  String get assigningNearestAmbulance =>
      'Inapeana ambulansi ya karibu kiotomatiki…';

  @override
  String get systemWillChooseClosestAmbulance =>
      'Mfumo utachagua ambulansi inayopatikana karibu zaidi na kusasisha skrini hii kwa wakati halisi.';

  @override
  String get emergencyTypeLabel => 'Aina ya dharura';

  @override
  String get confirmAndDispatch => 'Thibitisha na Kutuma';

  @override
  String get setLocation => 'Weka Mahali';

  @override
  String get automaticallyCapturingLocation => 'Inapata mahali kiotomatiki…';

  @override
  String get locationCaptureHelp =>
      'Hii itasaidia wakuja kukupata haraka.\nHakuna haja ya kusogeza ramani au kuweka alama ya mahali.';

  @override
  String clinicAssignedWithName(String name) {
    return 'Kliniki iliyopewa: $name';
  }

  @override
  String estimatedArrivalValue(String eta) {
    return 'Muda unaotarajiwa wa kufika: $eta';
  }

  @override
  String locationCoordinates(String lat, String lng) {
    return 'Mahali: $lat, $lng';
  }

  @override
  String get trackAmbulance => 'Fuatilia Ambulansi';

  @override
  String get mapPlaceholder => 'Kibaonyesho cha Ramani';

  @override
  String get notifyClinicPatientOnboard => 'Arifu kliniki mgonjwa ameshuka';

  @override
  String get clinicNotifiedPatientOnboard =>
      'Kliniki imearifiwa kuwa mgonjwa ameshuka.';

  @override
  String get caseClosedButton => 'Kesi Imefungwa';

  @override
  String get onboardPatient => 'Mgonjwa Ameingia';

  @override
  String get callingClinicToDiscuss =>
      'Inapiga kliniki kujadili kama ambulansi inahitajika...';

  @override
  String get callClinicToDiscussCase => 'Piga kliniki kujadili kesi';

  @override
  String get continueToDispatchAmbulance => 'Endelea kutuma ambulansi';

  @override
  String errorCreatingEmergencyCaseWithError(String error) {
    return 'Hitilafu katika kuunda kesi ya dharura: $error';
  }

  @override
  String get incomingCases => 'Kesi Zinazoingia';

  @override
  String get reviewEmergenciesSubmittedByVhts =>
      'Kagua dharura zilizowasilishwa na VHT.';

  @override
  String get emergencyCasesAssignedToYourClinic =>
      'Kesi za dharura zilizopangiwa kwa kliniki yako zitaonekana hapa.';

  @override
  String get patientLabel => 'Mgonjwa';

  @override
  String get requestAmbulanceDispatchConfirm =>
      'Hii itaelekeza kesi kwa usafirishaji kugawa ambulansi. Unataka kuendelea?';

  @override
  String get patientReceived => 'Mgonjwa Amepokelewa';

  @override
  String get proceed => 'Endelea';

  @override
  String get caseSummary => 'Muhtasari wa Kesi';

  @override
  String get patientArrival => 'Mgonjwa Amefika';

  @override
  String get assignStaff => 'Gawa Wafanyakazi';

  @override
  String get ambulanceTracking => 'Ufuatiliaji wa Ambulansi';

  @override
  String get activeCasesTitle => 'Kesi Zinazoendelea';

  @override
  String get allIncomingRequests => 'Maombi Yote Yanayoingia';

  @override
  String get incomingDispatch => 'Usafirishaji Unaokuja';

  @override
  String get arrival => 'Kufika';

  @override
  String get caseClosure => 'Kufunga Kesi';

  @override
  String get adminHome => 'Nyumbani';

  @override
  String get adminCases => 'Kesi';

  @override
  String get adminAnalytics => 'Uchambuzi';

  @override
  String get adminUsers => 'Watumiaji';

  @override
  String get caseDashboard => 'Dashibodi ya Kesi';

  @override
  String get caseAnalytics => 'Uchambuzi wa Kesi';

  @override
  String get manageUsersScreen => 'Simamia Watumiaji';

  @override
  String get userDetail => 'Maelezo ya Mtumiaji';

  @override
  String get caseTimeline => 'Muda wa Kesi';

  @override
  String get allCasesList => 'Orodha ya Kesi Zote';

  @override
  String get reportsExport => 'Hamisha Ripoti';

  @override
  String get vhtDetailsForm => 'Maelezo ya VHT';

  @override
  String get clinicianRegistrationForm => 'Usajili wa Kliniki';

  @override
  String get adminDetailsForm => 'Maelezo ya Msimamizi';

  @override
  String get ambulanceDriverDetailsForm => 'Maelezo ya Dereva wa Ambulansi';

  @override
  String get adminEmailOtpScreen => 'Uthibitishaji wa Barua pepe ya Msimamizi';

  @override
  String get registrationForm => 'Usajili';

  @override
  String get fullScreenCamera => 'Kamera';

  @override
  String get voiceNoteWidget => 'Noti ya sauti';

  @override
  String get locationRequestTimeout => 'Ombi la mahali limesubiri muda mrefu';

  @override
  String couldNotGetLocationWithError(String error) {
    return 'Hakuweza kupata mahali: $error';
  }

  @override
  String get reviewMediaTriageNextActions =>
      'Kagua vyombo, kiwango cha uchambuzi na hatua zinazofuata kwa dharura hii.';

  @override
  String get photoVoiceNotePreview => 'Onyesho la Picha / Noti ya Sauti';

  @override
  String get triageLevelHighRed => 'Kiwango cha Uchambuzi: Juu (Nyekundu)';

  @override
  String get seeStaff => 'Tazama Wafanyakazi';

  @override
  String get requestAdditionalInfo => 'Omba Maelezo Zaidi';

  @override
  String get callingVhtPlaceholder => 'Inapiga VHT (kibaonyesho)...';

  @override
  String get callingAmbulancePlaceholder =>
      'Inapiga ambulansi (kibaonyesho)...';

  @override
  String get confirmStaffAssignmentCloseCase =>
      'Thibitisha mgawanyo wa wafanyakazi na fungua kesi mara mgonjwa apokelewe.';

  @override
  String get emergencyLabel => 'Dharura';

  @override
  String get staffAssigned => 'Wafanyakazi wamegawiwa';

  @override
  String get patientReceivedCloseCase => 'Mgonjwa Amepokelewa / Fungua Kesi';

  @override
  String get confirmPersonnelEquipment =>
      'Thibitisha wafanyakazi waliopo na vifaa vinavyohitajika kwa kesi hii.';

  @override
  String get nurseAvailable => 'Nesi: Inapatikana';

  @override
  String get clinicianAvailable => 'Daktari: Inapatikana';

  @override
  String get checklistDeliveryKit =>
      'Orodha: Kifurushi cha Uwasilishaji, Kifurushi cha Jeraha, PPE';

  @override
  String get confirmStaff => 'Thibitisha Wafanyakazi';

  @override
  String get trackAmbulanceEtaStatus =>
      'Fuatilia ambulansi iliyopewa muda wa kufika na hali ya kesi hii.';

  @override
  String get mapEtaPlaceholder => 'Kibaonyesho cha Ramani / Muda wa Kufika';

  @override
  String get onTime => 'Kwa Muda';

  @override
  String get incomingDispatchRequests => 'Maombi ya Usafirishaji Yanayoingia';

  @override
  String get acceptDispatchToStart => 'Kubali usafirishaji kuanza safari yako.';

  @override
  String get errorLoadingRequests => 'Hitilafu kupakia maombi';

  @override
  String get noIncomingRequests => 'Hakuna maombi yanayoingia';

  @override
  String get dispatchedCasesAppearHere => 'Kesi zilizotumwa zitaonekana hapa.';

  @override
  String get dispatchRequest => 'Ombi la Kusafirisha';

  @override
  String get emergencyDispatch => 'Usafirishaji wa Dharura';

  @override
  String get reviewDetailsAcceptProceed =>
      'Kagua maelezo, kisha kubali kuendelea.';

  @override
  String get emergencyType => 'Aina ya Dharura';

  @override
  String get destination => 'Lengo';

  @override
  String get quickContact => 'Mawasiliano ya Haraka';

  @override
  String get callClinic => 'Piga Kliniki';

  @override
  String get acceptDispatch => 'Kubali Kusafirisha';

  @override
  String get toBeDetermined => 'Haijabainishwa';

  @override
  String statusUpdatedTo(String status) {
    return 'Hali imesasishwa kuwa $status';
  }

  @override
  String get arrivedAtScene => 'Imefika Mahali';

  @override
  String get arrivedAtVht => 'Imefika kwa VHT';

  @override
  String get deliveredToClinic => 'Imewasilishwa Klinikini';

  @override
  String get patientPickedUp => 'Mgonjwa Amechukuliwa';

  @override
  String get patientDeliveredSuccessfully => 'Mgonjwa Amewasilishwa Kikamilifu';

  @override
  String get deliveryCompleteClinicHandles =>
      'Usafirishaji wako umekamilika. Kliniki itamudu mgonjwa hapa.';

  @override
  String get sortByTime => 'Panga kwa muda';

  @override
  String get sortBySeverity => 'Panga kwa ukali';

  @override
  String get sortByStatus => 'Panga kwa hali';

  @override
  String get viewAndManageSystemUsers =>
      'Tazama na simamia watumiaji wa mfumo kwa jukumu.';

  @override
  String get noUsersFound => 'Hakuna watumiaji waliopatikana';

  @override
  String get unknownUser => 'Mtumiaji Asiyejulikana';

  @override
  String get tapToPlay => 'Gusa kucheza';

  @override
  String get tapToOpenCamera => 'Gusa kufungua kamera';

  @override
  String get notificationFallbackTitle => 'Arifa';

  @override
  String get locationPermissionDeniedForever =>
      'Ruhusa ya mahali imekataliwa kabisa. Fungua Mipangilio na wezesha mahali kwa programu hii.';

  @override
  String get locationUnknownError => 'Hakuweza kupata mahali';

  @override
  String get tapToRecordVoiceNote => 'Gusa kurekodi noti ya sauti';

  @override
  String get voiceNoteOptional => 'Noti ya Sauti (si lazima)';

  @override
  String recordingWithDuration(String duration) {
    return 'Inarekodi: $duration';
  }

  @override
  String get arrivedPatients => 'Wagonjwa Waliowasili';

  @override
  String get noPatientsArrivedYet => 'Hakuna wagonjwa waliowasili bado';

  @override
  String get patientsWillAppearHereOnceDelivered =>
      'Wagonjwa wataonekana hapa utakapowasilishwa na ambulansi.';

  @override
  String get notSpecified => 'Haijabainishwa';

  @override
  String get idLabel => 'Kitambulisho';

  @override
  String get patientInfo => 'Maelezo ya mgonjwa';

  @override
  String get patientOnboard => 'Mgonjwa ameingia';

  @override
  String get inTreatmentStatus => 'ANAPATIWA MATIBABU';

  @override
  String get deliveredStatus => 'AMEWASILISHWA';

  @override
  String get resolutionRate => 'Kiwango cha Uamuzi';

  @override
  String get doneLabel => 'Imekamilika';

  @override
  String get resolutionLabel => 'Uamuzi';

  @override
  String get adultFemale => 'Mwanamke Mzima';

  @override
  String get unknownPatient => 'Mgonjwa asiyejulikana';

  @override
  String yearsShort(int n) {
    return 'Miaka $n';
  }

  @override
  String get yourNotes => 'Maelezo Yako';

  @override
  String get yourAdviceToVht => 'Ushauri Wako kwa VHT';

  @override
  String get youAdvisedVhtCloseCase =>
      'Umemshauri VHT. Mgonjwa akiwa salama, fungua kesi.';

  @override
  String get patientDeliveredReceiveNow =>
      'Mgonjwa amewasilishwa klinikini. Pokee mgonjwa kuanza matibabu.';

  @override
  String get dispatching => 'Inatumwa...';

  @override
  String get progressTimeline => 'Muda wa Maendeleo';

  @override
  String get reviewEventsForCase => 'Kagua matukio ya kesi hii ya dharura.';

  @override
  String get liveMapCachedOffline =>
      'Ramani hai · Vipande vimehifadhiwa kwa matumizi nje ya mtandao';

  @override
  String get gettingYourLocation => 'Inapata mahali pako...';

  @override
  String get openNavigationMap => 'Fungua Ramani ya Uelekezi';

  @override
  String get backToDashboard => 'Rudi kwa Dashibodi';

  @override
  String get vhtPhoneNotAvailable => 'Nambari ya simu ya VHT haipatikani';

  @override
  String get clinicianPhoneNotAvailable =>
      'Nambari ya simu ya daktari haipatikani';

  @override
  String urgencyWithLevel(String level) {
    return 'Dharura: $level';
  }

  @override
  String get areYouSureCloseCasePatientOk =>
      'Una uhakika mgonjwa ni salama na kesi hii inaweza kufungwa?';

  @override
  String get closeCaseConfirmTitle => 'Funga Kesi';

  @override
  String get dischargePatientConfirmMsg =>
      'Hii itaonyesha mgonjwa amesafirishwa na kufunga kesi hii. Una uhakika?';

  @override
  String get errorLoadingCaseData => 'Hitilafu kupakia data ya kesi';

  @override
  String get callsLabel => 'Simu';

  @override
  String get notificationAmbulanceRequestStandby =>
      'Ombi la Ambulansi — Subiri';

  @override
  String notificationAmbulanceRequestStandbyMessage(
    String clinicianName,
    String emergencyType,
    String patientName,
  ) {
    return 'Daktari $clinicianName ameomba ambulansi kwa kesi ya $emergencyType. Mgonjwa: $patientName. Jiandae kwa kutuma.';
  }

  @override
  String get tapToViewCase => 'Gusa kuona kesi';

  @override
  String get latestDispatchRequest => 'Ombi la Hivi Karibuni la Kutuma';

  @override
  String get noNewDispatchRequests => 'Hakuna maombi mapya ya kutuma';

  @override
  String get viewAllRequests => 'Tazama Maombi Yote';

  @override
  String get time => 'Wakati';
}
