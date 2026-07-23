import 'package:freezed_annotation/freezed_annotation.dart';

import 'auth_role_preference.dart';
import 'auth_user_locale.dart';

part 'auth_user.freezed.dart';

/// The signed-in student (DB §7 `users`). Immutable; nullability mirrors the
/// table exactly — `display_name`, `email`, `role_preference` and `deleted_at`
/// are nullable columns, everything else is NOT NULL.
///
/// Pure domain type: no Flutter, no drift, no network imports (FA §2 / FES §3).
/// Generated code lives in `auth_user.freezed.dart` (`build_runner`).
@freezed
class AuthUser with _$AuthUser {
  const factory AuthUser({
    required String id,
    required String studentId,
    required UserLocale locale,
    required DateTime createdAt,
    required DateTime updatedAt,
    String? displayName,
    String? email,
    RolePreference? rolePreference,
    DateTime? deletedAt,
  }) = _AuthUser;
}
