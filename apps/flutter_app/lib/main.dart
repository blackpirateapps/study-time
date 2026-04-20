import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:workmanager/workmanager.dart';

import 'app.dart';
import 'core/config/firebase_config.dart';
import 'core/services/background_sync.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await Workmanager().initialize(
    auraBackgroundSyncDispatcher,
    isInDebugMode: false,
  );

  final firebaseOptions = FirebaseConfig.tryBuildOptions();
  if (firebaseOptions != null) {
    await Firebase.initializeApp(options: firebaseOptions);
  }

  runApp(const ProviderScope(child: AuraApp()));
}
