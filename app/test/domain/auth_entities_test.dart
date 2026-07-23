import 'package:flutter_test/flutter_test.dart';
import 'package:nycu_student_os/domain/entities/auth_app_session.dart';
import 'package:nycu_student_os/domain/entities/auth_portal_session_status.dart';
import 'package:nycu_student_os/domain/entities/auth_role_preference.dart';
import 'package:nycu_student_os/domain/entities/auth_tokens.dart';
import 'package:nycu_student_os/domain/entities/auth_user.dart';
import 'package:nycu_student_os/domain/entities/auth_user_locale.dart';

/// AUTH-001 Required Test: entity immutability, nullability parity with
/// DB §7, and the [AuthTokens] value-object invariants.
void main() {
  final now = DateTime.utc(2026, 7, 16, 9, 41);

  group('AuthUser', () {
    AuthUser minimal() => AuthUser(
          id: 'u-1',
          studentId: '311551000',
          locale: UserLocale.zhTw,
          createdAt: now,
          updatedAt: now,
        );

    test('nullable columns default to null; NOT NULL columns are required', () {
      final user = minimal();
      // display_name / email / role_preference / deleted_at are nullable in DB §7
      expect(user.displayName, isNull);
      expect(user.email, isNull);
      expect(user.rolePreference, isNull);
      expect(user.deletedAt, isNull);
      // NOT NULL columns carry values
      expect(user.id, 'u-1');
      expect(user.studentId, '311551000');
      expect(user.locale, UserLocale.zhTw);
      expect(user.createdAt, now);
      expect(user.updatedAt, now);
    });

    test('is immutable — copyWith returns a new instance, original untouched', () {
      final user = minimal();
      final renamed = user.copyWith(displayName: '王小明');
      expect(renamed.displayName, '王小明');
      expect(user.displayName, isNull);
      expect(identical(user, renamed), isFalse);
    });

    test('compares by value', () {
      expect(minimal(), equals(minimal()));
      expect(minimal(), isNot(equals(minimal().copyWith(email: 'a@b.c'))));
    });
  });

  group('AppSession', () {
    test('nullable columns default to null; required columns are set', () {
      final session = AppSession(
        id: 's-1',
        userId: 'u-1',
        expiresAt: now,
        createdAt: now,
      );
      expect(session.deviceLabel, isNull);
      expect(session.revokedAt, isNull);
      expect(session.id, 's-1');
      expect(session.userId, 'u-1');
    });

    test('is immutable — copyWith leaves the original unchanged', () {
      final session = AppSession(
        id: 's-1',
        userId: 'u-1',
        expiresAt: now,
        createdAt: now,
      );
      final revoked = session.copyWith(revokedAt: now);
      expect(revoked.revokedAt, now);
      expect(session.revokedAt, isNull);
    });
  });

  group('AuthTokens value object', () {
    // Built through a function so the invocation is NOT a const expression:
    // the asserts must fire at runtime (AssertionError) rather than becoming
    // a compile-time const error.
    AuthTokens build(String access, String refresh) =>
        AuthTokens(accessToken: access, refreshToken: refresh);

    test('accepts a well-formed pair', () {
      const tokens = AuthTokens(accessToken: 'a', refreshToken: 'r');
      expect(tokens.accessToken, 'a');
      expect(tokens.refreshToken, 'r');
    });

    test('rejects a blank accessToken', () {
      expect(() => build('  ', 'r'), throwsA(isA<AssertionError>()));
    });

    test('rejects a blank refreshToken', () {
      expect(() => build('a', ''), throwsA(isA<AssertionError>()));
    });

    test('compares by value', () {
      const a = AuthTokens(accessToken: 'a', refreshToken: 'r');
      const b = AuthTokens(accessToken: 'a', refreshToken: 'r');
      expect(a, equals(b));
    });
  });

  group('closed value domains match DB §7 CHECK constraints', () {
    test('PortalSessionStatus wire values', () {
      expect(
        PortalSessionStatus.values.map((s) => s.wireValue).toList(),
        <String>['ACTIVE', 'STALE', 'EXPIRED', 'REAUTH_REQUIRED'],
      );
    });

    test('UserLocale wire values', () {
      expect(
        UserLocale.values.map((l) => l.wireValue).toList(),
        <String>['zh-TW', 'en'],
      );
    });

    test('RolePreference wire values', () {
      expect(
        RolePreference.values.map((r) => r.wireValue).toList(),
        <String>['student', 'ta'],
      );
    });
  });
}
