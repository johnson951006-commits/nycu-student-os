import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nycu_student_os/core/errors/app_failure.dart';

/// AppFailure registry tests (INFRA-009): the sealed set mirrors IRR §7 and
/// every code has user copy in BOTH ARB locales (parity beyond the
/// corpus-lint arb-coverage gate).
void main() {
  const codeToArbKey = <String, String>{
    'E-PORTAL-DOWN': 'errorPortalDown',
    'E-DB-FAIL': 'errorDbFail',
    'E-NET-TIMEOUT': 'errorNetTimeout',
    'E-SYNC-FAIL': 'errorSyncFail',
    'E-COOKIE-EXPIRED': 'errorCookieExpired',
    'E-PERM-DENIED': 'errorPermDenied',
    'E-PARSE-DRIFT': 'errorParseDrift',
    'E-CAL-EXPAND': 'errorCalExpand',
    'E-NOTIF-FAIL': 'errorNotifFail',
    'E-UNEXPECTED': 'errorUnexpected',
    'E-PREF-SAVE': 'errorPrefSave',
    'E-SYNC-TOTAL': 'errorSyncTotal',
  };

  test('registry holds exactly the IRR §7 matrix', () {
    expect(AppFailure.registeredCodes, codeToArbKey.keys.toList());
  });

  test('fromCode round-trips every registered code', () {
    for (final code in AppFailure.registeredCodes) {
      expect(AppFailure.fromCode(code).code, code);
    }
  });

  test('unknown code collapses to E-UNEXPECTED, never throws', () {
    expect(AppFailure.fromCode('NOT-A-CODE'), isA<UnexpectedFailure>());
    expect(AppFailure.fromCode('ENDPOINT_SUNSET').code, 'E-UNEXPECTED');
  });

  test('every code has copy in both ARB locales', () {
    for (final arb in <String>[
      'lib/core/l10n/app_zh_TW.arb',
      'lib/core/l10n/app_en.arb',
    ]) {
      final keys =
          (jsonDecode(File(arb).readAsStringSync()) as Map<String, dynamic>)
              .keys
              .toSet();
      for (final key in codeToArbKey.values) {
        expect(keys, contains(key), reason: '$arb missing $key');
      }
    }
  });
}
