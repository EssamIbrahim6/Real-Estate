import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
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
  ];

  /// The application name
  ///
  /// In en, this message translates to:
  /// **'Real Estate App'**
  String get appName;

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

  /// No description provided for @commonClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonClose;

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get commonRetry;

  /// No description provided for @commonRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get commonRefresh;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @commonEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get commonEdit;

  /// No description provided for @commonSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get commonSubmit;

  /// No description provided for @commonDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get commonDone;

  /// No description provided for @commonApply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get commonApply;

  /// No description provided for @commonReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get commonReset;

  /// No description provided for @commonSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get commonSearch;

  /// No description provided for @commonClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get commonClear;

  /// No description provided for @commonBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get commonBack;

  /// No description provided for @commonNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get commonNext;

  /// No description provided for @commonSeeAll.
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get commonSeeAll;

  /// No description provided for @commonViewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get commonViewAll;

  /// No description provided for @commonError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get commonError;

  /// No description provided for @commonLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get commonLoading;

  /// No description provided for @commonEgp.
  ///
  /// In en, this message translates to:
  /// **'EGP'**
  String get commonEgp;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get navSearch;

  /// No description provided for @navChat.
  ///
  /// In en, this message translates to:
  /// **'Chats'**
  String get navChat;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @navFavorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get navFavorites;

  /// No description provided for @homeGreeting.
  ///
  /// In en, this message translates to:
  /// **'Find your dream home'**
  String get homeGreeting;

  /// No description provided for @homeCategories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get homeCategories;

  /// No description provided for @homeSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search address, city, or property...'**
  String get homeSearchHint;

  /// No description provided for @homeFeaturedEstates.
  ///
  /// In en, this message translates to:
  /// **'Featured Estates'**
  String get homeFeaturedEstates;

  /// No description provided for @homeExploreNearby.
  ///
  /// In en, this message translates to:
  /// **'Explore Nearby Estates'**
  String get homeExploreNearby;

  /// No description provided for @homeTopAgents.
  ///
  /// In en, this message translates to:
  /// **'Top Estate Agents'**
  String get homeTopAgents;

  /// No description provided for @homeTopLocations.
  ///
  /// In en, this message translates to:
  /// **'Popular Locations'**
  String get homeTopLocations;

  /// No description provided for @homeLocationDisabledTitle.
  ///
  /// In en, this message translates to:
  /// **'Location is turned off'**
  String get homeLocationDisabledTitle;

  /// No description provided for @homeLocationDisabledMessage.
  ///
  /// In en, this message translates to:
  /// **'Enable location services to discover properties near you.'**
  String get homeLocationDisabledMessage;

  /// No description provided for @homeEnableLocation.
  ///
  /// In en, this message translates to:
  /// **'Enable location'**
  String get homeEnableLocation;

  /// No description provided for @homeNoFeatured.
  ///
  /// In en, this message translates to:
  /// **'No featured estates available right now.'**
  String get homeNoFeatured;

  /// No description provided for @homeNoNearby.
  ///
  /// In en, this message translates to:
  /// **'No estates found near your current location.'**
  String get homeNoNearby;

  /// No description provided for @homeNoAgents.
  ///
  /// In en, this message translates to:
  /// **'No estate agents found.'**
  String get homeNoAgents;

  /// No description provided for @homeLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading properties...'**
  String get homeLoading;

  /// No description provided for @homeLoadError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load home properties.'**
  String get homeLoadError;

  /// No description provided for @searchTitle.
  ///
  /// In en, this message translates to:
  /// **'Search properties'**
  String get searchTitle;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search estates...'**
  String get searchHint;

  /// No description provided for @searchFilters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get searchFilters;

  /// No description provided for @searchApplyFilters.
  ///
  /// In en, this message translates to:
  /// **'Apply filters'**
  String get searchApplyFilters;

  /// No description provided for @searchClearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get searchClearFilters;

  /// No description provided for @searchPriceRange.
  ///
  /// In en, this message translates to:
  /// **'Price range (EGP)'**
  String get searchPriceRange;

  /// No description provided for @searchMinPrice.
  ///
  /// In en, this message translates to:
  /// **'Minimum'**
  String get searchMinPrice;

  /// No description provided for @searchMaxPrice.
  ///
  /// In en, this message translates to:
  /// **'Maximum'**
  String get searchMaxPrice;

  /// No description provided for @searchBedrooms.
  ///
  /// In en, this message translates to:
  /// **'Bedrooms'**
  String get searchBedrooms;

  /// No description provided for @searchBathrooms.
  ///
  /// In en, this message translates to:
  /// **'Bathrooms'**
  String get searchBathrooms;

  /// No description provided for @searchFurnished.
  ///
  /// In en, this message translates to:
  /// **'Furnished properties only'**
  String get searchFurnished;

  /// No description provided for @searchAny.
  ///
  /// In en, this message translates to:
  /// **'Any'**
  String get searchAny;

  /// No description provided for @searchPropertyType.
  ///
  /// In en, this message translates to:
  /// **'Property type'**
  String get searchPropertyType;

  /// No description provided for @searchListingType.
  ///
  /// In en, this message translates to:
  /// **'Listing type'**
  String get searchListingType;

  /// No description provided for @searchForSale.
  ///
  /// In en, this message translates to:
  /// **'For Sale'**
  String get searchForSale;

  /// No description provided for @searchForRent.
  ///
  /// In en, this message translates to:
  /// **'For Rent'**
  String get searchForRent;

  /// No description provided for @searchNoResults.
  ///
  /// In en, this message translates to:
  /// **'No estates found'**
  String get searchNoResults;

  /// No description provided for @searchNoResultsHint.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your search terms or filters.'**
  String get searchNoResultsHint;

  /// No description provided for @searchViewOnMap.
  ///
  /// In en, this message translates to:
  /// **'View on map'**
  String get searchViewOnMap;

  /// No description provided for @listingsAllTitle.
  ///
  /// In en, this message translates to:
  /// **'All Estates'**
  String get listingsAllTitle;

  /// No description provided for @listingsFeaturedTitle.
  ///
  /// In en, this message translates to:
  /// **'Featured Estates'**
  String get listingsFeaturedTitle;

  /// No description provided for @listingsCategoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Category Estates'**
  String get listingsCategoryTitle;

  /// No description provided for @listingsNearbyTitle.
  ///
  /// In en, this message translates to:
  /// **'Nearby Estates'**
  String get listingsNearbyTitle;

  /// No description provided for @listingsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No properties found.'**
  String get listingsEmpty;

  /// No description provided for @listingsCategoryEmpty.
  ///
  /// In en, this message translates to:
  /// **'No estates found for this category.'**
  String get listingsCategoryEmpty;

  /// No description provided for @listingsLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading properties...'**
  String get listingsLoading;

  /// No description provided for @detailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Property Details'**
  String get detailsTitle;

  /// No description provided for @detailsPricePer.
  ///
  /// In en, this message translates to:
  /// **'EGP {price} / {period}'**
  String detailsPricePer(String price, String period);

  /// No description provided for @detailsPriceTotal.
  ///
  /// In en, this message translates to:
  /// **'EGP {price}'**
  String detailsPriceTotal(String price);

  /// No description provided for @detailsOverview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get detailsOverview;

  /// No description provided for @detailsBedrooms.
  ///
  /// In en, this message translates to:
  /// **'{count} Beds'**
  String detailsBedrooms(int count);

  /// No description provided for @detailsBathrooms.
  ///
  /// In en, this message translates to:
  /// **'{count} Baths'**
  String detailsBathrooms(int count);

  /// No description provided for @detailsArea.
  ///
  /// In en, this message translates to:
  /// **'{count} sqm'**
  String detailsArea(String count);

  /// No description provided for @detailsFurnished.
  ///
  /// In en, this message translates to:
  /// **'Furnished'**
  String get detailsFurnished;

  /// No description provided for @detailsUnfurnished.
  ///
  /// In en, this message translates to:
  /// **'Unfurnished'**
  String get detailsUnfurnished;

  /// No description provided for @detailsAmenities.
  ///
  /// In en, this message translates to:
  /// **'Amenities'**
  String get detailsAmenities;

  /// No description provided for @detailsNoAmenities.
  ///
  /// In en, this message translates to:
  /// **'No specific amenities listed.'**
  String get detailsNoAmenities;

  /// No description provided for @detailsDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get detailsDescription;

  /// No description provided for @detailsReadMore.
  ///
  /// In en, this message translates to:
  /// **'Read more'**
  String get detailsReadMore;

  /// No description provided for @detailsShowLess.
  ///
  /// In en, this message translates to:
  /// **'Show less'**
  String get detailsShowLess;

  /// No description provided for @detailsLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get detailsLocation;

  /// No description provided for @detailsViewFullMap.
  ///
  /// In en, this message translates to:
  /// **'View Full Map'**
  String get detailsViewFullMap;

  /// No description provided for @detailsListingAgent.
  ///
  /// In en, this message translates to:
  /// **'Listing Agent'**
  String get detailsListingAgent;

  /// No description provided for @detailsContactAgent.
  ///
  /// In en, this message translates to:
  /// **'Contact Agent'**
  String get detailsContactAgent;

  /// No description provided for @detailsReviews.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get detailsReviews;

  /// No description provided for @detailsWriteReview.
  ///
  /// In en, this message translates to:
  /// **'Write a Review'**
  String get detailsWriteReview;

  /// No description provided for @detailsYourRating.
  ///
  /// In en, this message translates to:
  /// **'Your Rating'**
  String get detailsYourRating;

  /// No description provided for @detailsReviewCommentHint.
  ///
  /// In en, this message translates to:
  /// **'Share details about this property...'**
  String get detailsReviewCommentHint;

  /// No description provided for @detailsNoReviews.
  ///
  /// In en, this message translates to:
  /// **'No reviews yet. Be the first to review!'**
  String get detailsNoReviews;

  /// No description provided for @detailsReviewSuccess.
  ///
  /// In en, this message translates to:
  /// **'Your review has been submitted successfully.'**
  String get detailsReviewSuccess;

  /// No description provided for @detailsReviewError.
  ///
  /// In en, this message translates to:
  /// **'Failed to submit review.'**
  String get detailsReviewError;

  /// No description provided for @mapExploreTitle.
  ///
  /// In en, this message translates to:
  /// **'Explore on Map'**
  String get mapExploreTitle;

  /// No description provided for @mapSearchTitle.
  ///
  /// In en, this message translates to:
  /// **'Search Map'**
  String get mapSearchTitle;

  /// No description provided for @mapZoomIn.
  ///
  /// In en, this message translates to:
  /// **'Zoom in'**
  String get mapZoomIn;

  /// No description provided for @mapZoomOut.
  ///
  /// In en, this message translates to:
  /// **'Zoom out'**
  String get mapZoomOut;

  /// No description provided for @mapFitAll.
  ///
  /// In en, this message translates to:
  /// **'Fit all properties'**
  String get mapFitAll;

  /// No description provided for @mapMyLocation.
  ///
  /// In en, this message translates to:
  /// **'My location'**
  String get mapMyLocation;

  /// No description provided for @mapNoValidCoordsTitle.
  ///
  /// In en, this message translates to:
  /// **'No properties with valid coordinates found.'**
  String get mapNoValidCoordsTitle;

  /// No description provided for @mapNoValidCoordsMessage.
  ///
  /// In en, this message translates to:
  /// **'The selected properties do not have geographic coordinates available to pin on the map.'**
  String get mapNoValidCoordsMessage;

  /// No description provided for @mapLoadAllButton.
  ///
  /// In en, this message translates to:
  /// **'Load All Properties'**
  String get mapLoadAllButton;

  /// No description provided for @mapServicesDisabled.
  ///
  /// In en, this message translates to:
  /// **'Location services are disabled on this device.'**
  String get mapServicesDisabled;

  /// No description provided for @mapPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Location permission is required to center on your position.'**
  String get mapPermissionRequired;

  /// No description provided for @mapLocationError.
  ///
  /// In en, this message translates to:
  /// **'Could not determine location.'**
  String get mapLocationError;

  /// No description provided for @mapViewDetails.
  ///
  /// In en, this message translates to:
  /// **'View details'**
  String get mapViewDetails;

  /// No description provided for @favoritesTitle.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favoritesTitle;

  /// No description provided for @favoritesEmpty.
  ///
  /// In en, this message translates to:
  /// **'You have not saved any properties yet.'**
  String get favoritesEmpty;

  /// No description provided for @favoritesUnavailableNotice.
  ///
  /// In en, this message translates to:
  /// **'Some saved properties are no longer available.'**
  String get favoritesUnavailableNotice;

  /// No description provided for @favoritesSignInPrompt.
  ///
  /// In en, this message translates to:
  /// **'Sign in to view and save your favorite properties.'**
  String get favoritesSignInPrompt;

  /// No description provided for @favoritesSignInButton.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get favoritesSignInButton;

  /// No description provided for @favoritesLoadError.
  ///
  /// In en, this message translates to:
  /// **'Favorites could not be loaded.'**
  String get favoritesLoadError;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Your profile'**
  String get profileTitle;

  /// No description provided for @profileEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get profileEditTitle;

  /// No description provided for @profileEditSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Update your name, phone, and photo'**
  String get profileEditSubtitle;

  /// No description provided for @profileSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get profileSettingsTitle;

  /// No description provided for @profileSettingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Account security and app preferences'**
  String get profileSettingsSubtitle;

  /// No description provided for @profileHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Help & support'**
  String get profileHelpTitle;

  /// No description provided for @profileHelpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Browse frequently asked questions'**
  String get profileHelpSubtitle;

  /// No description provided for @profileSignOutTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get profileSignOutTitle;

  /// No description provided for @profileSignOutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign out of this account on this device'**
  String get profileSignOutSubtitle;

  /// No description provided for @profileSignOutConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get profileSignOutConfirmTitle;

  /// No description provided for @profileSignOutConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out?'**
  String get profileSignOutConfirmMessage;

  /// No description provided for @profileFavoritesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Properties you have saved'**
  String get profileFavoritesSubtitle;

  /// No description provided for @profileMessagesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Continue your conversations'**
  String get profileMessagesSubtitle;

  /// No description provided for @profileEmailVerified.
  ///
  /// In en, this message translates to:
  /// **'Email verified'**
  String get profileEmailVerified;

  /// No description provided for @profileEmailNotVerified.
  ///
  /// In en, this message translates to:
  /// **'Email not verified'**
  String get profileEmailNotVerified;

  /// No description provided for @profileSignInPrompt.
  ///
  /// In en, this message translates to:
  /// **'Sign in to view your profile'**
  String get profileSignInPrompt;

  /// No description provided for @profileSignInSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your saved properties and account details will be here.'**
  String get profileSignInSubtitle;

  /// No description provided for @profileSignOutDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign out?'**
  String get profileSignOutDialogTitle;

  /// No description provided for @profileSignOutDialogContent.
  ///
  /// In en, this message translates to:
  /// **'You can sign back in at any time to access your account.'**
  String get profileSignOutDialogContent;

  /// No description provided for @profileLoadError.
  ///
  /// In en, this message translates to:
  /// **'Your profile could not be loaded.'**
  String get profileLoadError;

  /// No description provided for @profileSectionAccount.
  ///
  /// In en, this message translates to:
  /// **'YOUR ACCOUNT'**
  String get profileSectionAccount;

  /// No description provided for @profileSectionPreferences.
  ///
  /// In en, this message translates to:
  /// **'PREFERENCES & SUPPORT'**
  String get profileSectionPreferences;

  /// No description provided for @profileSectionSignOut.
  ///
  /// In en, this message translates to:
  /// **'ACCOUNT'**
  String get profileSectionSignOut;

  /// No description provided for @supportSection.
  ///
  /// In en, this message translates to:
  /// **'SUPPORT'**
  String get supportSection;

  /// No description provided for @chatEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No conversations yet'**
  String get chatEmptyTitle;

  /// No description provided for @chatEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Start a conversation with an agent from a property.'**
  String get chatEmptyMessage;

  /// No description provided for @chatAuthRequired.
  ///
  /// In en, this message translates to:
  /// **'Sign in to view your conversations.'**
  String get chatAuthRequired;

  /// No description provided for @chatInquiry.
  ///
  /// In en, this message translates to:
  /// **'Property inquiry'**
  String get chatInquiry;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsAccountSection.
  ///
  /// In en, this message translates to:
  /// **'ACCOUNT & SECURITY'**
  String get settingsAccountSection;

  /// No description provided for @settingsResetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get settingsResetPassword;

  /// No description provided for @settingsResetPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Send a password reset link'**
  String get settingsResetPasswordSubtitle;

  /// No description provided for @settingsAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearance;

  /// No description provided for @settingsAppearanceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your preferred theme'**
  String get settingsAppearanceSubtitle;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settingsThemeSystem;

  /// No description provided for @settingsThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeDark;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose between Arabic and English'**
  String get settingsLanguageSubtitle;

  /// No description provided for @settingsLanguageEn.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settingsLanguageEn;

  /// No description provided for @settingsLanguageAr.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get settingsLanguageAr;

  /// No description provided for @settingsNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsNotifications;

  /// No description provided for @settingsNotificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Notification preferences are not available yet.'**
  String get settingsNotificationsSubtitle;

  /// No description provided for @settingsAddProperty.
  ///
  /// In en, this message translates to:
  /// **'Add New Property'**
  String get settingsAddProperty;

  /// No description provided for @settingsAddPropertySubtitle.
  ///
  /// In en, this message translates to:
  /// **'List a new estate in English and Arabic'**
  String get settingsAddPropertySubtitle;

  /// No description provided for @addPropertyTitle.
  ///
  /// In en, this message translates to:
  /// **'Add New Property'**
  String get addPropertyTitle;

  /// No description provided for @addPropertySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter property details in English and Arabic'**
  String get addPropertySubtitle;

  /// No description provided for @addPropertyTitleEn.
  ///
  /// In en, this message translates to:
  /// **'Title (English)'**
  String get addPropertyTitleEn;

  /// No description provided for @addPropertyTitleAr.
  ///
  /// In en, this message translates to:
  /// **'Title (Arabic)'**
  String get addPropertyTitleAr;

  /// No description provided for @addPropertyDescEn.
  ///
  /// In en, this message translates to:
  /// **'Description (English)'**
  String get addPropertyDescEn;

  /// No description provided for @addPropertyDescAr.
  ///
  /// In en, this message translates to:
  /// **'Description (Arabic)'**
  String get addPropertyDescAr;

  /// No description provided for @addPropertyAddressEn.
  ///
  /// In en, this message translates to:
  /// **'Address (English)'**
  String get addPropertyAddressEn;

  /// No description provided for @addPropertyAddressAr.
  ///
  /// In en, this message translates to:
  /// **'Address (Arabic)'**
  String get addPropertyAddressAr;

  /// No description provided for @addPropertyCityEn.
  ///
  /// In en, this message translates to:
  /// **'City (English)'**
  String get addPropertyCityEn;

  /// No description provided for @addPropertyCityAr.
  ///
  /// In en, this message translates to:
  /// **'City (Arabic)'**
  String get addPropertyCityAr;

  /// No description provided for @addPropertyPrice.
  ///
  /// In en, this message translates to:
  /// **'Price (EGP)'**
  String get addPropertyPrice;

  /// No description provided for @addPropertyPricePeriod.
  ///
  /// In en, this message translates to:
  /// **'Price Period (e.g. monthly, total)'**
  String get addPropertyPricePeriod;

  /// No description provided for @addPropertyCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get addPropertyCategory;

  /// No description provided for @addPropertyListingType.
  ///
  /// In en, this message translates to:
  /// **'Listing Type'**
  String get addPropertyListingType;

  /// No description provided for @addPropertyBedrooms.
  ///
  /// In en, this message translates to:
  /// **'Bedrooms'**
  String get addPropertyBedrooms;

  /// No description provided for @addPropertyBathrooms.
  ///
  /// In en, this message translates to:
  /// **'Bathrooms'**
  String get addPropertyBathrooms;

  /// No description provided for @addPropertyArea.
  ///
  /// In en, this message translates to:
  /// **'Area (sqm)'**
  String get addPropertyArea;

  /// No description provided for @addPropertyFurnished.
  ///
  /// In en, this message translates to:
  /// **'Furnished'**
  String get addPropertyFurnished;

  /// No description provided for @addPropertyCoverImage.
  ///
  /// In en, this message translates to:
  /// **'Cover Image URL'**
  String get addPropertyCoverImage;

  /// No description provided for @addPropertySubmit.
  ///
  /// In en, this message translates to:
  /// **'Publish Listing'**
  String get addPropertySubmit;

  /// No description provided for @addPropertySuccess.
  ///
  /// In en, this message translates to:
  /// **'Property published successfully!'**
  String get addPropertySuccess;

  /// No description provided for @addPropertyError.
  ///
  /// In en, this message translates to:
  /// **'Failed to publish property. Please check required fields.'**
  String get addPropertyError;

  /// No description provided for @addPropertyValidationRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get addPropertyValidationRequired;

  /// No description provided for @addPropertyValidationNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid number'**
  String get addPropertyValidationNumber;

  /// No description provided for @authWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get authWelcome;

  /// No description provided for @authWelcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Find and manage properties with ease'**
  String get authWelcomeSubtitle;

  /// No description provided for @authSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get authSignIn;

  /// No description provided for @authSignUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get authSignUp;

  /// No description provided for @authEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get authEmailLabel;

  /// No description provided for @authPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPasswordLabel;

  /// No description provided for @authFullNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get authFullNameLabel;

  /// No description provided for @authPhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get authPhoneLabel;

  /// No description provided for @authForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get authForgotPassword;

  /// No description provided for @authSendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send reset link'**
  String get authSendResetLink;

  /// No description provided for @authOtpTitle.
  ///
  /// In en, this message translates to:
  /// **'Verification'**
  String get authOtpTitle;

  /// No description provided for @authOtpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the 4-digit code sent to your email'**
  String get authOtpSubtitle;

  /// No description provided for @authVerify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get authVerify;

  /// No description provided for @authResendOtp.
  ///
  /// In en, this message translates to:
  /// **'Resend code'**
  String get authResendOtp;

  /// No description provided for @authOrContinue.
  ///
  /// In en, this message translates to:
  /// **'Or continue with'**
  String get authOrContinue;

  /// No description provided for @authDontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Sign Up'**
  String get authDontHaveAccount;

  /// No description provided for @authAlreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign In'**
  String get authAlreadyHaveAccount;

  /// No description provided for @authEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get authEmailRequired;

  /// No description provided for @authEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get authEmailInvalid;

  /// No description provided for @authPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get authPasswordRequired;

  /// No description provided for @authPasswordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get authPasswordTooShort;

  /// No description provided for @authContinueWithEmail.
  ///
  /// In en, this message translates to:
  /// **'Continue with Email'**
  String get authContinueWithEmail;

  /// No description provided for @authForgotPasswordLink.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get authForgotPasswordLink;

  /// No description provided for @authDontHaveAccountShort.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get authDontHaveAccountShort;

  /// No description provided for @authAlreadyHaveAccountShort.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get authAlreadyHaveAccountShort;

  /// No description provided for @authSignInLink.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get authSignInLink;

  /// No description provided for @authRegisterLink.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get authRegisterLink;

  /// No description provided for @authLoginTitle.
  ///
  /// In en, this message translates to:
  /// **'Let\'s Sign In'**
  String get authLoginTitle;

  /// No description provided for @authLoginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome back! Sign in to continue.'**
  String get authLoginSubtitle;

  /// No description provided for @authRegisterTitle.
  ///
  /// In en, this message translates to:
  /// **'Create your account'**
  String get authRegisterTitle;

  /// No description provided for @authRegisterSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Join us to find your dream property.'**
  String get authRegisterSubtitle;

  /// No description provided for @authLoginButton.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get authLoginButton;

  /// No description provided for @authRegisterButton.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get authRegisterButton;

  /// No description provided for @authPasswordRequiredField.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get authPasswordRequiredField;

  /// No description provided for @authTermsOfService.
  ///
  /// In en, this message translates to:
  /// **'By tapping Register, you agree to our Terms of Service & Privacy Policy.'**
  String get authTermsOfService;

  /// No description provided for @authFacebookLogin.
  ///
  /// In en, this message translates to:
  /// **'Facebook Login'**
  String get authFacebookLogin;

  /// No description provided for @authFacebookLoginMessage.
  ///
  /// In en, this message translates to:
  /// **'Facebook Login requires configuring the Facebook App ID in Firebase Console.'**
  String get authFacebookLoginMessage;

  /// No description provided for @authFacebookDialogOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get authFacebookDialogOk;

  /// No description provided for @authReadyTo.
  ///
  /// In en, this message translates to:
  /// **'Ready to '**
  String get authReadyTo;

  /// No description provided for @authExplore.
  ///
  /// In en, this message translates to:
  /// **'explore?'**
  String get authExplore;

  /// No description provided for @authExploreSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Find your dream house easily and experience the comfort of your future home.'**
  String get authExploreSubtitle;

  /// No description provided for @authForgotPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your registered email address and we will send you a link to reset your password.'**
  String get authForgotPasswordSubtitle;

  /// No description provided for @authPasswordResetSent.
  ///
  /// In en, this message translates to:
  /// **'Password reset link sent! Check your inbox and spam folder.'**
  String get authPasswordResetSent;

  /// No description provided for @authResendLink.
  ///
  /// In en, this message translates to:
  /// **'Resend Link'**
  String get authResendLink;

  /// No description provided for @authOtpEnterAllDigits.
  ///
  /// In en, this message translates to:
  /// **'Please enter all 4 digits'**
  String get authOtpEnterAllDigits;

  /// No description provided for @authOtpDispatched.
  ///
  /// In en, this message translates to:
  /// **'A new verification code has been dispatched.'**
  String get authOtpDispatched;

  /// No description provided for @authOtpResendIn.
  ///
  /// In en, this message translates to:
  /// **'Resend code in'**
  String get authOtpResendIn;

  /// No description provided for @editProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get editProfileTitle;

  /// No description provided for @editProfileFullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get editProfileFullName;

  /// No description provided for @editProfileEmail.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get editProfileEmail;

  /// No description provided for @editProfileEmailHelper.
  ///
  /// In en, this message translates to:
  /// **'Email changes require account verification and are not available here.'**
  String get editProfileEmailHelper;

  /// No description provided for @editProfilePhone.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get editProfilePhone;

  /// No description provided for @editProfileNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get editProfileNameRequired;

  /// No description provided for @editProfileSaveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get editProfileSaveChanges;

  /// No description provided for @editProfileChangePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change profile photo'**
  String get editProfileChangePhoto;

  /// No description provided for @editProfileTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get editProfileTryAgain;

  /// No description provided for @editProfileLoadError.
  ///
  /// In en, this message translates to:
  /// **'Profile details could not be loaded.'**
  String get editProfileLoadError;

  /// No description provided for @mapRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get mapRefresh;

  /// No description provided for @mapLoadAllProperties.
  ///
  /// In en, this message translates to:
  /// **'Load All Properties'**
  String get mapLoadAllProperties;

  /// No description provided for @agentDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Agent Details'**
  String get agentDetailsTitle;

  /// No description provided for @agentDetailsTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get agentDetailsTryAgain;

  /// No description provided for @agentDetailsPropertiesError.
  ///
  /// In en, this message translates to:
  /// **'Properties could not be loaded.'**
  String get agentDetailsPropertiesError;

  /// No description provided for @agentDetailsNoProperties.
  ///
  /// In en, this message translates to:
  /// **'This agent has no published properties yet.'**
  String get agentDetailsNoProperties;

  /// No description provided for @agentDetailsPropertiesTitle.
  ///
  /// In en, this message translates to:
  /// **'Agent\'s Properties'**
  String get agentDetailsPropertiesTitle;

  /// No description provided for @agentDetailsPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get agentDetailsPhone;

  /// No description provided for @agentDetailsEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get agentDetailsEmail;

  /// No description provided for @agentDetailsBio.
  ///
  /// In en, this message translates to:
  /// **'Bio'**
  String get agentDetailsBio;

  /// No description provided for @agentDetailsPublishedEstates.
  ///
  /// In en, this message translates to:
  /// **'Published estates'**
  String get agentDetailsPublishedEstates;

  /// No description provided for @searchFilterPriceError.
  ///
  /// In en, this message translates to:
  /// **'Minimum price must not exceed maximum price.'**
  String get searchFilterPriceError;

  /// No description provided for @searchFilterInvalidPrice.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid price'**
  String get searchFilterInvalidPrice;

  /// No description provided for @searchFilterInvalidNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a whole number'**
  String get searchFilterInvalidNumber;

  /// No description provided for @chatNoMessages.
  ///
  /// In en, this message translates to:
  /// **'No messages yet. Start the conversation.'**
  String get chatNoMessages;

  /// No description provided for @chatMessageHint.
  ///
  /// In en, this message translates to:
  /// **'Write a message...'**
  String get chatMessageHint;

  /// No description provided for @chatSignInToSend.
  ///
  /// In en, this message translates to:
  /// **'Sign in to send a message'**
  String get chatSignInToSend;

  /// No description provided for @chatSendTooltip.
  ///
  /// In en, this message translates to:
  /// **'Send message'**
  String get chatSendTooltip;

  /// No description provided for @galleryViewAll.
  ///
  /// In en, this message translates to:
  /// **'View all photos'**
  String get galleryViewAll;

  /// No description provided for @onboarding1Title.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Real Estate App'**
  String get onboarding1Title;

  /// No description provided for @onboarding1Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Discover your dream home with ease'**
  String get onboarding1Subtitle;

  /// No description provided for @onboarding2Title.
  ///
  /// In en, this message translates to:
  /// **'Smart Search & Filters'**
  String get onboarding2Title;

  /// No description provided for @onboarding2Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Find properties that match your criteria'**
  String get onboarding2Subtitle;

  /// No description provided for @onboarding3Title.
  ///
  /// In en, this message translates to:
  /// **'Connect with Agents'**
  String get onboarding3Title;

  /// No description provided for @onboarding3Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Chat directly with verified agents'**
  String get onboarding3Subtitle;

  /// No description provided for @onboardingGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get onboardingGetStarted;

  /// No description provided for @onboardingSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkip;

  /// No description provided for @faqTitle.
  ///
  /// In en, this message translates to:
  /// **'Frequently Asked Questions'**
  String get faqTitle;

  /// No description provided for @faqSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search questions...'**
  String get faqSearchHint;

  /// No description provided for @faqNoResults.
  ///
  /// In en, this message translates to:
  /// **'No questions found matching your search.'**
  String get faqNoResults;

  /// No description provided for @faqExpand.
  ///
  /// In en, this message translates to:
  /// **'Expand'**
  String get faqExpand;

  /// No description provided for @faqCollapse.
  ///
  /// In en, this message translates to:
  /// **'Collapse'**
  String get faqCollapse;

  /// No description provided for @commonOr.
  ///
  /// In en, this message translates to:
  /// **'Or'**
  String get commonOr;

  /// No description provided for @commonBullet.
  ///
  /// In en, this message translates to:
  /// **' • '**
  String get commonBullet;

  /// No description provided for @commonTermsAndPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service & Privacy Policy'**
  String get commonTermsAndPrivacy;

  /// No description provided for @offlineNotice.
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Some features may be unavailable.'**
  String get offlineNotice;

  /// No description provided for @bookingTitle.
  ///
  /// In en, this message translates to:
  /// **'Book a Visit'**
  String get bookingTitle;

  /// No description provided for @bookingSuccess.
  ///
  /// In en, this message translates to:
  /// **'Visit booked successfully!'**
  String get bookingSuccess;

  /// No description provided for @bookingDuplicateError.
  ///
  /// In en, this message translates to:
  /// **'You already have a booking for this date and time slot.'**
  String get bookingDuplicateError;

  /// No description provided for @bookingError.
  ///
  /// In en, this message translates to:
  /// **'Booking failed.'**
  String get bookingError;

  /// No description provided for @bookingCustomerSection.
  ///
  /// In en, this message translates to:
  /// **'Your Details'**
  String get bookingCustomerSection;

  /// No description provided for @bookingCustomerName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get bookingCustomerName;

  /// No description provided for @bookingFieldRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get bookingFieldRequired;

  /// No description provided for @bookingCustomerEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get bookingCustomerEmail;

  /// No description provided for @bookingEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get bookingEmailInvalid;

  /// No description provided for @bookingCustomerPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get bookingCustomerPhone;

  /// No description provided for @bookingPhoneInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid phone number'**
  String get bookingPhoneInvalid;

  /// No description provided for @bookingScheduleSection.
  ///
  /// In en, this message translates to:
  /// **'Visit Schedule'**
  String get bookingScheduleSection;

  /// No description provided for @bookingDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Visit Date'**
  String get bookingDateLabel;

  /// No description provided for @bookingTimeSlotLabel.
  ///
  /// In en, this message translates to:
  /// **'Time Slot'**
  String get bookingTimeSlotLabel;

  /// No description provided for @bookingNotesLabel.
  ///
  /// In en, this message translates to:
  /// **'Additional Notes (optional)'**
  String get bookingNotesLabel;

  /// No description provided for @bookingNotesHint.
  ///
  /// In en, this message translates to:
  /// **'Any special requests or questions for the agent...'**
  String get bookingNotesHint;

  /// No description provided for @bookingSubmit.
  ///
  /// In en, this message translates to:
  /// **'Confirm Booking'**
  String get bookingSubmit;

  /// No description provided for @myBookingsTitle.
  ///
  /// In en, this message translates to:
  /// **'My Bookings'**
  String get myBookingsTitle;

  /// No description provided for @myBookingsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No bookings yet.'**
  String get myBookingsEmpty;

  /// No description provided for @myBookingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Book a visit to any property to get started.'**
  String get myBookingsSubtitle;

  /// No description provided for @bookingDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Booking Details'**
  String get bookingDetailsTitle;

  /// No description provided for @bookingStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get bookingStatusLabel;

  /// No description provided for @bookingPropertySnapshot.
  ///
  /// In en, this message translates to:
  /// **'Property'**
  String get bookingPropertySnapshot;

  /// No description provided for @bookingCancelTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel Booking?'**
  String get bookingCancelTitle;

  /// No description provided for @bookingCancelConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel this booking? This action cannot be undone.'**
  String get bookingCancelConfirm;

  /// No description provided for @bookingCancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel Booking'**
  String get bookingCancelButton;

  /// No description provided for @bookingCancelSuccess.
  ///
  /// In en, this message translates to:
  /// **'Booking cancelled.'**
  String get bookingCancelSuccess;

  /// No description provided for @detailsBookVisit.
  ///
  /// In en, this message translates to:
  /// **'Book a Visit'**
  String get detailsBookVisit;

  /// No description provided for @detailsBookVisitLoginPrompt.
  ///
  /// In en, this message translates to:
  /// **'Please sign in to book a visit.'**
  String get detailsBookVisitLoginPrompt;

  /// No description provided for @detailsEstateUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This property is currently unavailable for booking.'**
  String get detailsEstateUnavailable;

  /// No description provided for @profileMyBookingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'View and manage your tour requests'**
  String get profileMyBookingsSubtitle;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @notificationsMarkAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all read'**
  String get notificationsMarkAllRead;

  /// No description provided for @notificationsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet.'**
  String get notificationsEmpty;

  /// No description provided for @profileNotificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'View your activity and updates'**
  String get profileNotificationsSubtitle;
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
      <String>['ar', 'en'].contains(locale.languageCode);

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
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
