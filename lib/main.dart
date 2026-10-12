import 'package:flutter/material.dart';

import 'app.dart';
import 'core/di/injection_container.dart' as di;
import 'core/services/firebase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase (single source of truth with DefaultFirebaseOptions)
  await FirebaseService.initialize();

  // Initialize dependency injection
  await di.initDependencies();
  // await seedEstates();
  runApp(const RealEstateApp());
}
