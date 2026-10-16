import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class LocaleState extends Equatable {
  final Locale locale;
  final bool isLoaded;
  final String? error;

  const LocaleState({
    this.locale = const Locale('en'),
    this.isLoaded = false,
    this.error,
  });

  bool get isArabic => locale.languageCode == 'ar';
  bool get isEnglish => locale.languageCode == 'en';
  TextDirection get textDirection =>
      isArabic ? TextDirection.rtl : TextDirection.ltr;

  LocaleState copyWith({
    Locale? locale,
    bool? isLoaded,
    String? error,
  }) {
    return LocaleState(
      locale: locale ?? this.locale,
      isLoaded: isLoaded ?? this.isLoaded,
      error: error,
    );
  }

  @override
  List<Object?> get props => [locale, isLoaded, error];
}

