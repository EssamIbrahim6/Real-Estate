# Premium UI/UX Transformation Plan

## Repository State (baseline)
- Branch: `main`, commit `7ae89e5` ("refactor"), working tree clean.
- Flutter 3.47.5, Dart 3.13.4.
- No prior uncommitted changes exist; no `transformation_plan.md` existed before this plan.
- Architecture: feature-based folders with `data/domain/presentation` (BLoC/Cubit + go_router).
- Shared widgets live in `lib/core/widgets/`: `app_button.dart`, `app_card.dart`, `app_text_field.dart`, `app_empty_state.dart`, `app_error_view.dart`, `app_skeleton.dart`, `app_loading_indicator.dart`, `app_feedback.dart`, `person_avatar.dart`.
- Auth widgets live in `lib/features/auth/presentation/widgets/`: `auth_header.dart`, `auth_text_field.dart`, `social_auth_button.dart`, `app_back_button.dart`, `otp_input_boxes.dart`.
- Theme: `lib/core/theme/app_theme.dart` (Material 3 `ColorScheme` light/dark), `app_text_styles.dart` (static text styles, largely unused by screens), `theme_cubit.dart` (system/light/dark preference).
- Dimensions: `lib/core/constants/app_dimensions.dart`. Colors: `lib/core/constants/app_colors.dart`.
- Localization: ARB files `lib/l10n/app_en.arb` / `app_ar.arb`, generated `app_localizations.dart`.

## Screens inventory
Auth: welcome_screen, login_screen, register_screen, forgot_password_screen, otp_verification_screen.
Core: home_screen, search_screen, listings_screen, category_estates_screen, estate_details_screen, fullscreen_gallery_screen, favorites_screen, profile_screen, edit_profile_screen, settings_screen, chat_screen, conversation_screen, agent_details_screen.
Booking: book_tour_screen, booking_details_screen, booking_history_screen.
Notifications: notifications_screen.
Secondary: onboarding, account_setup (location/preferences/payment/personal-info/support), faq_support, map, add_property.

## Guiding principles (Premium redesign)
1. Preserve all existing business logic, cubits, validation, navigation, localization, and auth behavior. No accidental logic changes.
2. Reuse existing shared widgets; avoid duplicate components and unnecessary new dependencies.
3. Improve visual design, not just theme colors: hierarchy, spacing, typography, interactions.
4. Consistent use of `AppTextStyles`/theme `textTheme` and `AppDimensions`.
5. Add meaningful skeleton (`AppSkeleton`/*), empty (`AppEmptyState`), error (`AppErrorView`), and success states.
6. Verify Arabic (RTL) and English (LTR) layouts; verify Light and Dark themes (contrast).
7. Work one group at a time: implement -> `flutter analyze` -> tests -> review diff -> fix regressions -> update plan.

## Execution order (groups)
Group 0: Validation & shared components (auth_header, auth_text_field, social_auth_button, app_text_field, welcome, login, register, notifications_screen, booking_history_screen + the 9 shared widgets).
Group 1: Auth screens (welcome, login, register, forgot_password, otp_verification).
Group 2: Home screen + home widgets (estate_card, category_card, agent_card, location_card, section_header, home_header, home_search_bar).
Group 3: Search & AI Search.
Group 4: Listings & Category screens.
Group 5: Estate Details & Image Gallery (fullscreen gallery).
Group 6: Favorites.
Group 7: Profile & Edit Profile & Settings.
Group 8: Booking screens (book_tour, booking_details, booking_history).
Group 9: Chat & Conversation.
Group 10: Agent Details & Reviews.
Group 11: Remaining secondary screens.

## Definition of done per group
- `flutter analyze --no-pub` clean (no new issues).
- Relevant `flutter test` pass.
- Diff reviewed; no business-logic changes.
- Light/Dark + en/ar visually consistent.
- `transformation_plan.md` updated with group status.

## Final verification (complete)
- `flutter analyze --no-pub`: No issues found.
- `flutter test`: All 124 tests passed.
- `flutter build apk --debug`: `√ Built build\app\outputs\flutter-apk\app-debug.apk` (only pre-existing Gradle/Kotlin-plugin warnings from firebase plugins).

## Groups completed (all)
Group 0: Validation & shared components — app_error_view enhanced (icon container + Try again button), auth_header + social_auth_button polished with theme typography; validation files reviewed (welcome, login, register, forgot_password, otp, notifications, booking_history) with dark-theme regressions fixed in forgot_password/otp (hardcoded white surface + brandNavy text → theme colorScheme).
Group 1: Auth screens — forgot_password & otp_verification theme-aware.
Group 2: Home — estate_card adds availability badge + refined price/location; home_screen empties/errors use consistent inline states.
Group 3: Search — empty state uses AppEmptyState.
Group 4: Listings & Category — empty states use AppEmptyState; category scaffold dark-theme fixed.
Group 5: Estate Details & Image Gallery — already premium-quality (shared skeleton, AppErrorView, sticky contact bar); inspected, no logic changes.
Group 6: Favorites — error/empty states use AppErrorView/AppEmptyState.
Group 7: Profile & Edit Profile & Settings — _SignedOutView/_ProfileLoadError use AppEmptyState/AppErrorView; edit profile name/phone use AppTextField.
Group 8: Booking — booking_history already used shared states; book_tour/booking_details functional with AppButton/AppFeedback.
Group 9: Chat & Conversation — empty states use AppEmptyState.
Group 10: Agent Details & Reviews — error state uses AppErrorView.
Group 11: Secondary screens — scaffold backgrounds (faq, onboarding, preferences, location, account_success, personal_info, payment_method) use theme surface for dark-theme support.

## Unfinished / out of scope
- book_tour_screen still uses inline TextFormFields (retained to preserve phone `inputFormatters` behavior); functional and theme-consistent via InputDecorationTheme.
- estate_favorite_button.dart uses a white CircleAvatar background (minor, acceptable in both themes).
- Secondary screens retain brand accent colors (brandGreen) as intentional brand; only surfaces fixed for dark theme.
