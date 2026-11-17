import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_app/core/theme/app_theme.dart';
import 'package:real_estate_app/features/estate/domain/entities/estate_entity.dart';
import 'package:real_estate_app/features/estate_details/presentation/widgets/property_info_section.dart';
import 'package:real_estate_app/l10n/generated/app_localizations.dart';

void main() {
  testWidgets('property facts fit narrow English and Arabic themes', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final estate = _estate();
    for (final (size, theme, locale) in [
      (const Size(320, 640), AppTheme.lightTheme, const Locale('en')),
      (const Size(320, 640), AppTheme.darkTheme, const Locale('ar')),
      (const Size(900, 1000), AppTheme.lightTheme, const Locale('ar')),
      (const Size(900, 1000), AppTheme.darkTheme, const Locale('en')),
    ]) {
      tester.view.physicalSize = size;
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          locale: locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: Scaffold(
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: PropertyInfoSection(estate: estate),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(PropertyInfoSection), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });
}

EstateEntity _estate() => EstateEntity(
  id: 'estate-1',
  title: 'Family home',
  description: 'A spacious family home.',
  price: 2500000,
  listingType: 'sale',
  categoryId: 'house',
  agentId: 'agent-1',
  location: const EstateLocationEntity(
    address: 'Street 1',
    city: 'Cairo',
    latitude: 30,
    longitude: 31,
  ),
  coverImage: '',
  images: const [],
  bedrooms: 3,
  bathrooms: 2,
  area: 145,
  isFurnished: false,
  amenities: const [],
  rating: 4.5,
  reviewCount: 12,
  isFeatured: false,
  isAvailable: true,
  status: 'active',
);
