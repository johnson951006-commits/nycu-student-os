import 'dart:convert';
import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Wraps the platform keychain/keystore (FES §13): the only sanctioned home for
/// sensitive material — the SQLCipher database key here, the JWT pair later (AUTH).
/// Nothing sensitive may live in Hive or SharedPreferences.
class SecureStorage {
  SecureStorage([FlutterSecureStorage? storage])
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
            );

  final FlutterSecureStorage _storage;

  static const String _databaseKeyName = 'db_key';

  /// Returns the persisted 256-bit SQLCipher key, generating and storing one on
  /// first launch. base64url output contains no quote characters, so it is safe
  /// to interpolate into the `PRAGMA key` statement.
  Future<String> readOrCreateDatabaseKey() async {
    final existing = await _storage.read(key: _databaseKeyName);
    if (existing != null && existing.isNotEmpty) {
      return existing;
    }
    final random = Random.secure();
    final bytes = List<int>.generate(32, (_) => random.nextInt(256));
    final key = base64UrlEncode(bytes);
    await _storage.write(key: _databaseKeyName, value: key);
    return key;
  }
}
