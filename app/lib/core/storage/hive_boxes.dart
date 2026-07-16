import 'package:hive_flutter/hive_flutter.dart';

/// Hive box names (FA §9.2): structured, non-relational caches — all safe to lose
/// (evaluated flags, dashboard layout, last sync-status snapshot, JWKS). Never
/// sensitive material (that goes to secure storage, FES §13).
abstract final class HiveBoxes {
  static const String config = 'config';
  static const String layout = 'layout';
  static const String syncSnapshot = 'sync_snapshot';
  static const String jwks = 'jwks';

  static const List<String> all = <String>[config, layout, syncSnapshot, jwks];
}

/// Opens every Hive box. Contents are populated by the tasks that own them
/// (evaluated flags → INFRA-010; layout/snapshot → dashboard/sync tasks).
Future<void> openHiveBoxes() async {
  for (final name in HiveBoxes.all) {
    await Hive.openBox<dynamic>(name);
  }
}
