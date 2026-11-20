import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import 'app.dart';
import 'core/di/dependency_injection.dart' as di;
import 'core/services/firebase_service.dart';

Future<void> main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  
  await FirebaseService.initialize();

  await di.initDependencies();
  
  runApp(const RealEstateApp());
}
