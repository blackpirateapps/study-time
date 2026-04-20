import 'package:flutter/cupertino.dart';

import 'core/theme/app_theme.dart';
import 'features/home/presentation/home_screen.dart';

class AuraApp extends StatelessWidget {
  const AuraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      debugShowCheckedModeBanner: false,
      title: 'Aura',
      theme: AppTheme.light,
      home: const HomeScreen(),
    );
  }
}
