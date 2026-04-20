import 'package:isar/isar.dart';

part 'study_log_model.g.dart';

@collection
class StudyLogModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String remoteId;

  @Index()
  late bool isSynced;

  late String subject;
  String? tag;
  late int durationSeconds;
  late DateTime startTime;
}
