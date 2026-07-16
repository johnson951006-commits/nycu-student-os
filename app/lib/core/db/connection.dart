import 'dart:ffi';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlcipher_flutter_libs/sqlcipher_flutter_libs.dart';
import 'package:sqlite3/open.dart';

/// Opens the drift database file encrypted with SQLCipher (FA §9.2 / FES §13).
///
/// The bundled SQLCipher library is loaded in place of plain sqlite3, and the
/// 256-bit [key] (from the platform keychain, [SecureStorage]) is applied via
/// `PRAGMA key` before any I/O. Native SQLCipher wiring is exercised on-device by
/// the integration suite; the unit smoke uses an in-memory drift database.
QueryExecutor openEncryptedConnection(String key) {
  return LazyDatabase(() async {
    open
      ..overrideFor(OperatingSystem.android, openCipherOnAndroid)
      ..overrideFor(OperatingSystem.iOS, DynamicLibrary.process)
      ..overrideFor(OperatingSystem.macOS, DynamicLibrary.process);

    final dir = await getApplicationSupportDirectory();
    final file = File(p.join(dir.path, 'nycu.db'));

    return NativeDatabase(
      file,
      setup: (db) => db.execute("PRAGMA key = '$key';"),
    );
  });
}
