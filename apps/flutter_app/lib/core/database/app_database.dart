import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../../data/local/study_log_model.dart';

class AppDatabase {
  static Isar? _isar;

  static Future<void> initialize() async {
    if (_isar != null) {
      return;
    }

    final directory = await getApplicationDocumentsDirectory();
    _isar = await Isar.open(
      [StudyLogModelSchema],
      directory: directory.path,
      inspector: false,
    );
  }

  static Isar get instance {
    final isar = _isar;
    if (isar == null) {
      throw StateError('AppDatabase.initialize() must run before first use.');
    }

    return isar;
  }
}
