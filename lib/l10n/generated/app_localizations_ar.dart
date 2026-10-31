// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'تطبيق العقارات';

  @override
  String get commonSave => 'حفظ';

  @override
  String get commonCancel => 'إلغاء';

  @override
  String get commonClose => 'إغلاق';

  @override
  String get commonRetry => 'إعادة المحاولة';

  @override
  String get commonRefresh => 'تحديث';

  @override
  String get commonDelete => 'حذف';

  @override
  String get commonEdit => 'تعديل';

  @override
  String get commonSubmit => 'إرسال';

  @override
  String get commonDone => 'تم';

  @override
  String get commonApply => 'تطبيق';

  @override
  String get commonReset => 'إعادة ضبط';

  @override
  String get commonSearch => 'بحث';

  @override
  String get commonClear => 'مسح';

  @override
  String get commonBack => 'رجوع';

  @override
  String get commonNext => 'التالي';

  @override
  String get commonSeeAll => 'عرض الكل';

  @override
  String get commonViewAll => 'عرض الكل';

  @override
  String get commonError => 'حدث خطأ ما';

  @override
  String get commonLoading => 'جاري التحميل…';

  @override
  String get commonEgp => 'ج.م';

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navSearch => 'البحث';

  @override
  String get navChat => 'المحادثات';

  @override
  String get navProfile => 'الملف الشخصي';

  @override
  String get navFavorites => 'المفضلة';

  @override
  String get homeGreeting => 'ابحث عن منزل أحلامك';

  @override
  String get homeCategories => 'الفئات';

  @override
  String get homeSearchHint => 'ابحث بالشارع، المدينة، أو العقار…';

  @override
  String get homeFeaturedEstates => 'عقارات مميزة';

  @override
  String get homeExploreNearby => 'استكشف العقارات القريبة';

  @override
  String get homeTopAgents => 'أفضل الوكلاء العقاريين';

  @override
  String get homeTopLocations => 'أشهر المناطق';

  @override
  String get homeLocationDisabledTitle => 'خدمات الموقع غير مفعّلة';

  @override
  String get homeLocationDisabledMessage =>
      'قم بتفعيل خدمات الموقع لاستكشاف العقارات القريبة منك.';

  @override
  String get homeEnableLocation => 'تفعيل الموقع';

  @override
  String get homeNoFeatured => 'لا توجد عقارات مميزة متاحة حالياً.';

  @override
  String get homeNoNearby => 'لم يتم العثور على عقارات بالقرب من موقعك الحالي.';

  @override
  String get homeNoAgents => 'لم يتم العثور على وكلاء عقاريين.';

  @override
  String get homeLoading => 'جاري تحميل العقارات…';

  @override
  String get homeLoadError => 'تعذر تحميل العقارات الرئيسية.';

  @override
  String get searchTitle => 'البحث عن عقار';

  @override
  String get searchHint => 'ابحث عن عقارات…';

  @override
  String get searchFilters => 'التصفية';

  @override
  String get searchApplyFilters => 'تطبيق الفلاتر';

  @override
  String get searchClearFilters => 'مسح الفلاتر';

  @override
  String get searchPriceRange => 'نطاق السعر (جنيه مصري)';

  @override
  String get searchMinPrice => 'الحد الأدنى';

  @override
  String get searchMaxPrice => 'الحد الأقصى';

  @override
  String get searchBedrooms => 'غرف النوم';

  @override
  String get searchBathrooms => 'الحمامات';

  @override
  String get searchFurnished => 'العقارات المفروشة فقط';

  @override
  String get searchAny => 'أي عدد';

  @override
  String get searchPropertyType => 'نوع العقار';

  @override
  String get searchListingType => 'نوع العرض';

  @override
  String get searchForSale => 'للبيع';

  @override
  String get searchForRent => 'للإيجار';

  @override
  String get searchNoResults => 'لم يتم العثور على عقارات';

  @override
  String get searchNoResultsHint => 'جرّب تعديل كلمات البحث أو تغيير الفلاتر.';

  @override
  String get searchViewOnMap => 'عرض على الخريطة';

  @override
  String get listingsAllTitle => 'جميع العقارات';

  @override
  String get listingsFeaturedTitle => 'العقارات المميزة';

  @override
  String get listingsCategoryTitle => 'عقارات الفئة';

  @override
  String get listingsNearbyTitle => 'العقارات القريبة';

  @override
  String get listingsEmpty => 'لم يتم العثور على أي عقارات.';

  @override
  String get listingsCategoryEmpty => 'لا توجد عقارات لهذه الفئة.';

  @override
  String get listingsLoading => 'جاري تحميل العقارات…';

  @override
  String get detailsTitle => 'تفاصيل العقار';

  @override
  String detailsPricePer(String price, String period) {
    return '$price ج.م / $period';
  }

  @override
  String detailsPriceTotal(String price) {
    return '$price ج.م';
  }

  @override
  String get detailsOverview => 'نظرة عامة';

  @override
  String detailsBedrooms(int count) {
    return '$count غرف';
  }

  @override
  String detailsBathrooms(int count) {
    return '$count حمامات';
  }

  @override
  String detailsArea(String count) {
    return '$count م²';
  }

  @override
  String get detailsFurnished => 'مفروش';

  @override
  String get detailsUnfurnished => 'غير مفروش';

  @override
  String get detailsAmenities => 'المرافق والخدمات';

  @override
  String get detailsNoAmenities => 'لا توجد مرافق محددة مدونة.';

  @override
  String get detailsDescription => 'الوصف';

  @override
  String get detailsReadMore => 'قراءة المزيد';

  @override
  String get detailsShowLess => 'عرض أقل';

  @override
  String get detailsLocation => 'الموقع';

  @override
  String get detailsViewFullMap => 'عرض الخريطة بالكامل';

  @override
  String get detailsListingAgent => 'الوكيل العقاري';

  @override
  String get detailsContactAgent => 'تواصل مع الوكيل';

  @override
  String get detailsReviews => 'التقييمات';

  @override
  String get detailsWriteReview => 'اكتب تقييماً';

  @override
  String get detailsYourRating => 'تقييمك';

  @override
  String get detailsReviewCommentHint => 'شارك رأيك حول هذا العقار…';

  @override
  String get detailsNoReviews => 'لا توجد تقييمات بعد. كن أول من يكتب تقييماً!';

  @override
  String get detailsReviewSuccess => 'تم إرسال تقييمك بنجاح.';

  @override
  String get detailsReviewError => 'فشل إرسال التقييم.';

  @override
  String get mapExploreTitle => 'استكشف على الخريطة';

  @override
  String get mapSearchTitle => 'خريطة البحث';

  @override
  String get mapZoomIn => 'تكبير';

  @override
  String get mapZoomOut => 'تصغير';

  @override
  String get mapFitAll => 'إظهار جميع العقارات';

  @override
  String get mapMyLocation => 'موقعي الحالي';

  @override
  String get mapNoValidCoordsTitle =>
      'لم يتم العثور على عقارات بإحداثيات صالحة.';

  @override
  String get mapNoValidCoordsMessage =>
      'العقارات المحددة لا تحتوي على إحداثيات جغرافية لعرضها على الخريطة.';

  @override
  String get mapLoadAllButton => 'تحميل جميع العقارات';

  @override
  String get mapServicesDisabled => 'خدمات الموقع غير مفعّلة على هذا الجهاز.';

  @override
  String get mapPermissionRequired =>
      'إذن تحديد الموقع مطلوب للتمركز على موقعك.';

  @override
  String get mapLocationError => 'تعذر تحديد الموقع الجغرافي.';

  @override
  String get mapViewDetails => 'عرض التفاصيل';

  @override
  String get favoritesTitle => 'المفضلة';

  @override
  String get favoritesEmpty => 'لم تقم بحفظ أي عقارات بعد.';

  @override
  String get favoritesUnavailableNotice =>
      'بعض العقارات المحفوظة لم تعد متاحة.';

  @override
  String get favoritesSignInPrompt => 'سجّل الدخول لعرض وحفظ عقاراتك المفضلة.';

  @override
  String get favoritesSignInButton => 'تسجيل الدخول';

  @override
  String get favoritesLoadError => 'تعذر تحميل المفضلة.';

  @override
  String get profileTitle => 'الملف الشخصي';

  @override
  String get profileEditTitle => 'تعديل الملف الشخصي';

  @override
  String get profileEditSubtitle => 'تحديث الاسم، الهاتف، والصورة الشخصية';

  @override
  String get profileSettingsTitle => 'الإعدادات';

  @override
  String get profileSettingsSubtitle => 'أمان الحساب وتفضيلات التطبيق';

  @override
  String get profileHelpTitle => 'المساعدة والدعم';

  @override
  String get profileHelpSubtitle => 'تصفح الأسئلة الشائعة';

  @override
  String get profileSignOutTitle => 'تسجيل الخروج';

  @override
  String get profileSignOutSubtitle => 'تسجيل الخروج من هذا الحساب على الجهاز';

  @override
  String get profileSignOutConfirmTitle => 'تسجيل الخروج';

  @override
  String get profileSignOutConfirmMessage =>
      'هل أنت متأكد من رغبتك في تسجيل الخروج؟';

  @override
  String get profileFavoritesSubtitle => 'العقارات التي قمت بحفظها';

  @override
  String get profileMessagesSubtitle => 'تابع محادثاتك مع الوكلاء';

  @override
  String get profileEmailVerified => 'تم التحقق من البريد الإلكتروني';

  @override
  String get profileEmailNotVerified => 'لم يتم التحقق من البريد الإلكتروني';

  @override
  String get profileSignInPrompt => 'سجّل الدخول لعرض ملفك الشخصي';

  @override
  String get profileSignInSubtitle =>
      'ستظهر هنا عقاراتك المحفوظة وبيانات حسابك.';

  @override
  String get profileSignOutDialogTitle => 'تسجيل الخروج؟';

  @override
  String get profileSignOutDialogContent =>
      'يمكنك تسجيل الدخول مرة أخرى في أي وقت للوصول إلى حسابك.';

  @override
  String get profileLoadError => 'تعذر تحميل بيانات الملف الشخصي.';

  @override
  String get profileSectionAccount => 'حسابك';

  @override
  String get profileSectionPreferences => 'التفضيلات والدعم';

  @override
  String get profileSectionSignOut => 'الحساب';

  @override
  String get supportSection => 'الدعم والمساعدة';

  @override
  String get chatEmptyTitle => 'لا توجد محادثات بعد';

  @override
  String get chatEmptyMessage => 'ابدأ محادثة مع وكيل من أي عقار.';

  @override
  String get chatAuthRequired => 'سجّل الدخول لعرض محادثاتك.';

  @override
  String get chatInquiry => 'استفسار عن العقار';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get settingsAccountSection => 'الحساب والأمان';

  @override
  String get settingsResetPassword => 'إعادة تعيين كلمة المرور';

  @override
  String get settingsResetPasswordSubtitle =>
      'إرسال رابط إعادة تعيين كلمة المرور';

  @override
  String get settingsAppearance => 'المظهر';

  @override
  String get settingsAppearanceSubtitle => 'اختر الوضع المناسب لواجهة التطبيق';

  @override
  String get settingsThemeSystem => 'تلقائي (حسب النظام)';

  @override
  String get settingsThemeLight => 'فاتح';

  @override
  String get settingsThemeDark => 'داكن';

  @override
  String get settingsLanguage => 'اللغة';

  @override
  String get settingsLanguageSubtitle => 'التبديل بين العربية والإنجليزية';

  @override
  String get settingsLanguageEn => 'English (الإنجليزية)';

  @override
  String get settingsLanguageAr => 'العربية';

  @override
  String get settingsNotifications => 'الإشعارات';

  @override
  String get settingsNotificationsSubtitle =>
      'تفضيلات الإشعارات غير متاحة حالياً.';

  @override
  String get settingsAddProperty => 'إضافة عقار جديد';

  @override
  String get settingsAddPropertySubtitle =>
      'إدراج عقار جديد باللغتين العربية والإنجليزية';

  @override
  String get addPropertyTitle => 'إضافة عقار جديد';

  @override
  String get addPropertySubtitle =>
      'أدخل بيانات العقار باللغتين العربية والإنجليزية';

  @override
  String get addPropertyTitleEn => 'عنوان العقار (بالإنجليزية)';

  @override
  String get addPropertyTitleAr => 'عنوان العقار (بالعربية)';

  @override
  String get addPropertyDescEn => 'الوصف (بالإنجليزية)';

  @override
  String get addPropertyDescAr => 'الوصف (بالعربية)';

  @override
  String get addPropertyAddressEn => 'العنوان (بالإنجليزية)';

  @override
  String get addPropertyAddressAr => 'العنوان (بالعربية)';

  @override
  String get addPropertyCityEn => 'المدينة (بالإنجليزية)';

  @override
  String get addPropertyCityAr => 'المدينة (بالعربية)';

  @override
  String get addPropertyPrice => 'السعر (جنيه مصري)';

  @override
  String get addPropertyPricePeriod => 'فترة السعر (مثلاً: شهرياً، إجمالي)';

  @override
  String get addPropertyCategory => 'الفئة';

  @override
  String get addPropertyListingType => 'نوع العرض';

  @override
  String get addPropertyBedrooms => 'غرف النوم';

  @override
  String get addPropertyBathrooms => 'الحمامات';

  @override
  String get addPropertyArea => 'المساحة (م²)';

  @override
  String get addPropertyFurnished => 'مفروش';

  @override
  String get addPropertyCoverImage => 'رابط الصورة الرئيسية';

  @override
  String get addPropertySubmit => 'نشر الإعلان';

  @override
  String get addPropertySuccess => 'تم نشر العقار بنجاح!';

  @override
  String get addPropertyError =>
      'تعذر نشر العقار. يرجى التأكد من الحقول المطلوبة.';

  @override
  String get addPropertyValidationRequired => 'هذا الحقل مطلوب';

  @override
  String get addPropertyValidationNumber => 'يرجى إدخال رقم صحيح';

  @override
  String get authWelcome => 'مرحباً بك';

  @override
  String get authWelcomeSubtitle => 'اعثر على عقاراتك وأدرها بكل سهولة';

  @override
  String get authSignIn => 'تسجيل الدخول';

  @override
  String get authSignUp => 'إنشاء حساب';

  @override
  String get authEmailLabel => 'البريد الإلكتروني';

  @override
  String get authPasswordLabel => 'كلمة المرور';

  @override
  String get authFullNameLabel => 'الاسم بالكامل';

  @override
  String get authPhoneLabel => 'رقم الهاتف';

  @override
  String get authForgotPassword => 'نسيت كلمة المرور؟';

  @override
  String get authSendResetLink => 'إرسال رابط التعيين';

  @override
  String get authOtpTitle => 'التحقق من الرمز';

  @override
  String get authOtpSubtitle =>
      'أدخل الرمز المكون من 4 أرقام المرسل إلى بريدك الإلكتروني';

  @override
  String get authVerify => 'تحقق';

  @override
  String get authResendOtp => 'إعادة إرسال الرمز';

  @override
  String get authOrContinue => 'أو المتابعة من خلال';

  @override
  String get authDontHaveAccount => 'ليس لديك حساب؟ إنشاء حساب';

  @override
  String get authAlreadyHaveAccount => 'لديك حساب بالفعل؟ تسجيل الدخول';

  @override
  String get authEmailRequired => 'يرجى إدخال البريد الإلكتروني';

  @override
  String get authEmailInvalid => 'يرجى إدخال بريد إلكتروني صالح';

  @override
  String get authPasswordRequired => 'يرجى إدخال كلمة المرور';

  @override
  String get authPasswordTooShort => 'يجب أن تكون كلمة المرور 6 أحرف على الأقل';

  @override
  String get authContinueWithEmail => 'المتابعة بالبريد الإلكتروني';

  @override
  String get authForgotPasswordLink => 'نسيت كلمة المرور؟';

  @override
  String get authDontHaveAccountShort => 'ليس لديك حساب؟ ';

  @override
  String get authAlreadyHaveAccountShort => 'لديك حساب بالفعل؟ ';

  @override
  String get authSignInLink => 'تسجيل الدخول';

  @override
  String get authRegisterLink => 'إنشاء حساب';

  @override
  String get authLoginTitle => 'لنبدأ بتسجيل الدخول';

  @override
  String get authLoginSubtitle => 'أهلاً بعودتك! سجّل الدخول للمتابعة.';

  @override
  String get authRegisterTitle => 'إنشاء حسابك';

  @override
  String get authRegisterSubtitle => 'انضم إلينا للعثور على عقار أحلامك.';

  @override
  String get authLoginButton => 'تسجيل الدخول';

  @override
  String get authRegisterButton => 'إنشاء حساب';

  @override
  String get authPasswordRequiredField => 'كلمة المرور مطلوبة';

  @override
  String get authTermsOfService =>
      'بإنشاء الحساب، أنت توافق على شروط الخدمة وسياسة الخصوصية.';

  @override
  String get authFacebookLogin => 'تسجيل الدخول بفيسبوك';

  @override
  String get authFacebookLoginMessage =>
      'تسجيل الدخول بفيسبوك يتطلب إعداد معرف تطبيق فيسبوك في كونسول Firebase.';

  @override
  String get authFacebookDialogOk => 'موافق';

  @override
  String get authReadyTo => 'هل أنت مستعد ';

  @override
  String get authExplore => 'للاستكشاف؟';

  @override
  String get authExploreSubtitle =>
      'اعثر على منزل أحلامك بسهولة وعش راحة منزلك المستقبلي.';

  @override
  String get authForgotPasswordSubtitle =>
      'أدخل بريدك الإلكتروني المسجل وسنرسل لك رابطاً لإعادة تعيين كلمة المرور.';

  @override
  String get authPasswordResetSent =>
      'تم إرسال رابط إعادة تعيين كلمة المرور! تحقق من صندوق الوارد والبريد غير الهام.';

  @override
  String get authResendLink => 'إعادة إرسال الرابط';

  @override
  String get authOtpEnterAllDigits => 'يرجى إدخال جميع الأرقام الأربعة';

  @override
  String get authOtpDispatched => 'تم إرسال رمز تحقق جديد بنجاح.';

  @override
  String get authOtpResendIn => 'إعادة إرسال الرمز خلال';

  @override
  String get editProfileTitle => 'تعديل الملف الشخصي';

  @override
  String get editProfileFullName => 'الاسم بالكامل';

  @override
  String get editProfileEmail => 'البريد الإلكتروني';

  @override
  String get editProfileEmailHelper =>
      'تغيير البريد الإلكتروني يتطلب التحقق من الحساب وغير متاح هنا.';

  @override
  String get editProfilePhone => 'رقم الهاتف';

  @override
  String get editProfileNameRequired => 'أدخل اسمك';

  @override
  String get editProfileSaveChanges => 'حفظ التغييرات';

  @override
  String get editProfileChangePhoto => 'تغيير الصورة الشخصية';

  @override
  String get editProfileTryAgain => 'إعادة المحاولة';

  @override
  String get editProfileLoadError => 'تعذر تحميل بيانات الملف الشخصي.';

  @override
  String get mapRefresh => 'تحديث';

  @override
  String get mapLoadAllProperties => 'تحميل جميع العقارات';

  @override
  String get agentDetailsTitle => 'تفاصيل الوكيل';

  @override
  String get agentDetailsTryAgain => 'إعادة المحاولة';

  @override
  String get agentDetailsPropertiesError => 'تعذر تحميل العقارات.';

  @override
  String get agentDetailsNoProperties =>
      'هذا الوكيل ليس لديه عقارات منشورة بعد.';

  @override
  String get agentDetailsPropertiesTitle => 'عقارات الوكيل';

  @override
  String get agentDetailsPhone => 'الهاتف';

  @override
  String get agentDetailsEmail => 'البريد الإلكتروني';

  @override
  String get agentDetailsBio => 'نبذة';

  @override
  String get agentDetailsPublishedEstates => 'العقارات المنشورة';

  @override
  String get searchFilterPriceError =>
      'يجب ألا يتجاوز الحد الأدنى للسعر الحد الأقصى.';

  @override
  String get searchFilterInvalidPrice => 'أدخل سعراً صحيحاً';

  @override
  String get searchFilterInvalidNumber => 'أدخل رقماً صحيحاً';

  @override
  String get chatNoMessages => 'لا توجد رسائل بعد. ابدأ المحادثة.';

  @override
  String get chatMessageHint => 'اكتب رسالة...';

  @override
  String get chatSignInToSend => 'سجّل الدخول لإرسال رسالة';

  @override
  String get chatSendTooltip => 'إرسال رسالة';

  @override
  String get galleryViewAll => 'عرض جميع الصور';

  @override
  String get onboarding1Title => 'مرحباً بك في تطبيق العقارات';

  @override
  String get onboarding1Subtitle => 'اكتشف منزل أحلامك بكل سهولة';

  @override
  String get onboarding2Title => 'بحث ذكي وفلاتر';

  @override
  String get onboarding2Subtitle => 'ابحث عن عقارات تناسب معاييرك';

  @override
  String get onboarding3Title => 'تواصل مع الوكلاء';

  @override
  String get onboarding3Subtitle => 'تحدث مباشرة مع وكلاء معتمدين';

  @override
  String get onboardingGetStarted => 'ابدأ الآن';

  @override
  String get onboardingSkip => 'تخطي';

  @override
  String get faqTitle => 'الأسئلة الشائعة';

  @override
  String get faqSearchHint => 'ابحث في الأسئلة...';

  @override
  String get faqNoResults => 'لم يتم العثور على أسئلة مطابقة لبحثك.';

  @override
  String get faqExpand => 'توسيع';

  @override
  String get faqCollapse => 'طي';

  @override
  String get commonOr => 'أو';

  @override
  String get commonBullet => ' • ';

  @override
  String get commonTermsAndPrivacy => 'شروط الخدمة وسياسة الخصوصية';

  @override
  String get offlineNotice =>
      'لا يوجد اتصال بالإنترنت. قد لا تتوفر بعض الميزات.';

  @override
  String get bookingTitle => 'حجز موعد للمعاينة';

  @override
  String get bookingSuccess => 'تم حجز موعد المعاينة بنجاح!';

  @override
  String get bookingDuplicateError =>
      'لديك بالفعل حجز لهذا التاريخ والوقت المحدد.';

  @override
  String get bookingError => 'فشل الحجز.';

  @override
  String get bookingCustomerSection => 'بياناتك الشخصية';

  @override
  String get bookingCustomerName => 'الاسم بالكامل';

  @override
  String get bookingFieldRequired => 'مطلوب';

  @override
  String get bookingCustomerEmail => 'البريد الإلكتروني';

  @override
  String get bookingEmailInvalid => 'أدخل بريداً إلكترونياً صالحاً';

  @override
  String get bookingCustomerPhone => 'رقم الهاتف';

  @override
  String get bookingPhoneInvalid => 'أدخل رقم هاتف صحيح';

  @override
  String get bookingScheduleSection => 'موعد المعاينة';

  @override
  String get bookingDateLabel => 'تاريخ المعاينة';

  @override
  String get bookingTimeSlotLabel => 'الوقت المحدد';

  @override
  String get bookingNotesLabel => 'ملاحظات إضافية (اختياري)';

  @override
  String get bookingNotesHint => 'أي طلبات خاصة أو أسئلة للوكيل...';

  @override
  String get bookingSubmit => 'تأكيد الحجز';

  @override
  String get myBookingsTitle => 'حجوزاتي';

  @override
  String get myBookingsEmpty => 'لا توجد حجوزات حتى الآن.';

  @override
  String get myBookingsSubtitle => 'احجز موعداً لمعاينة أي عقار للبدء.';

  @override
  String get bookingDetailsTitle => 'تفاصيل الحجز';

  @override
  String get bookingStatusLabel => 'الحالة';

  @override
  String get bookingPropertySnapshot => 'العقار';

  @override
  String get bookingCancelTitle => 'إلغاء الحجز؟';

  @override
  String get bookingCancelConfirm =>
      'هل أنت متأكد من رغبتك في إلغاء هذا الحجز؟ لا يمكن التراجع عن هذا الإجراء.';

  @override
  String get bookingCancelButton => 'إلغاء الحجز';

  @override
  String get bookingCancelSuccess => 'تم إلغاء الحجز بنجاح.';

  @override
  String get detailsBookVisit => 'حجز معاينة';

  @override
  String get detailsBookVisitLoginPrompt => 'يرجى تسجيل الدخول لحجز معاينة.';

  @override
  String get detailsEstateUnavailable => 'هذا العقار غير متاح للحجز حالياً.';

  @override
  String get profileMyBookingsSubtitle => 'عرض وإدارة مواعيد معاينة العقارات';

  @override
  String get notificationsTitle => 'الإشعارات';

  @override
  String get notificationsMarkAllRead => 'تحديد الكل كمقروء';

  @override
  String get notificationsEmpty => 'لا توجد إشعارات حتى الآن.';

  @override
  String get profileNotificationsSubtitle => 'عرض نشاطك والتحديثات';
}
