import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/config/firebase_config.dart';
import 'core/database/app_database.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AppDatabase.initialize();

  final firebaseOptions = FirebaseConfig.tryBuildOptions();
  if (firebaseOptions != null) {
    await Firebase.initializeApp(options: firebaseOptions);
  }

  runApp(const ProviderScope(child: AuraApp()));
}
