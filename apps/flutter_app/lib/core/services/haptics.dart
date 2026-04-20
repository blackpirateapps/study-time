import 'package:flutter/services.dart';

class AuraHaptics {
  static Future<void> syncSuccess() => HapticFeedback.mediumImpact();

  static Future<void> syncError() => HapticFeedback.heavyImpact();
}
