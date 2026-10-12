// // lib/seed/seed_estates.dart

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';

// // lib/seed/seed_images.dart

// class SeedImages {
//   // Exterior / cover images
//   static const List<String> exterior = [
//     'https://res.cloudinary.com/xo5cninj/image/upload/v1789849297/frames-for-your-heart-mR1CIDduGLc-unsplash.jpg',
//     'https://res.cloudinary.com/xo5cninj/image/upload/v1789848084/pexels-constanze-marie-3872134-34720051.jpg',
//     'https://res.cloudinary.com/xo5cninj/image/upload/v1789847972/Shape12.png',
//     'https://res.cloudinary.com/xo5cninj/image/upload/v1789847972/Shape11.png',
//     'https://res.cloudinary.com/xo5cninj/image/upload/v1789847972/Shape13.png',
//     'https://res.cloudinary.com/xo5cninj/image/upload/v1789847972/Shape8.jpg',
//     'https://res.cloudinary.com/xo5cninj/image/upload/v1789847971/Shape14.png',
//     'https://res.cloudinary.com/xo5cninj/image/upload/v1789847969/Shape7.png',
//     'https://res.cloudinary.com/xo5cninj/image/upload/v1789847969/Shape9.jpg',
//     'https://res.cloudinary.com/xo5cninj/image/upload/v1789847969/Shape4.png',
//     'https://res.cloudinary.com/xo5cninj/image/upload/v1789847968/Shape3.png',
//     'https://res.cloudinary.com/xo5cninj/image/upload/v1789847968/Shape2.png',
//     'https://res.cloudinary.com/xo5cninj/image/upload/v1789847967/image_28.png',
//     'https://res.cloudinary.com/xo5cninj/image/upload/v1789847966/image_30.png',
//     'https://res.cloudinary.com/xo5cninj/image/upload/v1789847966/image_27.png',
//     'https://res.cloudinary.com/xo5cninj/image/upload/v1789847965/image_26.png',
//     'https://res.cloudinary.com/xo5cninj/image/upload/v1789847965/shape1.png',
//     'https://res.cloudinary.com/xo5cninj/image/upload/v1789847964/point3d-commercial-imaging-ltd-X_JXnSBKOO4-unsplash.jpg',
//     'https://res.cloudinary.com/xo5cninj/image/upload/v1789847963/eli-chamoun-ih31OJemzC8-unsplash.jpg',
//     'https://res.cloudinary.com/xo5cninj/image/upload/v1789847962/image_29.png',
//     'https://res.cloudinary.com/xo5cninj/image/upload/v1789847962/elite-prop-hmlP-v0vJ5o-unsplash.jpg',
//   ];

//   // Indoor / interior images
//   static const List<String> interior = [
//     'https://res.cloudinary.com/xo5cninj/image/upload/v1789848085/shadowfirearts-bedroom-1940168_640.jpg',
//     'https://res.cloudinary.com/xo5cninj/image/upload/v1789848084/ajs1-food-5391386_640.jpg',
//     'https://res.cloudinary.com/xo5cninj/image/upload/v1789848083/23555986-living-room-8896505_640.jpg',
//     'https://res.cloudinary.com/xo5cninj/image/upload/v1789847963/clay-banks-urH155LONWs-unsplash.jpg',
//     'https://res.cloudinary.com/xo5cninj/image/upload/v1789849299/woody-kelly-AwMVOIphjd0-unsplash.jpg',
//     'https://res.cloudinary.com/xo5cninj/image/upload/v1789849299/clay-banks-xe8ok0nR65M-unsplash.jpg',
//     'https://res.cloudinary.com/xo5cninj/image/upload/v1789849299/aalo-lens-ugIfsN9l_q4-unsplash.jpg',
//     'https://res.cloudinary.com/xo5cninj/image/upload/v1789849300/francesca-tosolini-tHkJAMcO3QE-unsplash.jpg',
//     'https://res.cloudinary.com/xo5cninj/image/upload/v1789849300/clay-banks-b0y9W2jPoSI-unsplash.jpg',
//     'https://res.cloudinary.com/xo5cninj/image/upload/v1789849301/lotus-design-n-print-wRzBarqn3hs-unsplash.jpg',
//     'https://res.cloudinary.com/xo5cninj/image/upload/v1789849300/lotus-design-n-print-Alp8v3dpGh0-unsplash.jpg',
//   ];
// }

// // ================== Fixed IDs ==================
// const _catApartment = 'tEy0flhpkAQvZbcgJ1Q5';
// const _catVilla     = 'IyMGCmuqGLxdXroaYuRF';
// const _catHouse     = '5vPTQAxJqZeYGTnhPezk';
// const _catStudio    = '1uJdLmyfmsuOYpgwbjbn';
// const _catCottage   = 'PrPQAztdVFx5uqm5lBGw';
// const _catChalet    = 'hge0dcWyeXHLTfUresbA';
// const _catOffice    = 'r1kywRuX21JoZqoFGgJt';

// const _agents = [
//   'agent_001', 'agent_002', 'agent_003', 'agent_004', 'agent_005',
// ];

// // ================== Seed ==================
// Future<void> seedEstates() async {
//   final db = FirebaseFirestore.instance;
//   final now = DateTime.now();

//   final samples = _buildSamples(now);
//   final batch = db.batch();

//   for (final s in samples) {
//     final ref = db.collection('estates').doc();

//     // Build geohash from lat/lng
//     final locMap = Map<String, dynamic>.from(s['location'] as Map);
//     final geo = GeoFirePoint(
//       GeoPoint(locMap['latitude'], locMap['longitude']),
//     );
//     locMap['geohash'] = geo.geohash;

//     final cover = s['coverImage'] as String;
//     final gallery = List<String>.from(s['images'] as List);

//     batch.set(ref, {
//       ...s,
//       'location': locMap,
//       'coverImage': cover,
//       'images': [cover, ...gallery],
//       'updatedAt': Timestamp.fromDate(now),
//     });
//   }

//   await batch.commit();
//   print('✅ Seeded ${samples.length} estates');
// }

// // ================== Data ==================
// List<Map<String, dynamic>> _buildSamples(DateTime now) {
//   final ext = SeedImages.exterior;
//   final ind = SeedImages.interior;

//   List<String> pickIndoor(int start, int count) {
//     return List.generate(count, (i) => ind[(start + i) % ind.length]);
//   }

//   return [
//     // ---------- 1) Apartment - Sheikh Zayed - Rent ----------
//     {
//       'title': 'Luxury Apartment with Garden View',
//       'description':
//           'Spacious 3-bedroom apartment with super lux finishing in a premium compound in Sheikh Zayed, close to Mall of Arabia and all amenities.',
//       'price': 14000,
//       'pricePeriod': 'monthly',
//       'listingType': 'rent',
//       'categoryId': _catApartment,
//       'agentId': _agents[0],
//       'bedrooms': 3,
//       'bathrooms': 2,
//       'area': 175,
//       'isFurnished': true,
//       'amenities': ['parking', 'pool', 'gym', 'security', 'garden'],
//       'location': {
//         'address': 'Palm Hills Compound, Sheikh Zayed, Giza',
//         'city': 'Giza',
//         'latitude': 30.0437,
//         'longitude': 30.9795,
//       },
//       'rating': 4.7,
//       'reviewCount': 38,
//       'isFeatured': true,
//       'isAvailable': true,
//       'status': 'active',
//       'virtualTourUrl': 'https://my.matterport.com/show/?m=demo_sz_001',
//       'coverImage': ext[0],
//       'images': pickIndoor(0, 4),
//       'createdAt': Timestamp.fromDate(now.subtract(const Duration(days: 2))),
//     },

//     // ---------- 2) Villa - Fifth Settlement - Sale ----------
//     {
//       'title': 'Standalone Villa with Pool and Garden',
//       'description':
//           'Townhouse villa in Fifth Settlement, 5 bedrooms, 200 sqm garden, fully modern design.',
//       'price': 12500000,
//       'pricePeriod': 'total',
//       'listingType': 'sale',
//       'categoryId': _catVilla,
//       'agentId': _agents[2],
//       'bedrooms': 5,
//       'bathrooms': 4,
//       'area': 420,
//       'isFurnished': false,
//       'amenities': ['parking', 'pool', 'garden', 'security'],
//       'location': {
//         'address': 'Mivida, Fifth Settlement, Cairo',
//         'city': 'Cairo',
//         'latitude': 30.0086,
//         'longitude': 31.4913,
//       },
//       'rating': 4.9,
//       'reviewCount': 21,
//       'isFeatured': true,
//       'isAvailable': true,
//       'status': 'active',
//       'virtualTourUrl': 'https://my.matterport.com/show/?m=demo_cairo_002',
//       'coverImage': ext[1],
//       'images': pickIndoor(2, 5),
//       'createdAt': Timestamp.fromDate(now.subtract(const Duration(days: 5))),
//     },

//     // ---------- 3) Studio - Nasr City - Rent ----------
//     {
//       'title': 'Fully Furnished Studio Apartment',
//       'description':
//           '45 sqm fully furnished studio with private entrance, ideal for students or young professionals, close to the metro.',
//       'price': 5500,
//       'pricePeriod': 'monthly',
//       'listingType': 'rent',
//       'categoryId': _catStudio,
//       'agentId': _agents[1],
//       'bedrooms': 1,
//       'bathrooms': 1,
//       'area': 45,
//       'isFurnished': true,
//       'amenities': ['wifi', 'ac'],
//       'location': {
//         'address': 'Abbas El Akkad, Nasr City, Cairo',
//         'city': 'Cairo',
//         'latitude': 30.0561,
//         'longitude': 31.3300,
//       },
//       'rating': 4.3,
//       'reviewCount': 12,
//       'isFeatured': false,
//       'isAvailable': true,
//       'status': 'active',
//       'virtualTourUrl': null,
//       'coverImage': ext[2],
//       'images': pickIndoor(0, 3),
//       'createdAt': Timestamp.fromDate(now.subtract(const Duration(days: 1))),
//     },

//     // ---------- 4) Apartment - Maadi - Rent ----------
//     {
//       'title': 'Quiet Apartment in Maadi',
//       'description':
//           'Two-bedroom apartment on a quiet street in Maadi, fully sunlit and close to the Corniche.',
//       'price': 9000,
//       'pricePeriod': 'monthly',
//       'listingType': 'rent',
//       'categoryId': _catApartment,
//       'agentId': _agents[3],
//       'bedrooms': 2,
//       'bathrooms': 1,
//       'area': 110,
//       'isFurnished': false,
//       'amenities': ['parking', 'balcony'],
//       'location': {
//         'address': 'Street 9, Maadi, Cairo',
//         'city': 'Cairo',
//         'latitude': 29.9603,
//         'longitude': 31.2569,
//       },
//       'rating': 4.5,
//       'reviewCount': 27,
//       'isFeatured': false,
//       'isAvailable': true,
//       'status': 'active',
//       'virtualTourUrl': null,
//       'coverImage': ext[3],
//       'images': pickIndoor(4, 4),
//       'createdAt': Timestamp.fromDate(now.subtract(const Duration(days: 7))),
//     },

//     // ---------- 5) Chalet - North Coast - Sale ----------
//     {
//       'title': 'Beachfront Chalet with Sea View',
//       'description':
//           'Chalet on the North Coast with direct sea view, 2 bedrooms plus a spacious terrace.',
//       'price': 4200000,
//       'pricePeriod': 'total',
//       'listingType': 'sale',
//       'categoryId': _catChalet,
//       'agentId': _agents[4],
//       'bedrooms': 2,
//       'bathrooms': 2,
//       'area': 95,
//       'isFurnished': true,
//       'amenities': ['pool', 'beach_access', 'security'],
//       'location': {
//         'address': 'Marassi, North Coast',
//         'city': 'North Coast',
//         'latitude': 31.0039,
//         'longitude': 28.9290,
//       },
//       'rating': 4.8,
//       'reviewCount': 44,
//       'isFeatured': true,
//       'isAvailable': true,
//       'status': 'active',
//       'virtualTourUrl': 'https://my.matterport.com/show/?m=demo_sahel_005',
//       'coverImage': ext[4],
//       'images': pickIndoor(6, 4),
//       'createdAt': Timestamp.fromDate(now.subtract(const Duration(days: 3))),
//     },

//     // ---------- 6) Office - New Capital - Rent ----------
//     {
//       'title': 'Administrative Office in New Capital',
//       'description':
//           '120 sqm office in a business tower in the New Administrative Capital, fully finished with fiber internet.',
//       'price': 25000,
//       'pricePeriod': 'monthly',
//       'listingType': 'rent',
//       'categoryId': _catOffice,
//       'agentId': _agents[2],
//       'bedrooms': 0,
//       'bathrooms': 2,
//       'area': 120,
//       'isFurnished': true,
//       'amenities': ['parking', 'security', 'wifi', 'elevator'],
//       'location': {
//         'address': 'Government District, New Administrative Capital',
//         'city': 'New Capital',
//         'latitude': 30.0169,
//         'longitude': 31.7500,
//       },
//       'rating': 4.6,
//       'reviewCount': 9,
//       'isFeatured': false,
//       'isAvailable': true,
//       'status': 'active',
//       'virtualTourUrl': null,
//       'coverImage': ext[5],
//       'images': pickIndoor(8, 3),
//       'createdAt': Timestamp.fromDate(now.subtract(const Duration(days: 10))),
//     },

//     // ---------- 7) House - Madinaty - Sale ----------
//     {
//       'title': 'Twin House in Madinaty',
//       'description':
//           '4-bedroom twin house with front and back garden in Madinaty, move-in ready.',
//       'price': 6800000,
//       'pricePeriod': 'total',
//       'listingType': 'sale',
//       'categoryId': _catHouse,
//       'agentId': _agents[0],
//       'bedrooms': 4,
//       'bathrooms': 3,
//       'area': 260,
//       'isFurnished': false,
//       'amenities': ['parking', 'garden', 'security'],
//       'location': {
//         'address': 'Group 12, Madinaty, Cairo',
//         'city': 'Cairo',
//         'latitude': 30.1067,
//         'longitude': 31.6422,
//       },
//       'rating': 4.7,
//       'reviewCount': 33,
//       'isFeatured': false,
//       'isAvailable': true,
//       'status': 'active',
//       'virtualTourUrl': null,
//       'coverImage': ext[6],
//       'images': pickIndoor(2, 4),
//       'createdAt': Timestamp.fromDate(now.subtract(const Duration(days: 12))),
//     },

//     // ---------- 8) Cottage - Ain Sokhna - Rent ----------
//     {
//       'title': 'Cozy Cottage with Mountain View',
//       'description':
//           'Wooden cottage with a mountain view in Ain Sokhna, perfect for weekend getaways.',
//       'price': 2500,
//       'pricePeriod': 'monthly',
//       'listingType': 'rent',
//       'categoryId': _catCottage,
//       'agentId': _agents[4],
//       'bedrooms': 2,
//       'bathrooms': 1,
//       'area': 70,
//       'isFurnished': true,
//       'amenities': ['bbq', 'garden'],
//       'location': {
//         'address': 'Zaafarana, Ain Sokhna',
//         'city': 'Suez',
//         'latitude': 29.6000,
//         'longitude': 32.3500,
//       },
//       'rating': 4.4,
//       'reviewCount': 17,
//       'isFeatured': false,
//       'isAvailable': true,
//       'status': 'active',
//       'virtualTourUrl': null,
//       'coverImage': ext[7],
//       'images': pickIndoor(1, 3),
//       'createdAt': Timestamp.fromDate(now.subtract(const Duration(days: 20))),
//     },

//     // ---------- 9) Apartment - Zamalek - Rent ----------
//     {
//       'title': 'Classic Apartment in Zamalek',
//       'description':
//           'Spacious 3-bedroom apartment in a historic building in Zamalek, high ceilings and parquet floors.',
//       'price': 22000,
//       'pricePeriod': 'monthly',
//       'listingType': 'rent',
//       'categoryId': _catApartment,
//       'agentId': _agents[1],
//       'bedrooms': 3,
//       'bathrooms': 2,
//       'area': 200,
//       'isFurnished': true,
//       'amenities': ['parking', 'elevator', 'security'],
//       'location': {
//         'address': 'Brazil Street, Zamalek, Cairo',
//         'city': 'Cairo',
//         'latitude': 30.0609,
//         'longitude': 31.2197,
//       },
//       'rating': 4.8,
//       'reviewCount': 52,
//       'isFeatured': true,
//       'isAvailable': true,
//       'status': 'active',
//       'virtualTourUrl': 'https://my.matterport.com/show/?m=demo_zamalek_009',
//       'coverImage': ext[8],
//       'images': pickIndoor(3, 5),
//       'createdAt': Timestamp.fromDate(now.subtract(const Duration(days: 6))),
//     },

//     // ---------- 10) Villa - 6 October - Sale ----------
//     {
//       'title': 'Modern Villa in 6th of October',
//       'description':
//           '350 sqm villa in New Sheikh Zayed, contemporary design with a private swimming pool.',
//       'price': 9800000,
//       'pricePeriod': 'total',
//       'listingType': 'sale',
//       'categoryId': _catVilla,
//       'agentId': _agents[2],
//       'bedrooms': 4,
//       'bathrooms': 4,
//       'area': 350,
//       'isFurnished': false,
//       'amenities': ['parking', 'pool', 'garden', 'security'],
//       'location': {
//         'address': 'First District, 6th of October, Giza',
//         'city': 'Giza',
//         'latitude': 29.9285,
//         'longitude': 30.9188,
//       },
//       'rating': 4.6,
//       'reviewCount': 24,
//       'isFeatured': false,
//       'isAvailable': true,
//       'status': 'active',
//       'virtualTourUrl': null,
//       'coverImage': ext[9],
//       'images': pickIndoor(5, 4),
//       'createdAt': Timestamp.fromDate(now.subtract(const Duration(days: 14))),
//     },

//     // ---------- 11) Studio - Sharm El Sheikh - Rent ----------
//     {
//       'title': 'Studio Apartment in Sharm El Sheikh',
//       'description':
//           'Furnished studio near Nabq, ideal for monthly rental with direct beach access.',
//       'price': 8000,
//       'pricePeriod': 'monthly',
//       'listingType': 'rent',
//       'categoryId': _catStudio,
//       'agentId': _agents[3],
//       'bedrooms': 1,
//       'bathrooms': 1,
//       'area': 50,
//       'isFurnished': true,
//       'amenities': ['beach_access', 'wifi', 'ac', 'pool'],
//       'location': {
//         'address': 'Nabq, Sharm El Sheikh, South Sinai',
//         'city': 'Sharm El Sheikh',
//         'latitude': 27.9158,
//         'longitude': 34.3300,
//       },
//       'rating': 4.5,
//       'reviewCount': 61,
//       'isFeatured': false,
//       'isAvailable': true,
//       'status': 'active',
//       'virtualTourUrl': null,
//       'coverImage': ext[10],
//       'images': pickIndoor(0, 3),
//       'createdAt': Timestamp.fromDate(now.subtract(const Duration(days: 9))),
//     },

//     // ---------- 12) House - Rehab - Sale ----------
//     {
//       'title': 'Family House in Rehab',
//       'description':
//           'Standalone 3-floor house with a small garden in Rehab, quiet and family-friendly.',
//       'price': 5400000,
//       'pricePeriod': 'total',
//       'listingType': 'sale',
//       'categoryId': _catHouse,
//       'agentId': _agents[0],
//       'bedrooms': 4,
//       'bathrooms': 3,
//       'area': 240,
//       'isFurnished': false,
//       'amenities': ['parking', 'garden', 'security', 'club'],
//       'location': {
//         'address': 'Phase 4, Rehab, Cairo',
//         'city': 'Cairo',
//         'latitude': 30.0637,
//         'longitude': 31.4913,
//       },
//       'rating': 4.7,
//       'reviewCount': 41,
//       'isFeatured': false,
//       'isAvailable': true,
//       'status': 'active',
//       'virtualTourUrl': null,
//       'coverImage': ext[11],
//       'images': pickIndoor(7, 4),
//       'createdAt': Timestamp.fromDate(now.subtract(const Duration(days: 18))),
//     },

//     // ---------- 13) Apartment - Heliopolis - Sale ----------
//     {
//       'title': 'Brand New Apartment in Heliopolis',
//       'description':
//           '2-bedroom apartment in brand new condition in Heliopolis, close to College metro station.',
//       'price': 3200000,
//       'pricePeriod': 'total',
//       'listingType': 'sale',
//       'categoryId': _catApartment,
//       'agentId': _agents[3],
//       'bedrooms': 2,
//       'bathrooms': 1,
//       'area': 105,
//       'isFurnished': false,
//       'amenities': ['elevator', 'balcony'],
//       'location': {
//         'address': 'College Square, Heliopolis, Cairo',
//         'city': 'Cairo',
//         'latitude': 30.0877,
//         'longitude': 31.3355,
//       },
//       'rating': 4.4,
//       'reviewCount': 19,
//       'isFeatured': false,
//       'isAvailable': true,
//       'status': 'active',
//       'virtualTourUrl': null,
//       'coverImage': ext[12],
//       'images': pickIndoor(2, 3),
//       'createdAt': Timestamp.fromDate(now.subtract(const Duration(days: 4))),
//     },

//     // ---------- 14) Chalet - El Gouna - Sale ----------
//     {
//       'title': 'Luxury Chalet in El Gouna',
//       'description':
//           'Lagoon-view chalet in El Gouna, elegant Nubian design with hotel-grade services.',
//       'price': 7100000,
//       'pricePeriod': 'total',
//       'listingType': 'sale',
//       'categoryId': _catChalet,
//       'agentId': _agents[4],
//       'bedrooms': 3,
//       'bathrooms': 2,
//       'area': 130,
//       'isFurnished': true,
//       'amenities': ['pool', 'beach_access', 'gym', 'security'],
//       'location': {
//         'address': 'El Gouna, Hurghada, Red Sea',
//         'city': 'Hurghada',
//         'latitude': 27.2579,
//         'longitude': 33.8116,
//       },
//       'rating': 4.9,
//       'reviewCount': 88,
//       'isFeatured': true,
//       'isAvailable': true,
//       'status': 'active',
//       'virtualTourUrl': 'https://my.matterport.com/show/?m=demo_gouna_014',
//       'coverImage': ext[13],
//       'images': pickIndoor(4, 5),
//       'createdAt': Timestamp.fromDate(now.subtract(const Duration(days: 8))),
//     },

//     // ---------- 15) Office - Nasr City - Rent ----------
//     {
//       'title': 'Commercial Office in Nasr City',
//       'description':
//           '90 sqm office in a commercial tower in Nasr City, ideal for a small company or clinic.',
//       'price': 15000,
//       'pricePeriod': 'monthly',
//       'listingType': 'rent',
//       'categoryId': _catOffice,
//       'agentId': _agents[1],
//       'bedrooms': 0,
//       'bathrooms': 1,
//       'area': 90,
//       'isFurnished': false,
//       'amenities': ['parking', 'elevator', 'security'],
//       'location': {
//         'address': 'Makram Ebeid, Nasr City, Cairo',
//         'city': 'Cairo',
//         'latitude': 30.0561,
//         'longitude': 31.3300,
//       },
//       'rating': 4.2,
//       'reviewCount': 7,
//       'isFeatured': false,
//       'isAvailable': true,
//       'status': 'active',
//       'virtualTourUrl': null,
//       'coverImage': ext[14],
//       'images': pickIndoor(9, 3),
//       'createdAt': Timestamp.fromDate(now.subtract(const Duration(days: 15))),
//     },

//     // ---------- 16) Villa - Alexandria - Rent ----------
//     {
//       'title': 'Villa on Alexandria Corniche',
//       'description':
//           'Direct sea-view villa in Sidi Bishr, 5 bedrooms and a spacious garden.',
//       'price': 45000,
//       'pricePeriod': 'monthly',
//       'listingType': 'rent',
//       'categoryId': _catVilla,
//       'agentId': _agents[2],
//       'bedrooms': 5,
//       'bathrooms': 4,
//       'area': 380,
//       'isFurnished': true,
//       'amenities': ['parking', 'garden', 'sea_view', 'security'],
//       'location': {
//         'address': 'Sidi Bishr, Alexandria',
//         'city': 'Alexandria',
//         'latitude': 31.2001,
//         'longitude': 29.9187,
//       },
//       'rating': 4.8,
//       'reviewCount': 36,
//       'isFeatured': true,
//       'isAvailable': true,
//       'status': 'active',
//       'virtualTourUrl': 'https://my.matterport.com/show/?m=demo_alex_016',
//       'coverImage': ext[15],
//       'images': pickIndoor(1, 4),
//       'createdAt': Timestamp.fromDate(now.subtract(const Duration(days: 11))),
//     },

//     // ---------- 17) Cottage - Fayoum - Rent ----------
//     {
//       'title': 'Rustic Cottage in Fayoum',
//       'description':
//           'Simple cottage overlooking Lake Qarun, perfect for nature lovers and quiet retreats.',
//       'price': 3500,
//       'pricePeriod': 'monthly',
//       'listingType': 'rent',
//       'categoryId': _catCottage,
//       'agentId': _agents[4],
//       'bedrooms': 2,
//       'bathrooms': 1,
//       'area': 80,
//       'isFurnished': true,
//       'amenities': ['garden', 'lake_view'],
//       'location': {
//         'address': 'Shakshouk, Fayoum',
//         'city': 'Fayoum',
//         'latitude': 29.4180,
//         'longitude': 30.5900,
//       },
//       'rating': 4.3,
//       'reviewCount': 14,
//       'isFeatured': false,
//       'isAvailable': true,
//       'status': 'active',
//       'virtualTourUrl': null,
//       'coverImage': ext[16],
//       'images': pickIndoor(6, 3),
//       'createdAt': Timestamp.fromDate(now.subtract(const Duration(days: 25))),
//     },

//     // ---------- 18) House - Obour - Sale ----------
//     {
//       'title': 'Standalone House in Obour',
//       'description':
//           '220 sqm standalone house in Obour, quiet and close to services and schools.',
//       'price': 4100000,
//       'pricePeriod': 'total',
//       'listingType': 'sale',
//       'categoryId': _catHouse,
//       'agentId': _agents[0],
//       'bedrooms': 3,
//       'bathrooms': 3,
//       'area': 220,
//       'isFurnished': false,
//       'amenities': ['parking', 'garden'],
//       'location': {
//         'address': 'First District, Obour, Qalyubia',
//         'city': 'Obour',
//         'latitude': 30.2111,
//         'longitude': 31.4517,
//       },
//       'rating': 4.5,
//       'reviewCount': 22,
//       'isFeatured': false,
//       'isAvailable': true,
//       'status': 'active',
//       'virtualTourUrl': null,
//       'coverImage': ext[17],
//       'images': pickIndoor(3, 4),
//       'createdAt': Timestamp.fromDate(now.subtract(const Duration(days: 16))),
//     },
//   ];
// }

// [
//     {
//       'id': 'agent_001',

//       'userId': '5VJP6f16blNnunsMYvlrdefUa4I2',

//       'agencyName': 'Prime Estate',
//       'bio':
//           'Experienced real estate agent helping clients find suitable properties.',
//       'yearsOfExperience': 8,
//       'rating': 4.8,
//       'reviewCount': 124,
//       'isVerified': true,
//     },
//     {
//       'id': 'agent_002',

//       'userId': 'Cw0rfk9RiAhoJ1GtLDQdWXX8iDo1',

//       'agencyName': 'Urban Homes',
//       'bio':
//           'Real estate specialist focused on residential properties and rentals.',
//       'yearsOfExperience': 6,
//       'rating': 4.7,
//       'reviewCount': 89,
//       'isVerified': true,
//     },
//     {
//       'id': 'agent_003',

//       'userId': 'UamdLWJU02bMq92wRR40KIo1kp62',

//       'agencyName': 'Elite Properties',
//       'bio':
//           'Professional real estate consultant specializing in premium properties.',
//       'yearsOfExperience': 10,
//       'rating': 4.9,
//       'reviewCount': 176,
//       'isVerified': true,
//     },
//     {
//       'id': 'agent_004',

//       'userId': 'fejmoigOJQdlmYR8gQmtdRiC6v52',

//       'agencyName': 'Home Finder',
//       'bio':
//           'Helping clients discover comfortable homes and investment opportunities.',
//       'yearsOfExperience': 5,
//       'rating': 4.6,
//       'reviewCount': 67,
//       'isVerified': true,
//     },
//     {
//       'id': 'agent_005',

//       'userId': 'oi0tWHvxZSOP2cBStdEYrghCK2t2',

//       'agencyName': 'Golden Homes',
//       'bio':
//           'Real estate advisor specializing in apartments, villas and family homes.',
//       'yearsOfExperience': 7,
//       'rating': 4.8,
//       'reviewCount': 103,
//       'isVerified': true,
//     },
//   ];                                                                                                                                                                                /categories/1uJdLmyfmsuOYpgwbjbn                      name :"studio"                                                                       /categories/5vPTQAxJqZeYGTnhPezk                      name :"house"                                                                     /categories/IyMGCmuqGLxdXroaYuRF                      name :"villa"                                         /categories/PrPQAztdVFx5uqm5lBGw                       name : "cottage"                                 /categories/hge0dcWyeXHLTfUresbA                         name :"chalet"                                /categories/r1kywRuX21JoZqoFGgJt                         name :"office"                                 /categories/tEy0flhpkAQvZbcgJ1Q5                        name :"apartment"

// دول collection الي هنربطه  بestate

// دي الصور الوجه بتع estate
// https://res.cloudinary.com/xo5cninj/image/upload/v1789849297/frames-for-your-heart-mR1CIDduGLc-unsplash.jpg                             https://res.cloudinary.com/xo5cninj/image/upload/v1789848084/pexels-constanze-marie-3872134-34720051.jpg                     https://res.cloudinary.com/xo5cninj/image/upload/v1789848084/pexels-constanze-marie-3872134-34720051.jpg             https://res.cloudinary.com/xo5cninj/image/upload/v1789848084/pexels-constanze-marie-3872134-34720051.jpg         https://res.cloudinary.com/xo5cninj/image/upload/v1789847972/Shape12.png            https://res.cloudinary.com/xo5cninj/image/upload/v1789847972/Shape11.png                 https://res.cloudinary.com/xo5cninj/image/upload/v1789847972/Shape13.png              https://res.cloudinary.com/xo5cninj/image/upload/v1789847972/Shape8.jpg                https://res.cloudinary.com/xo5cninj/image/upload/v1789847971/Shape14.png         https://res.cloudinary.com/xo5cninj/image/upload/v1789847969/Shape7.png              https://res.cloudinary.com/xo5cninj/image/upload/v1789847969/Shape9.jpg                    https://res.cloudinary.com/xo5cninj/image/upload/v1789847969/Shape4.png               https://res.cloudinary.com/xo5cninj/image/upload/v1789847968/Shape3.png              https://res.cloudinary.com/xo5cninj/image/upload/v1789847968/Shape2.png             https://res.cloudinary.com/xo5cninj/image/upload/v1789847967/image_28.png       https://res.cloudinary.com/xo5cninj/image/upload/v1789847966/image_30.png          https://res.cloudinary.com/xo5cninj/image/upload/v1789847966/image_27.png           https://res.cloudinary.com/xo5cninj/image/upload/v1789847965/image_26.png          https://res.cloudinary.com/xo5cninj/image/upload/v1789847965/shape1.png                https://res.cloudinary.com/xo5cninj/image/upload/v1789847964/point3d-commercial-imaging-ltd-X_JXnSBKOO4-unsplash.jpg                                                           https://res.cloudinary.com/xo5cninj/image/upload/v1789847963/eli-chamoun-ih31OJemzC8-unsplash.jpg                                       https://res.cloudinary.com/xo5cninj/image/upload/v1789847962/image_29.png         https://res.cloudinary.com/xo5cninj/image/upload/v1789847962/elite-prop-hmlP-v0vJ5o-unsplash.jpg

// ود  صور  بتع indoor  الي جو estate
// https://res.cloudinary.com/xo5cninj/image/upload/v1789848085/shadowfirearts-bedroom-1940168_640.jpg                                                      https://res.cloudinary.com/xo5cninj/image/upload/v1789848084/ajs1-food-5391386_640.jpg
// https://res.cloudinary.com/xo5cninj/image/upload/v1789848083/23555986-living-room-8896505_640.jpg                                                    https://res.cloudinary.com/xo5cninj/image/upload/v1789847963/clay-banks-urH155LONWs-unsplash.jpg                                https://res.cloudinary.com/xo5cninj/image/upload/v1789849299/woody-kelly-AwMVOIphjd0-unsplash.jpg                                  https://res.cloudinary.com/xo5cninj/image/upload/v1789849299/clay-banks-xe8ok0nR65M-unsplash.jpg                          https://res.cloudinary.com/xo5cninj/image/upload/v1789849299/aalo-lens-ugIfsN9l_q4-unsplash.jpg                               https://res.cloudinary.com/xo5cninj/image/upload/v1789849300/francesca-tosolini-tHkJAMcO3QE-unsplash.jpg                      https://res.cloudinary.com/xo5cninj/image/upload/v1789849300/clay-banks-b0y9W2jPoSI-unsplash.jpg                                  https://res.cloudinary.com/xo5cninj/image/upload/v1789849301/lotus-design-n-print-wRzBarqn3hs-unsplash.jpg                              https://res.cloudinary.com/xo5cninj/image/upload/v1789849300/lotus-design-n-print-Alp8v3dpGh0-unsplash.jpg
