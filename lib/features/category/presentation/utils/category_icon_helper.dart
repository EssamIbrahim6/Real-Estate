import 'package:flutter/material.dart';

import '../../../../l10n/generated/app_localizations.dart';

class CategoryIconHelper {
  const CategoryIconHelper._();

  /// Returns a distinct, recognizable icon for each property category.
  static IconData getIcon(String? categoryId, [String? categoryName]) {
    final key = (categoryId ?? categoryName ?? '').trim().toLowerCase();

    if (key.contains('apartment') || key.contains('flat') || key.contains('شقة')) {
      return Icons.apartment_rounded;
    }
    if (key.contains('villa') || key.contains('فيلا')) {
      return Icons.villa_rounded;
    }
    if (key.contains('house') || key.contains('home') || key.contains('منزل')) {
      return Icons.house_rounded;
    }
    if (key.contains('office') || key.contains('مكتب')) {
      return Icons.business_center_rounded;
    }
    if (key.contains('studio') || key.contains('استوديو')) {
      return Icons.single_bed_rounded;
    }
    if (key.contains('commercial') ||
        key.contains('retail') ||
        key.contains('shop') ||
        key.contains('store') ||
        key.contains('تجاري')) {
      return Icons.storefront_rounded;
    }
    if (key.contains('townhouse') || key.contains('تاون')) {
      return Icons.location_city_rounded;
    }
    if (key.contains('penthouse') || key.contains('بنتهاوس')) {
      return Icons.roofing_rounded;
    }
    if (key.contains('land') || key.contains('plot') || key.contains('أرض')) {
      return Icons.landscape_rounded;
    }
    if (key.contains('chalet') || key.contains('cabin') || key.contains('شاليه')) {
      return Icons.cottage_rounded;
    }
    if (key.contains('building') || key.contains('عمارة') || key.contains('مبنى')) {
      return Icons.domain_rounded;
    }

    return Icons.home_work_rounded;
  }

  /// Returns a localized category display name.
  static String getLocalizedName(
    BuildContext context,
    String? categoryId, [
    String? fallbackName,
  ]) {
    final l10n = AppLocalizations.of(context);
    final key = (categoryId ?? fallbackName ?? '').trim().toLowerCase();

    if (key.contains('apartment') || key.contains('flat')) {
      return l10n?.categoryApartment ?? fallbackName ?? 'Apartment';
    }
    if (key.contains('villa')) {
      return l10n?.categoryVilla ?? fallbackName ?? 'Villa';
    }
    if (key.contains('house') || key.contains('home')) {
      return l10n?.categoryHouse ?? fallbackName ?? 'House';
    }
    if (key.contains('office')) {
      return l10n?.categoryOffice ?? fallbackName ?? 'Office';
    }
    if (key.contains('studio')) {
      return l10n?.categoryStudio ?? fallbackName ?? 'Studio';
    }
    if (key.contains('commercial') || key.contains('shop')) {
      return l10n?.categoryCommercial ?? fallbackName ?? 'Commercial';
    }
    if (key.contains('townhouse')) {
      return l10n?.categoryTownhouse ?? fallbackName ?? 'Townhouse';
    }
    if (key.contains('penthouse')) {
      return l10n?.categoryPenthouse ?? fallbackName ?? 'Penthouse';
    }
    if (key.contains('land')) {
      return l10n?.categoryLand ?? fallbackName ?? 'Land';
    }
    if (key.contains('chalet')) {
      return l10n?.categoryChalet ?? fallbackName ?? 'Chalet';
    }

    return fallbackName ?? categoryId ?? '';
  }
}
