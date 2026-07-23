import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_app_session.freezed.dart';

/// The device's app session (DB §7 `app_sessions`). Immutable; nullability
/// mirrors the table exactly — `device_label` and `revoked_at` are nullable
/// columns, the rest are NOT NULL.
///
/// Deliberately omits `refresh_hash` and `rotated_from`: those are server-side
/// rotation bookkeeping (BIS §7 A02) and are never mirrored on the client. The
/// client holds the RAW tokens in [AuthTokens] (secure storage), never a hash.
///
/// Generated code lives in `auth_app_session.freezed.dart` (`build_runner`).
@freezed
class AppSession with _$AppSession {
  const factory AppSession({
    required String id,
    required String userId,
    required DateTime expiresAt,
    required DateTime createdAt,
    String? deviceLabel,
    DateTime? revokedAt,
  }) = _AppSession;
}
