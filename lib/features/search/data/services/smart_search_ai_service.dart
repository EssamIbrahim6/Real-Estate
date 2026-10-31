import 'dart:convert';

import 'package:firebase_ai/firebase_ai.dart';
import 'package:real_estate_app/features/search/domain/entities/search_filter.dart';

class SmartSearchCriteria {
  final String intent;
  final String? city;
  final String? propertyType;
  final String? listingType;
  final double? minPrice;
  final double? maxPrice;
  final String currency;
  final String? pricePeriod;
  final int? bedrooms;
  final int? bathrooms;
  final bool? furnished;
  final List<String> keywords;
  final List<String> preferences;
  final String? sortBy;
  final String? clarificationQuestion;

  const SmartSearchCriteria({
    this.intent = 'property_search',
    this.city,
    this.propertyType,
    this.listingType,
    this.minPrice,
    this.maxPrice,
    this.currency = 'EGP',
    this.pricePeriod,
    this.bedrooms,
    this.bathrooms,
    this.furnished,
    this.keywords = const [],
    this.preferences = const [],
    this.sortBy,
    this.clarificationQuestion,
  });

  factory SmartSearchCriteria.fromJson(Map<String, dynamic> json) {
    String? asString(dynamic v) => v is String ? v : null;
    double? asDouble(dynamic v) {
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v);
      return null;
    }

    int? asInt(dynamic v) {
      if (v is int) return v;
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v);
      return null;
    }

    bool? asBool(dynamic v) {
      if (v is bool) return v;
      if (v is String) {
        if (v.toLowerCase() == 'true') return true;
        if (v.toLowerCase() == 'false') return false;
      }
      return null;
    }

    List<String> asList(dynamic v) {
      if (v is List) {
        return v.whereType<String>().map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      }
      return const [];
    }

    const intents = {'property_search', 'refine_search', 'clarify'};
    const propertyTypes = {'apartment', 'villa', 'house', 'studio', 'office', 'chalet'};
    const listingTypes = {'rent', 'sale'};
    const sortOptions = {'price_asc', 'price_desc'};

    final intent = asString(json['intent']);
    final propertyType = asString(json['property_type']);
    final listingType = asString(json['listing_type']);
    final sortBy = asString(json['sort_by']);

    return SmartSearchCriteria(
      intent: intents.contains(intent) ? intent! : 'property_search',
      city: asString(json['city']),
      propertyType: propertyTypes.contains(propertyType) ? propertyType : null,
      listingType: listingTypes.contains(listingType) ? listingType : null,
      minPrice: asDouble(json['min_price']),
      maxPrice: asDouble(json['max_price']),
      currency: asString(json['currency']) ?? 'EGP',
      pricePeriod: asString(json['price_period']),
      bedrooms: asInt(json['bedrooms']),
      bathrooms: asInt(json['bathrooms']),
      furnished: asBool(json['furnished']),
      keywords: asList(json['keywords']),
      preferences: asList(json['preferences']),
      sortBy: sortOptions.contains(sortBy) ? sortBy : null,
      clarificationQuestion: asString(json['clarification_question']),
    );
  }

  static SmartSearchCriteria parseJson(String raw) {
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Expected JSON object');
    }
    return SmartSearchCriteria.fromJson(decoded);
  }

  SearchFilter toSearchFilter(SearchFilter existing, {String? queryOverride}) {
    return SearchFilter(
      query: queryOverride ?? (keywords.isNotEmpty ? keywords.join(' ') : existing.query),
      categoryId: propertyType ?? existing.categoryId,
      city: city ?? existing.city,
      minPrice: minPrice ?? existing.minPrice,
      maxPrice: maxPrice ?? existing.maxPrice,
      bedrooms: bedrooms ?? existing.bedrooms,
      bathrooms: bathrooms ?? existing.bathrooms,
      isFurnished: furnished ?? existing.isFurnished,
      listingType: listingType ?? existing.listingType,
      isAvailable: existing.isAvailable,
    );
  }
}

class SmartSearchAiService {
  final GenerativeModel _model;

  SmartSearchAiService(this._model);

  static SmartSearchAiService fromFirebase() {
    final model = FirebaseAI.googleAI().generativeModel(model: 'gemini-2.0-flash');
    return SmartSearchAiService(model);
  }

  Future<SmartSearchCriteria> parse(String query, {SmartSearchCriteria? previous}) async {
    final prompt = '''
You are a real estate search assistant. Convert the user query into JSON only, no markdown.
Schema: {"intent":"property_search","city":null,"property_type":null,"listing_type":null,"min_price":null,"max_price":null,"currency":"EGP","price_period":null,"bedrooms":null,"bathrooms":null,"furnished":null,"keywords":[],"preferences":[],"sort_by":null,"clarification_question":null}
Allowed: intent property_search/refine_search/clarify; property_type apartment/villa/house/studio/office/chalet; listing_type rent/sale; sort_by price_asc/price_desc.
Parse Arabic-Indic digits. Do not infer monthly/yearly unless explicit. Distinguish bedrooms from generic rooms. Use previous context for refinement. Return JSON only.
Previous: ${previous == null ? 'none' : 'provided'}
Query: $query
''';
    final response = await _model.generateContent([Content.text(prompt)]);
    final text = response.text ?? '';
    final cleaned = text.trim().replaceAll(RegExp(r'^```json\s*|\s*```$'), '');
    return SmartSearchCriteria.parseJson(cleaned);
  }
}