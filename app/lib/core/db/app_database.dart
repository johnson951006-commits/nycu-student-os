import 'package:drift/drift.dart';

part 'app_database.g.dart';

/// The client's local-first domain database (drift over SQLCipher — FA §9.2).
///
/// The scaffold opens an **empty, encrypted** database so the store exists from
/// day one; feature tasks add their tables (mirroring the server read models) and
/// bump [schemaVersion] with a migration as they land. Generated code lives in
/// `app_database.g.dart` (produced by `build_runner`).
@DriftDatabase(tables: <Type>[])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 1;
}
