// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Real Estate App';

  @override
  String get commonSave => 'Save';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonClose => 'Close';

  @override
  String get commonRetry => 'Try again';

  @override
  String get commonRefresh => 'Refresh';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonEdit => 'Edit';

  @override
  String get commonSubmit => 'Submit';

  @override
  String get commonDone => 'Done';

  @override
  String get commonApply => 'Apply';

  @override
  String get commonReset => 'Reset';

  @override
  String get commonSearch => 'Search';

  @override
  String get commonClear => 'Clear';

  @override
  String get commonBack => 'Back';

  @override
  String get commonNext => 'Next';

  @override
  String get commonSeeAll => 'See All';

  @override
  String get commonViewAll => 'View All';

  @override
  String get commonError => 'Something went wrong';

  @override
  String get commonLoading => 'Loading…';

  @override
  String get commonEgp => 'EGP';

  @override
  String get navHome => 'Home';

  @override
  String get navSearch => 'Search';

  @override
  String get navChat => 'Chats';

  @override
  String get navProfile => 'Profile';

  @override
  String get navFavorites => 'Favorites';

  @override
  String get homeGreeting => 'Find your dream home';

  @override
  String get homeCategories => 'Categories';

  @override
  String get homeSearchHint => 'Search address, city, or property…';

  @override
  String get homeFeaturedEstates => 'Featured Estates';

  @override
  String get homeExploreNearby => 'Explore Nearby Estates';

  @override
  String get homeTopAgents => 'Top Estate Agents';

  @override
  String get homeTopLocations => 'Popular Locations';

  @override
  String get homeLocationDisabledTitle => 'Location is turned off';

  @override
  String get homeLocationDisabledMessage =>
      'Enable location services to discover properties near you.';

  @override
  String get homeEnableLocation => 'Enable location';

  @override
  String get homeNoFeatured => 'No featured estates available right now.';

  @override
  String get homeNoNearby => 'No estates found near your current location.';

  @override
  String get homeNoAgents => 'No estate agents found.';

  @override
  String get homeLoading => 'Loading properties…';

  @override
  String get homeLoadError => 'Failed to load home properties.';

  @override
  String get searchTitle => 'Search properties';

  @override
  String get searchHint => 'Search estates…';

  @override
  String get searchFilters => 'Filters';

  @override
  String get searchApplyFilters => 'Apply filters';

  @override
  String get searchClearFilters => 'Clear filters';

  @override
  String get searchPriceRange => 'Price range (EGP)';

  @override
  String get searchMinPrice => 'Minimum';

  @override
  String get searchMaxPrice => 'Maximum';

  @override
  String get searchBedrooms => 'Bedrooms';

  @override
  String get searchBathrooms => 'Bathrooms';

  @override
  String get searchFurnished => 'Furnished properties only';

  @override
  String get searchAny => 'Any';

  @override
  String get searchPropertyType => 'Property type';

  @override
  String get searchListingType => 'Listing type';

  @override
  String get searchForSale => 'For Sale';

  @override
  String get searchForRent => 'For Rent';

  @override
  String get searchNoResults => 'No estates found';

  @override
  String get searchNoResultsHint =>
      'Try adjusting your search terms or filters.';

  @override
  String get searchViewOnMap => 'View on map';

  @override
  String get listingsAllTitle => 'All Estates';

  @override
  String get listingsFeaturedTitle => 'Featured Estates';

  @override
  String get listingsCategoryTitle => 'Category Estates';

  @override
  String get listingsNearbyTitle => 'Nearby Estates';

  @override
  String get listingsEmpty => 'No properties found.';

  @override
  String get listingsCategoryEmpty => 'No estates found for this category.';

  @override
  String get listingsLoading => 'Loading properties…';

  @override
  String get detailsTitle => 'Property Details';

  @override
  String detailsPricePer(String price, String period) {
    return 'EGP $price / $period';
  }

  @override
  String detailsPriceTotal(String price) {
    return 'EGP $price';
  }

  @override
  String get detailsOverview => 'Overview';

  @override
  String detailsBedrooms(int count) {
    return '$count Beds';
  }

  @override
  String detailsBathrooms(int count) {
    return '$count Baths';
  }

  @override
  String detailsArea(String count) {
    return '$count sqm';
  }

  @override
  String get detailsFurnished => 'Furnished';

  @override
  String get detailsUnfurnished => 'Unfurnished';

  @override
  String get detailsAmenities => 'Amenities';

  @override
  String get detailsNoAmenities => 'No specific amenities listed.';

  @override
  String get detailsDescription => 'Description';

  @override
  String get detailsReadMore => 'Read more';

  @override
  String get detailsShowLess => 'Show less';

  @override
  String get detailsLocation => 'Location';

  @override
  String get detailsViewFullMap => 'View Full Map';

  @override
  String get detailsListingAgent => 'Listing Agent';

  @override
  String get detailsContactAgent => 'Contact Agent';

  @override
  String get detailsReviews => 'Reviews';

  @override
  String get detailsWriteReview => 'Write a Review';

  @override
  String get detailsYourRating => 'Your Rating';

  @override
  String get detailsReviewCommentHint => 'Share details about this property…';

  @override
  String get detailsNoReviews => 'No reviews yet. Be the first to review!';

  @override
  String get detailsReviewSuccess =>
      'Your review has been submitted successfully.';

  @override
  String get detailsReviewError => 'Failed to submit review.';

  @override
  String get mapExploreTitle => 'Explore on Map';

  @override
  String get mapSearchTitle => 'Search Map';

  @override
  String get mapZoomIn => 'Zoom in';

  @override
  String get mapZoomOut => 'Zoom out';

  @override
  String get mapFitAll => 'Fit all properties';

  @override
  String get mapMyLocation => 'My location';

  @override
  String get mapNoValidCoordsTitle =>
      'No properties with valid coordinates found.';

  @override
  String get mapNoValidCoordsMessage =>
      'The selected properties do not have geographic coordinates available to pin on the map.';

  @override
  String get mapLoadAllButton => 'Load All Properties';

  @override
  String get mapServicesDisabled =>
      'Location services are disabled on this device.';

  @override
  String get mapPermissionRequired =>
      'Location permission is required to center on your position.';

  @override
  String get mapLocationError => 'Could not determine location.';

  @override
  String get mapViewDetails => 'View details';

  @override
  String get favoritesTitle => 'Favorites';

  @override
  String get favoritesEmpty => 'You have not saved any properties yet.';

  @override
  String get favoritesUnavailableNotice =>
      'Some saved properties are no longer available.';

  @override
  String get favoritesSignInPrompt =>
      'Sign in to view and save your favorite properties.';

  @override
  String get favoritesSignInButton => 'Sign in';

  @override
  String get favoritesLoadError => 'Favorites could not be loaded.';

  @override
  String get profileTitle => 'Your profile';

  @override
  String get profileEditTitle => 'Edit profile';

  @override
  String get profileEditSubtitle => 'Update your name, phone, and photo';

  @override
  String get profileSettingsTitle => 'Settings';

  @override
  String get profileSettingsSubtitle => 'Account security and app preferences';

  @override
  String get profileHelpTitle => 'Help & support';

  @override
  String get profileHelpSubtitle => 'Browse frequently asked questions';

  @override
  String get profileSignOutTitle => 'Sign out';

  @override
  String get profileSignOutSubtitle =>
      'Sign out of this account on this device';

  @override
  String get profileSignOutConfirmTitle => 'Sign out';

  @override
  String get profileSignOutConfirmMessage =>
      'Are you sure you want to sign out?';

  @override
  String get profileFavoritesSubtitle => 'Properties you have saved';

  @override
  String get profileMessagesSubtitle => 'Continue your conversations';

  @override
  String get profileEmailVerified => 'Email verified';

  @override
  String get profileEmailNotVerified => 'Email not verified';

  @override
  String get profileSignInPrompt => 'Sign in to view your profile';

  @override
  String get profileSignInSubtitle =>
      'Your saved properties and account details will be here.';

  @override
  String get profileSignOutDialogTitle => 'Sign out?';

  @override
  String get profileSignOutDialogContent =>
      'You can sign back in at any time to access your account.';

  @override
  String get profileLoadError => 'Your profile could not be loaded.';

  @override
  String get profileSectionAccount => 'YOUR ACCOUNT';

  @override
  String get profileSectionPreferences => 'PREFERENCES & SUPPORT';

  @override
  String get profileSectionSignOut => 'ACCOUNT';

  @override
  String get supportSection => 'SUPPORT';

  @override
  String get chatEmptyTitle => 'No conversations yet';

  @override
  String get chatEmptyMessage =>
      'Start a conversation with an agent from a property.';

  @override
  String get chatAuthRequired => 'Sign in to view your conversations.';

  @override
  String get chatInquiry => 'Property inquiry';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsAccountSection => 'ACCOUNT & SECURITY';

  @override
  String get settingsResetPassword => 'Reset password';

  @override
  String get settingsResetPasswordSubtitle => 'Send a password reset link';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsAppearanceSubtitle => 'Choose your preferred theme';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageSubtitle => 'Choose between Arabic and English';

  @override
  String get settingsLanguageEn => 'English';

  @override
  String get settingsLanguageAr => 'العربية (Arabic)';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsNotificationsSubtitle =>
      'Notification preferences are not available yet.';

  @override
  String get settingsAddProperty => 'Add New Property';

  @override
  String get settingsAddPropertySubtitle =>
      'List a new estate in English and Arabic';

  @override
  String get addPropertyTitle => 'Add New Property';

  @override
  String get addPropertySubtitle =>
      'Enter property details in English and Arabic';

  @override
  String get addPropertyTitleEn => 'Title (English)';

  @override
  String get addPropertyTitleAr => 'Title (Arabic)';

  @override
  String get addPropertyDescEn => 'Description (English)';

  @override
  String get addPropertyDescAr => 'Description (Arabic)';

  @override
  String get addPropertyAddressEn => 'Address (English)';

  @override
  String get addPropertyAddressAr => 'Address (Arabic)';

  @override
  String get addPropertyCityEn => 'City (English)';

  @override
  String get addPropertyCityAr => 'City (Arabic)';

  @override
  String get addPropertyPrice => 'Price (EGP)';

  @override
  String get addPropertyPricePeriod => 'Price Period (e.g. monthly, total)';

  @override
  String get addPropertyCategory => 'Category';

  @override
  String get addPropertyListingType => 'Listing Type';

  @override
  String get addPropertyBedrooms => 'Bedrooms';

  @override
  String get addPropertyBathrooms => 'Bathrooms';

  @override
  String get addPropertyArea => 'Area (sqm)';

  @override
  String get addPropertyFurnished => 'Furnished';

  @override
  String get addPropertyCoverImage => 'Cover Image URL';

  @override
  String get addPropertySubmit => 'Publish Listing';

  @override
  String get addPropertySuccess => 'Property published successfully!';

  @override
  String get addPropertyError =>
      'Failed to publish property. Please check required fields.';

  @override
  String get addPropertyValidationRequired => 'This field is required';

  @override
  String get addPropertyValidationNumber => 'Please enter a valid number';

  @override
  String get authWelcome => 'Welcome';

  @override
  String get authWelcomeSubtitle => 'Find and manage properties with ease';

  @override
  String get authSignIn => 'Sign In';

  @override
  String get authSignUp => 'Sign Up';

  @override
  String get authEmailLabel => 'Email';

  @override
  String get authPasswordLabel => 'Password';

  @override
  String get authFullNameLabel => 'Full Name';

  @override
  String get authPhoneLabel => 'Phone Number';

  @override
  String get authForgotPassword => 'Forgot password?';

  @override
  String get authSendResetLink => 'Send reset link';

  @override
  String get authOtpTitle => 'Verification';

  @override
  String get authOtpSubtitle => 'Enter the 4-digit code sent to your email';

  @override
  String get authVerify => 'Verify';

  @override
  String get authResendOtp => 'Resend code';

  @override
  String get authOrContinue => 'Or continue with';

  @override
  String get authDontHaveAccount => 'Don\'t have an account? Sign Up';

  @override
  String get authAlreadyHaveAccount => 'Already have an account? Sign In';

  @override
  String get authEmailRequired => 'Please enter your email';

  @override
  String get authEmailInvalid => 'Please enter a valid email address';

  @override
  String get authPasswordRequired => 'Please enter your password';

  @override
  String get authPasswordTooShort => 'Password must be at least 6 characters';

  @override
  String get offlineNotice =>
      'No internet connection. Some features may be unavailable.';
}
