import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_tokens.freezed.dart';

/// The access/refresh pair returned by the auth endpoints (BIS §5
/// `POST /auth/portal-session` · `/auth/refresh`). Immutable value object.
///
/// Both tokens are required by the contract, so a blank token is never a valid
/// value of this type — the asserts below are the invariant this object exists
/// to guarantee. Stored in `flutter_secure_storage`, never in drift/Hive
/// (FES §13); no NYCU password is ever held anywhere (IRR A1).
///
/// Generated code lives in `auth_tokens.freezed.dart` (`build_runner`).
@freezed
class AuthTokens with _$AuthTokens {
  @Assert('accessToken.trim().isNotEmpty', 'accessToken must not be empty')
  @Assert('refreshToken.trim().isNotEmpty', 'refreshToken must not be empty')
  const factory AuthTokens({
    required String accessToken,
    required String refreshToken,
  }) = _AuthTokens;
}
