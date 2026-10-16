/// Pre-reviewed and curated Arabic translations for real estate listings in Egypt.
/// Used by the migration tool to provide natural Arabic descriptions,
/// titles, addresses, and city names without external paid APIs.
library;

class EstateTranslations {
  static const Map<String, String> cityTranslations = {
    'Cairo': 'القاهرة',
    'Giza': 'الجيزة',
    'Suez': 'السويس',
    'North Coast': 'الساحل الشمالي',
    'New Capital': 'العاصمة الإدارية',
    'Alexandria': 'الإسكندرية',
    'Red Sea': 'البحر الأحمر',
    'South Sinai': 'جنوب سيناء',
  };

  static const Map<String, String> addressTranslations = {
    'Palm Hills Compound, Sheikh Zayed, Giza':
        'كمبوند بالم هيلز، الشيخ زايد، الجيزة',
    'Mivida, Fifth Settlement, Cairo': 'ميفيدا، التجمع الخامس، القاهرة',
    'Abbas El Akkad, Nasr City, Cairo': 'عباس العقاد، مدينة نصر، القاهرة',
    'Street 9, Maadi, Cairo': 'شارع 9، المعادي، القاهرة',
    'Marassi, North Coast': 'مراسي، الساحل الشمالي',
    'Government District, New Administrative Capital':
        'الحي الحكومي، العاصمة الإدارية الجديدة',
    'Group 12, Madinaty, Cairo': 'مجموعة 12، مدينتي، القاهرة',
    'Zaafarana, Ain Sokhna': 'الزعفرانة، العين السخنة',
    'Brazil Street, Zamalek, Cairo': 'شارع البرازيل، الزمالك، القاهرة',
    'New Sheikh Zayed, 6th of October, Giza':
        'الشيخ زايد الجديدة، السادس من أكتوبر، الجيزة',
  };

  static const Map<String, Map<String, String>> knownEstates = {
    'Luxury Apartment with Garden View': {
      'titleAr': 'شقة فاخرة بإطلالة على الحديقة',
      'descriptionAr':
          'شقة واسعة مكونة من 3 غرف نوم بتشطيب سوبر لوكس في كمبوند راقٍ بالشيخ زايد، بالقرب من مول العرب وجميع الخدمات والمرافق.',
      'cityAr': 'الجيزة',
      'addressAr': 'كمبوند بالم هيلز، الشيخ زايد، الجيزة',
    },
    'Standalone Villa with Pool and Garden': {
      'titleAr': 'فيلا مستقلة بحمام سباحة وحديقة',
      'descriptionAr':
          'فيلا تاون هاوس بالتجمع الخامس، 5 غرف نوم، حديقة بمساحة 200 متر مربع، تصميم عصري راقٍ ومتكامل.',
      'cityAr': 'القاهرة',
      'addressAr': 'ميفيدا، التجمع الخامس، القاهرة',
    },
    'Fully Furnished Studio Apartment': {
      'titleAr': 'استوديو مفروش بالكامل',
      'descriptionAr':
          'استوديو بمساحة 45 متراً مربعاً مفروش بالكامل مع مدخل خاص، مثالي للطلاب وحديثي التخرج، قريب من محطة المترو.',
      'cityAr': 'القاهرة',
      'addressAr': 'عباس العقاد، مدينة نصر، القاهرة',
    },
    'Quiet Apartment in Maadi': {
      'titleAr': 'شقة هادئة في المعادي',
      'descriptionAr':
          'شقة غرفتي نوم في شارع هادئ بالمعادي، مشمسة بالكامل وقريبة من كورنيش النيل.',
      'cityAr': 'القاهرة',
      'addressAr': 'شارع 9، المعادي، القاهرة',
    },
    'Beachfront Chalet with Sea View': {
      'titleAr': 'شاليه على الشاطئ بإطلالة بحرية',
      'descriptionAr':
          'شاليه في الساحل الشمالي بإطلالة مباشرة على البحر، غرفتي نوم مع تراس واسع وإمكانية الدخول للشاطئ.',
      'cityAr': 'الساحل الشمالي',
      'addressAr': 'مراسي، الساحل الشمالي',
    },
    'Administrative Office in New Capital': {
      'titleAr': 'مكتب إداري في العاصمة الإدارية',
      'descriptionAr':
          'مكتب بمساحة 120 متراً مربعاً في برج أعمال بالعاصمة الإدارية الجديدة، تشطيب كامل مع إنترنت ألياف ضوئية.',
      'cityAr': 'العاصمة الإدارية',
      'addressAr': 'الحي الحكومي، العاصمة الإدارية الجديدة',
    },
    'Twin House in Madinaty': {
      'titleAr': 'توين هاوس في مدينتي',
      'descriptionAr':
          'توين هاوس مكون من 4 غرف نوم مع حديقة أمامية وخلفية في مدينتي، جاهز للسكن الفوري.',
      'cityAr': 'القاهرة',
      'addressAr': 'مجموعة 12، مدينتي، القاهرة',
    },
    'Cozy Cottage with Mountain View': {
      'titleAr': 'كوخ دافئ بإطلالة جبلية',
      'descriptionAr':
          'كوخ خشبي دافئ بإطلالة خلابة على الجبل في العين السخنة، مثالي للعطلات والإجازات الأسبوعية.',
      'cityAr': 'السويس',
      'addressAr': 'الزعفرانة، العين السخنة',
    },
    'Classic Apartment in Zamalek': {
      'titleAr': 'شقة كلاسيكية في الزمالك',
      'descriptionAr':
          'شقة واسعة مكونة من 3 غرف نوم في مبنى تاريخي بالزمالك، أسقف مرتفعة وأرضيات باركيه فاخرة.',
      'cityAr': 'القاهرة',
      'addressAr': 'شارع البرازيل، الزمالك، القاهرة',
    },
    'Modern Villa in 6th of October': {
      'titleAr': 'فيلا عصرية في السادس من أكتوبر',
      'descriptionAr':
          'فيلا بمساحة 350 متراً مربعاً في الشيخ زايد الجديدة بتصميم معماري حديث مع حمام سباحة خاص.',
      'cityAr': 'الجيزة',
      'addressAr': 'الشيخ زايد الجديدة، السادس من أكتوبر، الجيزة',
    },
  };

  /// Translates city name, returning Arabic version if known or original.
  static String translateCity(String city) {
    final trimmed = city.trim();
    return cityTranslations[trimmed] ?? trimmed;
  }

  /// Translates address string, returning Arabic version if known or original.
  static String translateAddress(String address) {
    final trimmed = address.trim();
    if (addressTranslations.containsKey(trimmed)) {
      return addressTranslations[trimmed]!;
    }
    // Partial replacement for common Egyptian districts
    String result = trimmed;
    cityTranslations.forEach((en, ar) {
      result = result.replaceAll(en, ar);
    });
    result = result
        .replaceAll('Zamalek', 'الزمالك')
        .replaceAll('Maadi', 'المعادي')
        .replaceAll('Fifth Settlement', 'التجمع الخامس')
        .replaceAll('Sheikh Zayed', 'الشيخ زايد')
        .replaceAll('Nasr City', 'مدينة نصر')
        .replaceAll('New Cairo', 'القاهرة الجديدة')
        .replaceAll('Compound', 'كمبوند')
        .replaceAll('Street', 'شارع')
        .replaceAll('Madinaty', 'مدينتي');
    return result;
  }

  /// Translates an estate title to Arabic if known, or provides sensible Arabic fallback.
  static String translateTitle(String title) {
    final trimmed = title.trim();
    if (knownEstates.containsKey(trimmed)) {
      return knownEstates[trimmed]!['titleAr']!;
    }
    String result = trimmed;
    result = result
        .replaceAll('Luxury Apartment', 'شقة فاخرة')
        .replaceAll('Modern Villa', 'فيلا عصرية')
        .replaceAll('Standalone Villa', 'فيلا مستقلة')
        .replaceAll('Apartment', 'شقة')
        .replaceAll('Villa', 'فيلا')
        .replaceAll('Studio', 'استوديو')
        .replaceAll('Office', 'مكتب إداري')
        .replaceAll('Chalet', 'شاليه')
        .replaceAll('Cottage', 'كوخ')
        .replaceAll('House', 'منزل')
        .replaceAll('Twin House', 'توين هاوس')
        .replaceAll('in Zamalek', 'في الزمالك')
        .replaceAll('in Maadi', 'في المعادي')
        .replaceAll('in New Cairo', 'في القاهرة الجديدة')
        .replaceAll('in Sheikh Zayed', 'في الشيخ زايد')
        .replaceAll('in Nasr City', 'في مدينة نصر');
    return result;
  }

  /// Translates an estate description to Arabic if known.
  static String translateDescription(String description, {String? title}) {
    if (title != null && knownEstates.containsKey(title.trim())) {
      return knownEstates[title.trim()]!['descriptionAr']!;
    }
    return description;
  }
}

