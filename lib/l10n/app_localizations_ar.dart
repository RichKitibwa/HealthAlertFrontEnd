// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'نظام الطوارئ الصحية';

  @override
  String get settings => 'الإعدادات';

  @override
  String get language => 'اللغة';

  @override
  String get account => 'الحساب';

  @override
  String get preferences => 'التفضيلات';

  @override
  String get app => 'التطبيق';

  @override
  String get about => 'حول';

  @override
  String get helpSupport => 'المساعدة والدعم';

  @override
  String get ok => 'موافق';

  @override
  String get save => 'حفظ';

  @override
  String get cancel => 'إلغاء';

  @override
  String get submit => 'إرسال';

  @override
  String get confirm => 'تأكيد';

  @override
  String get close => 'إغلاق';

  @override
  String get done => 'تم';

  @override
  String get name => 'الاسم';

  @override
  String get role => 'الدور';

  @override
  String get phone => 'الهاتف';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get specialtyProfession => 'التخصص / المهنة';

  @override
  String get assignedFacility => 'المنشأة المعينة';

  @override
  String get settlementCamp => 'المستوطنة / المخيم';

  @override
  String get aboutMessage =>
      'HealthAlert\n\nالإصدار 1.0.0\n\nالتواصل في حالات الطوارئ للاستجابة الصحية في الخطوط الأمامية.';

  @override
  String get failedToSaveLanguage => 'فشل في حفظ تفضيل اللغة';

  @override
  String get helpSupportComingSoon => 'المساعدة والدعم قريباً';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageSwahili => 'السواحيلية';

  @override
  String get languageArabic => 'العربية';

  @override
  String get changeLanguageConfirmTitle => 'تغيير اللغة؟';

  @override
  String changeLanguageConfirmMessage(String language) {
    return 'تغيير اللغة إلى $language؟ سيتم تحديث التطبيق فوراً.';
  }

  @override
  String languageChangedSuccess(String language) {
    return 'تم تغيير اللغة إلى $language';
  }

  @override
  String get dashboard => 'لوحة التحكم';

  @override
  String get notifications => 'الإشعارات';

  @override
  String get reports => 'التقارير';

  @override
  String get analytics => 'التحليلات';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get menu => 'القائمة';

  @override
  String get viewAll => 'عرض الكل';

  @override
  String get searchByPatientNameOrId => 'البحث باسم المريض أو المعرّف...';

  @override
  String get searchByPatientNameOrType => 'البحث باسم المريض أو نوع الطوارئ...';

  @override
  String get searchByPatientNameIdOrType =>
      'البحث باسم المريض أو المعرّف أو النوع...';

  @override
  String get searchByPatientVhtOrType => 'البحث بالمريض أو VHT أو النوع...';

  @override
  String get searchUsers => 'البحث عن المستخدمين...';

  @override
  String get tapToReview => 'اضغط للمراجعة';

  @override
  String get voiceNote => 'مذكرة صوتية';

  @override
  String get reviewPatient => 'مراجعة المريض';

  @override
  String get newEmergency => 'طوارئ جديدة';

  @override
  String get reportEmergency => 'الإبلاغ عن طوارئ';

  @override
  String get selectTypeOfEmergency => 'اختر نوع الطوارئ';

  @override
  String get areaMap => 'خريطة المنطقة';

  @override
  String get navigationMap => 'خريطة الملاحة';

  @override
  String get birth => 'ولادة';

  @override
  String get trauma => 'رضح';

  @override
  String get infection => 'عدوى';

  @override
  String get other => 'أخرى';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get welcomeBack => 'مرحباً بعودتك!';

  @override
  String get phoneNumber => 'رقم الهاتف';

  @override
  String get pin => 'رمز PIN';

  @override
  String get enterPin => 'أدخل رمز PIN';

  @override
  String get reenterPin => 'أعد إدخال رمز PIN';

  @override
  String get setUpPin => 'إعداد رمز PIN';

  @override
  String get confirmPin => 'تأكيد رمز PIN';

  @override
  String get verifyPhoneNumber => 'التحقق من رقم الهاتف';

  @override
  String get verifyEmail => 'التحقق من البريد الإلكتروني';

  @override
  String get getVerificationCode => 'الحصول على رمز التحقق';

  @override
  String get codeSentResend => 'تم إرسال الرمز - إعادة الإرسال؟';

  @override
  String get resendVerificationCode => 'إعادة إرسال رمز التحقق';

  @override
  String get verificationCode => 'رمز التحقق';

  @override
  String get goBack => 'رجوع';

  @override
  String get goBackAndTryAgain => 'ارجع وحاول مرة أخرى';

  @override
  String get register => 'التسجيل';

  @override
  String get registerNewAccount => 'تسجيل حساب جديد';

  @override
  String get alreadyHaveAccountLogin => 'لديك حساب؟ سجّل الدخول';

  @override
  String get forgotPinRegisterAgain => 'نسيت رمز PIN؟ سجّل من جديد';

  @override
  String get vhtDetails => 'تفاصيل فريق صحة القرية';

  @override
  String get ambulanceDriverDetails => 'تفاصيل سائق الإسعاف';

  @override
  String get adminDetails => 'تفاصيل المسؤول';

  @override
  String get clinicianDetails => 'تفاصيل الطبيب';

  @override
  String get firstName => 'الاسم الأول';

  @override
  String get lastName => 'اسم العائلة';

  @override
  String get emailAddress => 'البريد الإلكتروني *';

  @override
  String get phoneNumberHint => '+256700000001';

  @override
  String get verificationCodeHint => '123456';

  @override
  String get adminVerificationCodeHint => '1234';

  @override
  String get emailHint => 'admin@example.com';

  @override
  String get iAmA => 'أنا...';

  @override
  String get pinHelperText => '4-6 أرقام';

  @override
  String get pleaseEnterPhoneNumber => 'يرجى إدخال رقم هاتفك';

  @override
  String get pleaseEnterPin => 'يرجى إدخال رمز PIN';

  @override
  String get pinMustBeDigits => 'يجب أن يكون رمز PIN من 4 إلى 6 أرقام';

  @override
  String get incorrectPinTryAgain =>
      'رمز PIN غير صحيح. يرجى المحاولة مرة أخرى.';

  @override
  String get userDataNotLoaded =>
      'لم يتم تحميل بيانات المستخدم. يرجى المحاولة مرة أخرى.';

  @override
  String get noAccountFoundRegisterFirst =>
      'لم يتم العثور على حساب بهذا الرقم. يرجى التسجيل أولاً.';

  @override
  String get errorLoadingUserData => 'خطأ في تحميل بيانات المستخدم';

  @override
  String get pleaseEnterVerificationCode => 'يرجى إدخال رمز التحقق';

  @override
  String get loginSuccessful => 'تم تسجيل الدخول بنجاح!';

  @override
  String get verificationCodeSentToEmail =>
      'تم إرسال رمز التحقق إلى بريدك الإلكتروني';

  @override
  String get verificationCodeResentToEmail =>
      'تم إعادة إرسال رمز التحقق إلى بريدك الإلكتروني';

  @override
  String get pleaseEnterEmailAddress => 'يرجى إدخال بريدك الإلكتروني';

  @override
  String get pleaseVerifyEmailFirst =>
      'يرجى التحقق من بريدك أولاً بالنقر على \"الحصول على رمز التحقق\"';

  @override
  String get failedToSendVerificationCode => 'فشل إرسال رمز التحقق';

  @override
  String get failedToResendCode => 'فشل إعادة إرسال الرمز';

  @override
  String get verificationFailed => 'فشل التحقق';

  @override
  String get registrationFailed => 'فشل التسجيل';

  @override
  String get verificationError => 'خطأ في التحقق';

  @override
  String get phoneNumberMinDigits => 'يجب أن يكون رقم الهاتف 9 أرقام على الأقل';

  @override
  String get userExistsPleaseLogin =>
      'يوجد بالفعل مستخدم بهذا الرقم. يرجى تسجيل الدخول.';

  @override
  String get pleaseEnterFirstName => 'يرجى إدخال اسمك الأول';

  @override
  String get pleaseEnterLastName => 'يرجى إدخال اسم العائلة';

  @override
  String get pleaseSelectProfession => 'يرجى اختيار مهنتك';

  @override
  String get pleaseSelectSettlementCamp => 'يرجى اختيار المستوطنة / المخيم';

  @override
  String get pleaseSelectHealthFacility => 'يرجى اختيار منشأتك الصحية';

  @override
  String welcomeBackDr(String name) {
    return 'مرحباً بعودتك، د. $name';
  }

  @override
  String welcomeBackName(String name) {
    return 'مرحباً بعودتك، $name';
  }

  @override
  String get user => 'المستخدم';

  @override
  String get vht => 'فريق صحة القرية';

  @override
  String get ambulance => 'الإسعاف';

  @override
  String get clinic => 'العيادة';

  @override
  String get admin => 'المسؤول';

  @override
  String get gender => 'الجنس';

  @override
  String get age => 'العمر';

  @override
  String get enterAgeInYears => 'أدخل العمر بالسنوات';

  @override
  String get typeImportantNotes => 'اكتب أي ملاحظات مهمة…';

  @override
  String get selectTriageLevel => 'اختر مستوى الفرز';

  @override
  String get selectFacility => 'اختر منشأة…';

  @override
  String get pleaseSelectPatientGender => 'يرجى اختيار جنس المريض.';

  @override
  String get pleaseEnterDobOrAge => 'يرجى إدخال تاريخ ميلاد المريض أو عمره.';

  @override
  String get pleaseSelectTriageLevel => 'يرجى اختيار مستوى الفرز.';

  @override
  String get pleaseSelectHealthFacilityToNotify =>
      'يرجى اختيار المنشأة الصحية للإبلاغ.';

  @override
  String get locationPermissionRequired => 'إذن الموقع مطلوب';

  @override
  String get pleaseEnableLocationInSettings =>
      'يرجى فتح الإعدادات وتمكين الموقع لهذا التطبيق.';

  @override
  String get openSettings => 'فتح الإعدادات';

  @override
  String get male => 'ذكر';

  @override
  String get female => 'أنثى';

  @override
  String get critical => 'حرج';

  @override
  String get high => 'عالي';

  @override
  String get moderate => 'متوسط';

  @override
  String get low => 'منخفض';

  @override
  String get pleaseSelectAnotherFacilityOrContactSupervisor =>
      'يرجى اختيار منشأة أخرى أو الاتصال بالمشرف.';

  @override
  String warningFailedUploadMedia(String files) {
    return 'تحذير: فشل تحميل $files. سيتم إرسال الحالة دون الوسائط.';
  }

  @override
  String get warningMediaUploadFailed =>
      'تحذير: فشل تحميل الوسائط. سيتم إرسال الحالة دون الوسائط.';

  @override
  String get errorSubmittingCase => 'خطأ في إرسال الحالة';

  @override
  String get retryLocationCapture => 'إعادة محاولة التقاط الموقع';

  @override
  String get failedToCaptureLocation =>
      'فشل التقاط الموقع. يرجى المحاولة مرة أخرى.';

  @override
  String get errorCreatingEmergencyCase => 'خطأ في إنشاء حالة الطوارئ';

  @override
  String get sendFollowUpUpdate => 'إرسال تحديث المتابعة';

  @override
  String get provideUpdateOnCondition => 'قدم تحديثاً عن حالة المريض الحالية:';

  @override
  String get sendUpdate => 'إرسال التحديث';

  @override
  String get followUpUpdateSentSuccessfully => 'تم إرسال تحديث المتابعة بنجاح.';

  @override
  String get failedToSendFollowUp => 'فشل إرسال المتابعة';

  @override
  String get caseNotFound => 'الحالة غير موجودة.';

  @override
  String get noAdminContactFound => 'لم يتم العثور على جهة اتصال المسؤول.';

  @override
  String couldNotOpenDialer(String phone) {
    return 'تعذر فتح تطبيق الاتصال لـ $phone';
  }

  @override
  String get errorFindingAdmin => 'خطأ في العثور على المسؤول';

  @override
  String get clinicianAdvice => 'نصيحة الطبيب';

  @override
  String get clinicianNotes => 'ملاحظات الطبيب';

  @override
  String get callClinician => 'الاتصال بالطبيب';

  @override
  String get callAmbulanceDriver => 'الاتصال بسائق الإسعاف';

  @override
  String get noContactsAvailableYet => 'لا توجد جهات اتصال متاحة بعد.';

  @override
  String get couldNotLoadImage => 'تعذر تحميل الصورة';

  @override
  String get tapImageToViewFullScreen => 'اضغط على الصورة لعرضها بالكامل';

  @override
  String get videoAttached => 'فيديو مرفق';

  @override
  String get tapToPlayVideo => 'اضغط لتشغيل الفيديو';

  @override
  String get latestFollowUp => 'أحدث متابعة';

  @override
  String get needHelpWithDispatch => 'تحتاج مساعدة في الإرسال؟';

  @override
  String get contactAdminForDispatch =>
      'تواصل مع المسؤول للتحقق من حالة الإرسال.';

  @override
  String get callAdmin => 'الاتصال بالمسؤول';

  @override
  String get message => 'الرسالة';

  @override
  String get followUpHint => 'مثال: حالة المريض تزداد سوءاً...';

  @override
  String get caseClosed => 'الحالة مغلقة.';

  @override
  String get pleaseAddNotesBeforeCallingClinic =>
      'يرجى إضافة ملاحظات قبل الاتصال بالعيادة.';

  @override
  String get pendingReview => 'قيد المراجعة';

  @override
  String get clinicianAdvised => 'الطبيب قد أشار';

  @override
  String get ambulanceRequested => 'تم طلب الإسعاف';

  @override
  String get ambulanceDispatched => 'تم إرسال الإسعاف';

  @override
  String get ambulanceEnRoute => 'الإسعاف في الطريق';

  @override
  String get ambulanceArrived => 'وصل الإسعاف';

  @override
  String get patientInTransit => 'المريض في الطريق';

  @override
  String get patientDelivered => 'تم تسليم المريض';

  @override
  String get inTreatment => 'قيد العلاج';

  @override
  String get admitted => 'تم قبوله';

  @override
  String get discharged => 'تم تسريحه';

  @override
  String get caseCompleted => 'اكتملت الحالة';

  @override
  String get caseCancelled => 'تم إلغاء الحالة';

  @override
  String get adviceSent => 'تم إرسال النصيحة';

  @override
  String get dispatched => 'تم الإرسال';

  @override
  String get enRoute => 'في الطريق';

  @override
  String get arrived => 'وصل';

  @override
  String get awaitingStatusUpdate => 'في انتظار تحديث الحالة.';

  @override
  String get justNow => 'الآن';

  @override
  String minAgo(int n) {
    return 'منذ $n دقيقة';
  }

  @override
  String hrAgo(int n) {
    return 'منذ $n ساعة';
  }

  @override
  String get patientInformation => 'معلومات المريض';

  @override
  String get reportingVht => 'فريق صحة القرية المُبلّغ';

  @override
  String get ambulanceDriver => 'سائق الإسعاف';

  @override
  String get vhtNotes => 'ملاحظات فريق صحة القرية';

  @override
  String get mediaFromVht => 'وسائط من فريق صحة القرية';

  @override
  String get attachments => 'المرفقات';

  @override
  String get treatmentNotesDischarge => 'ملاحظات العلاج والتسريح';

  @override
  String get noMediaAttachedByVht => 'لا توجد وسائط مرفقة من فريق صحة القرية';

  @override
  String get viewAttachment => 'عرض المرفق';

  @override
  String get takeAction => 'اتخذ إجراءً';

  @override
  String get addNotesAndDecide =>
      'أضف ملاحظات وقرر إرسال إسعاف أو إسداء النصيحة لفريق صحة القرية.';

  @override
  String get requestAmbulanceDispatch => 'طلب إرسال الإسعاف';

  @override
  String get sendAdviceToVht => 'إرسال النصيحة لفريق صحة القرية';

  @override
  String get closeCasePatientOk => 'إغلاق الحالة (المريض بخير)';

  @override
  String get receivePatient => 'استلام المريض';

  @override
  String get patientInTreatment => 'المريض قيد العلاج';

  @override
  String get admitPatientInpatientOrDischarge =>
      'قبول المريض للرعاية الداخلية، أو إضافة ملاحظات العلاج والتسريح.';

  @override
  String get admitPatient => 'قبول المريض';

  @override
  String get treatAndDischarge => 'علاج وتسريح';

  @override
  String get patientAdmitted => 'تم قبول المريض';

  @override
  String get addTreatmentNotesAndDischarge =>
      'أضف ملاحظات العلاج وسرّح عند الجاهزية.';

  @override
  String get dischargePatient => 'تسريح المريض';

  @override
  String get dispatch => 'إرسال';

  @override
  String get closeCase => 'إغلاق الحالة';

  @override
  String get discharge => 'تسريح';

  @override
  String get ambulanceDispatchRequested => 'تم طلب إرسال الإسعاف.';

  @override
  String get pleaseAddAdviceForVhtFirst =>
      'يرجى إضافة النصيحة لفريق صحة القرية أولاً.';

  @override
  String get adviceSentToVhtSuccessfully =>
      'تم إرسال النصيحة لفريق صحة القرية بنجاح.';

  @override
  String get caseClosedSuccessfully => 'تم إغلاق الحالة بنجاح.';

  @override
  String get patientReceivedAddTreatmentNotes =>
      'تم استلام المريض. يمكنك الآن إضافة ملاحظات العلاج.';

  @override
  String get patientAdmittedAddNotesWhenReady =>
      'تم قبول المريض. أضف ملاحظات العلاج عند الجاهزية للتسريح.';

  @override
  String get pleaseEnterTreatmentNotesBeforeDischarging =>
      'يرجى إدخال ملاحظات العلاج قبل التسريح';

  @override
  String get patientDischargedCaseCompleted =>
      'تم تسريح المريض. اكتملت الحالة.';

  @override
  String get couldNotOpenVideo => 'تعذر فتح الفيديو';

  @override
  String get callVht => 'الاتصال بفريق صحة القرية';

  @override
  String get callDriver => 'الاتصال بالسائق';

  @override
  String get addNotesAdviceForVhtHint =>
      'أضف ملاحظاتك أو نصيحتك لفريق صحة القرية...';

  @override
  String get treatmentNotesHint => 'أدخل التشخيص والعلاج والأدوية...';

  @override
  String get activeCases => 'الحالات النشطة';

  @override
  String get clinicNotifiedAboutArrival => 'تم إبلاغ العيادة بالوصول.';

  @override
  String get vhtNotifiedAboutArrival => 'تم إبلاغ فريق صحة القرية بالوصول.';

  @override
  String failedToUpdateStatus(String error) {
    return 'فشل تحديث الحالة: $error';
  }

  @override
  String couldNotLaunchDialer(String phone) {
    return 'تعذر فتح تطبيق الاتصال لـ $phone';
  }

  @override
  String get errorAcceptingDispatch => 'خطأ في قبول الإرسال';

  @override
  String get dispatchAmbulance => 'إرسال الإسعاف';

  @override
  String get userDetails => 'تفاصيل المستخدم';

  @override
  String get cannotRemoveAdminUsers => 'لا يمكن إزالة مستخدمي المسؤول';

  @override
  String get areYouSureRemoveUser =>
      'هل أنت متأكد أنك تريد إزالة هذا المستخدم؟';

  @override
  String get userRemoved => 'تم إزالة المستخدم';

  @override
  String get failedToRemoveUser => 'فشل إزالة المستخدم';

  @override
  String get casesByType => 'الحالات حسب النوع';

  @override
  String get urgencyDistribution => 'توزيع الأولوية';

  @override
  String get staffCoverage => 'تغطية الموظفين';

  @override
  String get caseLoadByFacility => 'عبء الحالات حسب المنشأة';

  @override
  String get rankedByTotalCasesAssigned => 'مرتبة حسب إجمالي الحالات المعينة';

  @override
  String get criticalUnresolvedCases => 'حالات حرجة غير محلولة';

  @override
  String get exportReports => 'تصدير التقارير';

  @override
  String get errorLoadingFacilityData => 'خطأ في تحميل بيانات المنشأة';

  @override
  String get noFacilityDataYet => 'لا توجد بيانات للمنشأة بعد.';

  @override
  String get unassigned => 'غير معينة';

  @override
  String get viewAndManageOngoingCases => 'عرض وإدارة جميع الحالات الجارية.';

  @override
  String get addOrRemoveSystemUsers => 'إضافة أو إزالة مستخدمي النظام.';

  @override
  String get manageUsers => 'إدارة المستخدمين';

  @override
  String get failedToGenerateReport => 'فشل إنشاء التقرير';

  @override
  String get totalCases => 'إجمالي الحالات';

  @override
  String get activeCasesCount => 'الحالات النشطة';

  @override
  String get completedCases => 'الحالات المكتملة';

  @override
  String get ambulanceDispatchedSuccessfully => 'تم إرسال الإسعاف بنجاح.';

  @override
  String get pleaseSignInToViewNotifications =>
      'يرجى تسجيل الدخول لعرض الإشعارات';

  @override
  String get markAllRead => 'تعليم الكل كمقروء';

  @override
  String get failedToMarkAsRead => 'فشل تعليم كمقروء';

  @override
  String get allNotificationsMarkedAsRead => 'تم تعليم جميع الإشعارات كمقروءة';

  @override
  String get failedToMarkAllAsRead => 'فشل تعليم الكل كمقروء';

  @override
  String get navigateWithGoogleMaps => 'التنقل مع خرائط جوجل';

  @override
  String get couldNotOpenGoogleMaps => 'تعذر فتح خرائط جوجل';

  @override
  String get ugandaClinicalGuidelines2023 =>
      'المبادئ التوجيهية السريرية لأوغندا 2023';

  @override
  String get viewCaseHistory => 'عرض سجل الحالة';

  @override
  String get learningResources => 'موارد التعلم';

  @override
  String get pickImage => 'اختيار صورة';

  @override
  String get pickVideo => 'اختيار فيديو';

  @override
  String get pickFromGallery => 'الاختيار من المعرض';

  @override
  String get switchCamera => 'تبديل الكاميرا';

  @override
  String imageSizeExceedsMax(String size, String max) {
    return 'حجم الصورة ($size كيلوبايت) يتجاوز الحد الأقصى ($max كيلوبايت)';
  }

  @override
  String videoSizeExceedsMax(String size, String max) {
    return 'حجم الفيديو ($size ميجابايت) يتجاوز الحد الأقصى ($max ميجابايت)';
  }

  @override
  String get microphonePermissionRequired =>
      'إذن الميكروفون مطلوب لتسجيل المذكرات الصوتية';

  @override
  String get errorStartingRecording => 'خطأ في بدء التسجيل';

  @override
  String get errorStoppingRecording => 'خطأ في إيقاف التسجيل';

  @override
  String get errorPlayingAudio => 'خطأ في تشغيل الصوت';

  @override
  String get couldNotPlayVoiceNote => 'تعذر تشغيل المذكرة الصوتية';

  @override
  String get locationServicesDisabled =>
      'خدمات الموقع معطلة. يرجى تمكين GPS في إعدادات جهازك.';

  @override
  String get locationPermissionDenied =>
      'تم رفض إذن الموقع. يرجى منح الوصول للموقع للإبلاغ عن الطوارئ.';

  @override
  String get locationPermissionPermanentlyDenied =>
      'إذن الموقع مرفوض نهائياً. يرجى فتح الإعدادات وتمكين الموقع لهذا التطبيق.';

  @override
  String get couldNotGetLocation => 'تعذر الحصول على الموقع';

  @override
  String get notificationNewEmergencyCase => 'حالة طوارئ جديدة';

  @override
  String notificationNewEmergencyCaseMessage(
    String emergencyType,
    String vhtName,
    String patientName,
    String urgency,
  ) {
    return 'حالة $emergencyType جديدة من فريق صحة القرية $vhtName. المريض: $patientName. الأولوية: $urgency. يرجى المراجعة فوراً.';
  }

  @override
  String get notificationCaseSubmittedSuccessfully => 'تم إرسال الحالة بنجاح';

  @override
  String notificationCaseSubmittedMessage(
    String emergencyType,
    String patientName,
    String clinicName,
  ) {
    return 'تم إرسال حالة $emergencyType للمريض $patientName إلى $clinicName للمراجعة.';
  }

  @override
  String get notificationVhtFollowUpUpdate => 'تحديث متابعة فريق صحة القرية';

  @override
  String notificationVhtFollowUpMessage(
    String vhtName,
    String patientName,
    String message,
  ) {
    return '$vhtName حدّث عن $patientName: \"$message\"';
  }

  @override
  String get notificationClinicianAdviceReceived => 'تم استلام نصيحة الطبيب';

  @override
  String notificationClinicianAdviceMessage(
    String clinicianName,
    String patientName,
    String advice,
  ) {
    return 'د. $clinicianName ردّ بشأن $patientName: \"$advice\"';
  }

  @override
  String get notificationAmbulanceDispatchRequired => 'مطلوب إرسال إسعاف';

  @override
  String get notificationAmbulanceOnTheWay => 'الإسعاف في الطريق';

  @override
  String notificationAmbulanceOnTheWayMessage(
    String driverName,
    String patientName,
  ) {
    return 'تم إرسال إسعاف يقوده $driverName. ابقَ مع $patientName.';
  }

  @override
  String get notificationAmbulanceDispatched => 'تم إرسال الإسعاف';

  @override
  String notificationAmbulanceDispatchedMessage(
    String driverName,
    String emergencyType,
    String patientName,
  ) {
    return 'تم إرسال سائق الإسعاف $driverName لحالة $emergencyType (المريض: $patientName).';
  }

  @override
  String get notificationNewDispatchAssignment => 'تكليف إرسال جديد';

  @override
  String notificationNewDispatchMessage(
    String emergencyType,
    String vhtName,
    String clinicName,
    String patientName,
  ) {
    return 'تم تكليفك بحالة $emergencyType. استلم المريض من فريق صحة القرية $vhtName، وسلّمه إلى $clinicName. المريض: $patientName.';
  }

  @override
  String get notificationPatientDelivered => 'تم تسليم المريض';

  @override
  String notificationPatientDeliveredMessage(
    String patientName,
    String emergencyType,
    String clinicName,
    String driverName,
  ) {
    return 'تم تسليم المريض $patientName ($emergencyType) بأمان إلى $clinicName بواسطة $driverName.';
  }

  @override
  String get notificationPatientArriving => 'المريض قادم';

  @override
  String notificationPatientArrivingMessage(
    String patientName,
    String emergencyType,
    String driverName,
  ) {
    return 'المريض $patientName ($emergencyType) تم تسليمه بواسطة $driverName. يرجى استلام المريض.';
  }

  @override
  String get notificationPatientDischarged => 'تم تسريح المريض';

  @override
  String notificationPatientDischargedMessage(
    String patientName,
    String emergencyType,
    String clinicName,
  ) {
    return 'تم علاج وتسريح المريض $patientName ($emergencyType) من $clinicName. اكتملت الحالة.';
  }

  @override
  String get notificationCaseCompleted => 'اكتملت الحالة';

  @override
  String notificationCaseCompletedMessage(
    String patientName,
    String emergencyType,
    String clinicName,
    String clinicianName,
  ) {
    return 'تم تسريح $patientName ($emergencyType) من $clinicName بواسطة د. $clinicianName. الحالة مغلقة.';
  }

  @override
  String get notificationCaseClosed => 'الحالة مغلقة';

  @override
  String notificationCaseClosedMessage(
    String clinicianName,
    String patientName,
    String emergencyType,
  ) {
    return 'د. $clinicianName أكد أن $patientName ($emergencyType) بخير وأغلق الحالة.';
  }

  @override
  String get notificationEmergencyAlerts => 'تنبيهات الطوارئ';

  @override
  String get notificationEmergencyAlertsDescription =>
      'إشعارات لحالات الطوارئ وتحديثات الحالة';

  @override
  String errorGeneric(String error) {
    return 'خطأ: $error';
  }

  @override
  String reportedBy(String name) {
    return 'أبلغ عنه: $name';
  }

  @override
  String reportedAt(String time) {
    return 'أُبلغ: $time';
  }

  @override
  String get splashAppName => 'HealthAlert';

  @override
  String get splashTagline =>
      'التواصل في حالات الطوارئ للاستجابة الصحية في الخطوط الأمامية';

  @override
  String get noNotificationsYet => 'لا توجد إشعارات بعد';

  @override
  String get notificationsWillAppearHere => 'ستظهر الإشعارات هنا';

  @override
  String get continueButton => 'متابعة';

  @override
  String get enterVerificationCode => 'أدخل رمز التحقق';

  @override
  String weSentCodeTo(String phone) {
    return 'أرسلنا رمزاً إلى $phone';
  }

  @override
  String get forTestNumbersEnter => 'للأرقام التجريبية، أدخل: 123456';

  @override
  String get verifyButton => 'تحقق';

  @override
  String get enterYourPinToContinue => 'أدخل رمز PIN للمتابعة';

  @override
  String get verifyPinButton => 'تحقق من رمز PIN';

  @override
  String get setYourPin => 'تعيين رمز PIN';

  @override
  String get enterPinBetween4And6 => 'أدخل رمز PIN من 4 إلى 6 أرقام';

  @override
  String get enterButton => 'إدخال';

  @override
  String get pleaseEnterAPin => 'يرجى إدخال رمز PIN';

  @override
  String get pleaseConfirmYourPin => 'يرجى تأكيد رمز PIN';

  @override
  String get pinsDoNotMatch => 'رموز PIN غير متطابقة. يرجى المحاولة مرة أخرى.';

  @override
  String get confirmYourPin => 'أكد رمز PIN';

  @override
  String get pleaseReenterPinToConfirm => 'يرجى إعادة إدخال رمز PIN للتأكيد';

  @override
  String get homeLabel => 'الرئيسية';

  @override
  String get learnLabel => 'تعلم';

  @override
  String get mapLabel => 'الخريطة';

  @override
  String get incomingLabel => 'الوارد';

  @override
  String welcomeName(String name) {
    return 'مرحباً، $name';
  }

  @override
  String get quickActions => 'إجراءات سريعة';

  @override
  String get ugandaClinicalGuidelinesDescription =>
      'المبادئ التوجيهية السريرية الوطنية للعاملين الصحيين في أوغندا';

  @override
  String get patientIdLabel => 'معرّف المريض';

  @override
  String get dateOfBirth => 'تاريخ الميلاد';

  @override
  String get selectDateOfBirth => 'اختر تاريخ الميلاد';

  @override
  String ageYears(int n) {
    return '$n سنوات';
  }

  @override
  String get notesLabel => 'الملاحظات';

  @override
  String get patientDetailsHelp =>
      'هذه التفاصيل ستساعد طاقم العيادة والإسعاف على الاستعداد.';

  @override
  String get photoVideoOptional => 'صورة / فيديو (اختياري)';

  @override
  String noStaffAtFacility(String facility) {
    return 'لا يوجد طاقم متاح في $facility. يرجى اختيار منشأة أخرى أو الاتصال بالمشرف.';
  }

  @override
  String get locationNeedsAccessMessage =>
      'يحتاج HealthAlert إلى إذن الموقع للإبلاغ عن الطوارئ ومساعدة الإسعاف في العثور على المرضى.\n\nيرجى فتح الإعدادات وتمكين الموقع لهذا التطبيق.';

  @override
  String get pendingOffline => 'قيد الانتظار (غير متصل)';

  @override
  String get selectHealthFacility => 'اختر المنشأة الصحية';

  @override
  String get chooseClinicForPatient => 'اختر العيادة الأنسب لهذا المريض.';

  @override
  String get notifyClinic => 'إبلاغ العيادة';

  @override
  String get triageLevel => 'مستوى الفرز';

  @override
  String get caseSubmitted => 'تم إرسال الحالة';

  @override
  String get clinicNotifiedOfEmergency => 'تم إبلاغ العيادة بالطوارئ.';

  @override
  String get currentStatus => 'الحالة الحالية';

  @override
  String get returnToDashboard => 'العودة للوحة التحكم';

  @override
  String get reportAnotherEmergency => 'الإبلاغ عن طوارئ أخرى';

  @override
  String get caseTracking => 'تتبع الحالة';

  @override
  String get assignedClinician => 'الطبيب المعين';

  @override
  String get savedOffline => 'محفوظ دون اتصال';

  @override
  String get caseSavedOfflineMessage =>
      'تم حفظ بيانات الحالة محلياً وستُرسل إلى العيادة عند العودة للاتصال.';

  @override
  String get lastUpdated => 'آخر تحديث';

  @override
  String get caseDetails => 'تفاصيل الحالة';

  @override
  String get adviceProgress => 'تقدم النصيحة';

  @override
  String get caseProgress => 'تقدم الحالة';

  @override
  String get sending => 'جاري الإرسال...';

  @override
  String get caseHistory => 'سجل الحالة';

  @override
  String get allCases => 'جميع الحالات';

  @override
  String get allTypes => 'جميع الأنواع';

  @override
  String get activeFilter => 'نشط';

  @override
  String get allFilter => 'الكل';

  @override
  String get completedFilter => 'مكتمل';

  @override
  String get errorLoadingCases => 'خطأ في تحميل الحالات';

  @override
  String get noActiveCases => 'لا توجد حالات نشطة';

  @override
  String get noCompletedCases => 'لا توجد حالات مكتملة';

  @override
  String get noCasesFound => 'لم يتم العثور على حالات';

  @override
  String get casesReportedAppearHere => 'ستظهر الحالات التي تُبلّغ عنها هنا.';

  @override
  String get casesAssignedToYouAppearHere => 'ستظهر الحالات المعينة لك هنا.';

  @override
  String get clinicLabel => 'العيادة';

  @override
  String get unknownClinic => 'عيادة غير معروفة';

  @override
  String get unknown => 'غير معروف';

  @override
  String get clinicianLabel => 'الطبيب';

  @override
  String get contactSection => 'الاتصال';

  @override
  String get statusMsgPending => 'الطبيب يراجع حالتك.';

  @override
  String get statusMsgPendingSubmitted =>
      'الطبيب يراجع حالتك. سيتم تحديثك عند اتخاذ القرار.';

  @override
  String get statusMsgAdvised => 'الطبيب أرسل لك نصيحة. انظر أدناه.';

  @override
  String get statusMsgAmbRequested => 'الطبيب طلب إسعافاً لهذا المريض.';

  @override
  String get statusMsgDispatched => 'تم إرسال إسعاف إلى موقعك.';

  @override
  String get statusMsgDispatchedStay =>
      'تم إرسال إسعاف إلى موقعك. ابقَ مع المريض.';

  @override
  String get statusMsgEnRoute => 'الإسعاف في الطريق.';

  @override
  String get statusMsgEnRoutePrepare => 'الإسعاف في الطريق. جهّز المريض للنقل.';

  @override
  String get statusMsgArrived => 'وصل الإسعاف.';

  @override
  String get statusMsgArrivedHandOver =>
      'وصل الإسعاف. سلّم المريض لطاقم الإسعاف.';

  @override
  String get statusMsgInTransit => 'المريض يُنقل إلى العيادة.';

  @override
  String get statusMsgDelivered => 'تم تسليم المريض إلى العيادة.';

  @override
  String get statusMsgInTreatment => 'المريض يُعالج حالياً في العيادة.';

  @override
  String get statusMsgAdmitted => 'تم قبول المريض في المستشفى';

  @override
  String get statusMsgDischarged => 'تم تسريح المريض';

  @override
  String get statusMsgCompleted => 'اكتملت هذه الحالة.';

  @override
  String get statusMsgCompletedTreated => 'اكتملت هذه الحالة. تم علاج المريض.';

  @override
  String get statusMsgCancelled => 'تم إلغاء هذه الحالة.';

  @override
  String get viewAllIncomingCases => 'عرض جميع الحالات الواردة';

  @override
  String get needsYourReview => 'تحتاج مراجعتك';

  @override
  String get allCaughtUp => 'تم كل شيء!';

  @override
  String get noCasesPendingReview => 'لا توجد حالات بانتظار مراجعتك حالياً.';

  @override
  String get ambulanceEmergencyDispatch => 'الإسعاف — إرسال الطوارئ';

  @override
  String get viewIncomingEmergencyRequests =>
      'عرض طلبات الطوارئ الواردة من فريق صحة القرية والعيادات.';

  @override
  String get viewDispatch => 'عرض الإرسال';

  @override
  String get viewActiveCases => 'عرض الحالات النشطة';

  @override
  String get recentCases => 'الحالات الأخيرة';

  @override
  String get noRecentCases => 'لا توجد حالات حديثة';

  @override
  String get chooseWhatToManageToday => 'اختر ما تريد إدارته اليوم.';

  @override
  String get dispatchNeeded => 'الإرسال مطلوب';

  @override
  String get dispatchLabel => 'إرسال';

  @override
  String get analyticsSubtitle =>
      'عرض إرسال الإسعاف ورؤى تقارير فريق صحة القرية.';

  @override
  String get manageUsersSubtitle => 'إضافة أو إزالة مستخدمي النظام.';

  @override
  String get caseSavedOfflineSyncWhenOnline =>
      'تم حفظ حالة الطوارئ دون اتصال. ستُزامن عند الاتصال.';

  @override
  String get emergencyCaseCreatedSuccessfully => 'تم إنشاء حالة الطوارئ بنجاح!';

  @override
  String get dispatchConfirmation => 'تأكيد الإرسال';

  @override
  String get clinicAssigned => 'تم تعيين العيادة';

  @override
  String get estimatedArrival => 'الوصول المتوقع';

  @override
  String get assigningNearestAmbulance => 'جاري تعيين أقرب إسعاف تلقائياً…';

  @override
  String get systemWillChooseClosestAmbulance =>
      'سيختار النظام أقرب إسعاف متاح ويحدّث هذه الشاشة في الوقت الفعلي.';

  @override
  String get emergencyTypeLabel => 'نوع الطوارئ';

  @override
  String get confirmAndDispatch => 'تأكيد وإرسال';

  @override
  String get setLocation => 'تعيين الموقع';

  @override
  String get automaticallyCapturingLocation => 'جاري التقاط الموقع تلقائياً…';

  @override
  String get locationCaptureHelp =>
      'سيساعد هذا المستجيبين على العثور عليك أسرع.\nلا حاجة لتحريك الخريطة أو تثبيت موقعك.';

  @override
  String clinicAssignedWithName(String name) {
    return 'العيادة المعينة: $name';
  }

  @override
  String estimatedArrivalValue(String eta) {
    return 'الوصول المتوقع: $eta';
  }

  @override
  String locationCoordinates(String lat, String lng) {
    return 'الموقع: $lat، $lng';
  }

  @override
  String get trackAmbulance => 'تتبع الإسعاف';

  @override
  String get mapPlaceholder => 'عنصر نائب للخريطة';

  @override
  String get notifyClinicPatientOnboard =>
      'إبلاغ العيادة أن المريض على متن الإسعاف';

  @override
  String get clinicNotifiedPatientOnboard =>
      'تم إبلاغ العيادة أن المريض على متن الإسعاف.';

  @override
  String get caseClosedButton => 'الحالة مغلقة';

  @override
  String get onboardPatient => 'المريض على متن الإسعاف';

  @override
  String get callingClinicToDiscuss =>
      'الاتصال بالعيادة لمناقشة الحاجة إلى إسعاف...';

  @override
  String get callClinicToDiscussCase => 'الاتصال بالعيادة لمناقشة الحالة';

  @override
  String get continueToDispatchAmbulance => 'متابعة إرسال الإسعاف';

  @override
  String errorCreatingEmergencyCaseWithError(String error) {
    return 'خطأ في إنشاء حالة الطوارئ: $error';
  }

  @override
  String get incomingCases => 'الحالات الواردة';

  @override
  String get reviewEmergenciesSubmittedByVhts =>
      'مراجعة الطوارئ المُبلّغ عنها من فريق صحة القرية.';

  @override
  String get emergencyCasesAssignedToYourClinic =>
      'ستظهر هنا حالات الطوارئ المعينة لعيادتك.';

  @override
  String get patientLabel => 'المريض';

  @override
  String get requestAmbulanceDispatchConfirm =>
      'سيُحوّل هذا الحالة إلى الإرسال لتعيين إسعاف. هل تريد المتابعة؟';

  @override
  String get patientReceived => 'تم استلام المريض';

  @override
  String get proceed => 'متابعة';

  @override
  String get caseSummary => 'ملخص الحالة';

  @override
  String get patientArrival => 'وصول المريض';

  @override
  String get assignStaff => 'تعيين الطاقم';

  @override
  String get ambulanceTracking => 'تتبع الإسعاف';

  @override
  String get activeCasesTitle => 'الحالات النشطة';

  @override
  String get allIncomingRequests => 'جميع الطلبات الواردة';

  @override
  String get incomingDispatch => 'الإرسال الوارد';

  @override
  String get arrival => 'الوصول';

  @override
  String get caseClosure => 'إغلاق الحالة';

  @override
  String get adminHome => 'الرئيسية';

  @override
  String get adminCases => 'الحالات';

  @override
  String get adminAnalytics => 'التحليلات';

  @override
  String get adminUsers => 'المستخدمون';

  @override
  String get caseDashboard => 'لوحة حالات';

  @override
  String get caseAnalytics => 'تحليلات الحالات';

  @override
  String get manageUsersScreen => 'إدارة المستخدمين';

  @override
  String get userDetail => 'تفاصيل المستخدم';

  @override
  String get caseTimeline => 'الجدول الزمني للحالة';

  @override
  String get allCasesList => 'جميع الحالات';

  @override
  String get reportsExport => 'تصدير التقارير';

  @override
  String get vhtDetailsForm => 'تفاصيل فريق صحة القرية';

  @override
  String get clinicianRegistrationForm => 'تسجيل الطبيب';

  @override
  String get adminDetailsForm => 'تفاصيل المسؤول';

  @override
  String get ambulanceDriverDetailsForm => 'تفاصيل سائق الإسعاف';

  @override
  String get adminEmailOtpScreen => 'التحقق من بريد المسؤول';

  @override
  String get registrationForm => 'التسجيل';

  @override
  String get fullScreenCamera => 'الكاميرا';

  @override
  String get voiceNoteWidget => 'مذكرة صوتية';

  @override
  String get locationRequestTimeout => 'انتهت مهلة طلب الموقع';

  @override
  String couldNotGetLocationWithError(String error) {
    return 'تعذر الحصول على الموقع: $error';
  }

  @override
  String get reviewMediaTriageNextActions =>
      'مراجعة الوسائط ومستوى الفرز والإجراءات التالية لهذه الطوارئ.';

  @override
  String get photoVoiceNotePreview => 'معاينة الصورة / المذكرة الصوتية';

  @override
  String get triageLevelHighRed => 'مستوى الفرز: عالي (أحمر)';

  @override
  String get seeStaff => 'عرض الطاقم';

  @override
  String get requestAdditionalInfo => 'طلب معلومات إضافية';

  @override
  String get callingVhtPlaceholder => 'الاتصال بفريق صحة القرية (عنصر نائب)...';

  @override
  String get callingAmbulancePlaceholder => 'الاتصال بالإسعاف (عنصر نائب)...';

  @override
  String get confirmStaffAssignmentCloseCase =>
      'تأكيد تعيين الطاقم وإغلاق الحالة عند استلام المريض.';

  @override
  String get emergencyLabel => 'طوارئ';

  @override
  String get staffAssigned => 'تم تعيين الطاقم';

  @override
  String get patientReceivedCloseCase => 'تم استلام المريض / إغلاق الحالة';

  @override
  String get confirmPersonnelEquipment =>
      'تأكيد توفر الطاقم والمعدات المطلوبة لهذه الحالة.';

  @override
  String get nurseAvailable => 'الممرضة: متاحة';

  @override
  String get clinicianAvailable => 'الطبيب: متاح';

  @override
  String get checklistDeliveryKit =>
      'قائمة: مجموعة الولادة، مجموعة الرضح، معدات الوقاية';

  @override
  String get confirmStaff => 'تأكيد الطاقم';

  @override
  String get trackAmbulanceEtaStatus =>
      'تتبع وقت الوصول المتوقع للإسعاف وحالة هذه الحالة.';

  @override
  String get mapEtaPlaceholder => 'عنصر نائب للخريطة / وقت الوصول';

  @override
  String get onTime => 'في الوقت المحدد';

  @override
  String get incomingDispatchRequests => 'طلبات الإرسال الواردة';

  @override
  String get acceptDispatchToStart => 'اقبل الإرسال لبدء رحلتك.';

  @override
  String get errorLoadingRequests => 'خطأ في تحميل الطلبات';

  @override
  String get noIncomingRequests => 'لا توجد طلبات واردة';

  @override
  String get dispatchedCasesAppearHere => 'ستظهر الحالات المُرسلة هنا.';

  @override
  String get dispatchRequest => 'طلب الإرسال';

  @override
  String get emergencyDispatch => 'إرسال الطوارئ';

  @override
  String get reviewDetailsAcceptProceed => 'راجع التفاصيل، ثم اقبل للمتابعة.';

  @override
  String get emergencyType => 'نوع الطوارئ';

  @override
  String get destination => 'الوجهة';

  @override
  String get quickContact => 'اتصال سريع';

  @override
  String get callClinic => 'الاتصال بالعيادة';

  @override
  String get acceptDispatch => 'قبول الإرسال';

  @override
  String get toBeDetermined => 'يُحدد لاحقاً';

  @override
  String statusUpdatedTo(String status) {
    return 'تم تحديث الحالة إلى $status';
  }

  @override
  String get arrivedAtScene => 'الوصول إلى المكان';

  @override
  String get arrivedAtVht => 'الوصول إلى فريق صحة القرية';

  @override
  String get deliveredToClinic => 'تم التسليم إلى العيادة';

  @override
  String get patientPickedUp => 'تم استلام المريض';

  @override
  String get patientDeliveredSuccessfully => 'تم تسليم المريض بنجاح';

  @override
  String get deliveryCompleteClinicHandles =>
      'اكتمل التسليم. العيادة ستتولى المريض من هنا.';

  @override
  String get sortByTime => 'ترتيب حسب الوقت';

  @override
  String get sortBySeverity => 'ترتيب حسب الخطورة';

  @override
  String get sortByStatus => 'ترتيب حسب الحالة';

  @override
  String get viewAndManageSystemUsers => 'عرض وإدارة مستخدمي النظام حسب الدور.';

  @override
  String get noUsersFound => 'لم يتم العثور على مستخدمين';

  @override
  String get unknownUser => 'مستخدم غير معروف';

  @override
  String get tapToPlay => 'اضغط للتشغيل';

  @override
  String get tapToOpenCamera => 'اضغط لفتح الكاميرا';

  @override
  String get notificationFallbackTitle => 'إشعار';

  @override
  String get locationPermissionDeniedForever =>
      'إذن الموقع مرفوض نهائياً. افتح الإعدادات وتمكين الموقع لهذا التطبيق.';

  @override
  String get locationUnknownError => 'تعذر الحصول على الموقع';

  @override
  String get tapToRecordVoiceNote => 'اضغط لتسجيل مذكرة صوتية';

  @override
  String get voiceNoteOptional => 'مذكرة صوتية (اختياري)';

  @override
  String recordingWithDuration(String duration) {
    return 'جاري التسجيل: $duration';
  }

  @override
  String get arrivedPatients => 'المرضى الواصلون';

  @override
  String get noPatientsArrivedYet => 'لم يصل أي مرضى بعد';

  @override
  String get patientsWillAppearHereOnceDelivered =>
      'ستظهر المرضى هنا بعد تسليمهم بواسطة الإسعاف.';

  @override
  String get notSpecified => 'غير محدد';

  @override
  String get idLabel => 'المعرّف';

  @override
  String get patientInfo => 'معلومات المريض';

  @override
  String get patientOnboard => 'المريض على متن الإسعاف';

  @override
  String get inTreatmentStatus => 'قيد العلاج';

  @override
  String get deliveredStatus => 'تم التسليم';

  @override
  String get resolutionRate => 'معدل الحل';

  @override
  String get doneLabel => 'تم';

  @override
  String get resolutionLabel => 'الحل';

  @override
  String get adultFemale => 'بالغة';

  @override
  String get unknownPatient => 'مريض غير معروف';

  @override
  String yearsShort(int n) {
    return '$n سنة';
  }

  @override
  String get yourNotes => 'ملاحظاتك';

  @override
  String get yourAdviceToVht => 'نصيحتك لفريق صحة القرية';

  @override
  String get youAdvisedVhtCloseCase =>
      'لقد أرسلت النصيحة. عندما يكون المريض بخير، أغلق الحالة.';

  @override
  String get patientDeliveredReceiveNow =>
      'تم تسليم المريض إلى العيادة. استلم المريض لبدء العلاج.';

  @override
  String get dispatching => 'جارٍ الإرسال...';

  @override
  String get progressTimeline => 'الجدول الزمني للتقدم';

  @override
  String get reviewEventsForCase => 'مراجعة أحداث هذه الحالة.';

  @override
  String get liveMapCachedOffline => 'خريطة مباشرة · مخزنة للاستخدام دون اتصال';

  @override
  String get gettingYourLocation => 'جارٍ تحديد موقعك...';

  @override
  String get openNavigationMap => 'فتح خريطة الملاحة';

  @override
  String get backToDashboard => 'العودة للوحة التحكم';

  @override
  String get vhtPhoneNotAvailable => 'رقم هاتف فريق صحة القرية غير متوفر';

  @override
  String get clinicianPhoneNotAvailable => 'رقم هاتف الطبيب غير متوفر';

  @override
  String urgencyWithLevel(String level) {
    return 'الأولوية: $level';
  }

  @override
  String get areYouSureCloseCasePatientOk =>
      'هل أنت متأكد أن المريض بخير ويمكن إغلاق الحالة؟';

  @override
  String get closeCaseConfirmTitle => 'إغلاق الحالة';

  @override
  String get dischargePatientConfirmMsg =>
      'سيؤدي ذلك إلى تسريح المريض وإغلاق الحالة. هل أنت متأكد؟';

  @override
  String get errorLoadingCaseData => 'خطأ في تحميل بيانات الحالة';

  @override
  String get callsLabel => 'المكالمات';

  @override
  String get notificationAmbulanceRequestStandby => 'طلب سيارة إسعاف — استعداد';

  @override
  String notificationAmbulanceRequestStandbyMessage(
    String clinicianName,
    String emergencyType,
    String patientName,
  ) {
    return 'الطبيب $clinicianName طلب سيارة إسعاف لحالة $emergencyType. المريض: $patientName. كن مستعداً للإرسال.';
  }

  @override
  String get tapToViewCase => 'اضغط لعرض الحالة';

  @override
  String get latestDispatchRequest => 'أحدث طلب إرسال';

  @override
  String get noNewDispatchRequests => 'لا توجد طلبات إرسال جديدة';

  @override
  String get viewAllRequests => 'عرض جميع الطلبات';

  @override
  String get time => 'الوقت';
}
