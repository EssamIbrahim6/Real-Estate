import 'package:real_estate_app/features/search/domain/entities/search_filter.dart';

class SmartSearchParser {
  static final Map<String, String> _propertyTypeMap = {
    'apartment': 'apartment',
    'شقة': 'apartment',
    'شقه': 'apartment',
    'villa': 'villa',
    'فيلا': 'villa',
    'house': 'house',
    'منزل': 'house',
    'بيت': 'house',
    'studio': 'studio',
    'استوديو': 'studio',
    'office': 'office',
    'مكتب': 'office',
    'chalet': 'chalet',
    'شاليه': 'chalet',
  };

  static final Map<String, String> _cityMap = {
    'cairo': 'Cairo',
    'القاهرة': 'Cairo',
    'القاهره': 'Cairo',
    'giza': 'Giza',
    'الجيزة': 'Giza',
    'الجيزه': 'Giza',
    'alexandria': 'Alexandria',
    'الإسكندرية': 'Alexandria',
    'الاسكندرية': 'Alexandria',
    'اسكندرية': 'Alexandria',
  };

  static SearchFilter parse(String query, {SearchFilter? existing}) {
    final normalized = _normalizeArabic(query);
    final lower = normalized.toLowerCase();

    String? categoryId;
    String? city;
    double? minPrice;
    double? maxPrice;
    int? bedrooms;
    int? bathrooms;
    bool? isFurnished;
    String? listingType;
    final remainingTerms = <String>[];

    final tokens = lower.split(RegExp(r'\s+'));

    // Property type
    for (final entry in _propertyTypeMap.entries) {
      if (lower.contains(entry.key)) {
        categoryId = entry.value;
        break;
      }
    }

    // City
    for (final entry in _cityMap.entries) {
      if (lower.contains(entry.key)) {
        city = entry.value;
        break;
      }
    }

    // Price: "less than X", "under X", "أقل من X"
    final maxPriceRegex = RegExp(
      r'(?:أقل\s*من|under|less\s*than|max)\s*([\d٠-٩]+)',
    );
    final minPriceRegex = RegExp(
      r'(?:أكثر\s*من|over|more\s*than|min)\s*([\d٠-٩]+)',
    );

    final maxMatch = maxPriceRegex.firstMatch(normalized);
    if (maxMatch != null) {
      maxPrice = _parseNumber(maxMatch.group(1)!);
    }
    final minMatch = minPriceRegex.firstMatch(normalized);
    if (minMatch != null) {
      minPrice = _parseNumber(minMatch.group(1)!);
    }

    // Bedrooms: "3 bedrooms", "٣ غرف"
    final bedroomRegex = RegExp(r'([\d٠-٩]+)\s*(?:bedrooms?|غرف|غرفة)');
    final bedroomMatch = bedroomRegex.firstMatch(normalized);
    if (bedroomMatch != null) {
      bedrooms = _parseNumber(bedroomMatch.group(1)!).toInt();
    }

    // Bathrooms
    final bathroomRegex = RegExp(r'([\d٠-٩]+)\s*(?:bathrooms?|حمامات|حمام)');
    final bathroomMatch = bathroomRegex.firstMatch(normalized);
    if (bathroomMatch != null) {
      bathrooms = _parseNumber(bathroomMatch.group(1)!).toInt();
    }

    // Furnished
    if (lower.contains('مفروش') || lower.contains('furnished')) {
      isFurnished = true;
    }
    if (lower.contains('غير مفروش') || lower.contains('unfurnished')) {
      isFurnished = false;
    }

    // Rent/Sale
    if (lower.contains('للإيجار') || lower.contains('for rent') || lower.contains('rent')) {
      listingType = 'rent';
    }
    if (lower.contains('للبيع') || lower.contains('for sale') || lower.contains('sale')) {
      listingType = 'sale';
    }

    // Remaining text terms
    for (final token in tokens) {
      if (!_propertyTypeMap.containsKey(token) &&
          !_cityMap.containsKey(token) &&
          !RegExp(r'^[\d٠-٩]+$').hasMatch(token)) {
        remainingTerms.add(token);
      }
    }

    final queryText = remainingTerms.join(' ').trim();

    return SearchFilter(
      query: queryText.isEmpty ? existing?.query : queryText,
      categoryId: categoryId ?? existing?.categoryId,
      city: city ?? existing?.city,
      minPrice: minPrice ?? existing?.minPrice,
      maxPrice: maxPrice ?? existing?.maxPrice,
      bedrooms: bedrooms ?? existing?.bedrooms,
      bathrooms: bathrooms ?? existing?.bathrooms,
      isFurnished: isFurnished ?? existing?.isFurnished,
      listingType: listingType ?? existing?.listingType,
      isAvailable: existing?.isAvailable ?? true,
    );
  }

  static String _normalizeArabic(String input) {
    return input
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ة', 'ه')
        .replaceAll('ى', 'ي')
        .replaceAll(RegExp(r'[\u064B-\u065F]'), '');
  }

  static double _parseNumber(String value) {
    final western = value
        .replaceAll('٠', '0')
        .replaceAll('١', '1')
        .replaceAll('٢', '2')
        .replaceAll('٣', '3')
        .replaceAll('٤', '4')
        .replaceAll('٥', '5')
        .replaceAll('٦', '6')
        .replaceAll('٧', '7')
        .replaceAll('٨', '8')
        .replaceAll('٩', '9');
    return double.tryParse(western.replaceAll(',', '')) ?? 0;
  }
}
