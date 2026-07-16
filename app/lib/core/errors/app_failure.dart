/// Client-side error contract (IRR §7 Error State Matrix, BIS §1.9).
///
/// Every user-visible failure in the app is one of these sealed variants — the
/// same registry the backend serves in problem+json `code`. Screens `switch`
/// exhaustively (FA §15): adding a variant breaks compilation until every
/// consumer handles it. User copy lives in ARB (`error_*` keys), never here.
sealed class AppFailure {
  const AppFailure({this.requestId});

  /// Correlation id from the failing response (`X-Request-Id`), when one
  /// exists — surfaced in support flows, never in user copy.
  final String? requestId;

  /// The registered IRR §7 code (also the backend problem+json `code`).
  String get code;

  /// Maps a backend problem+json `code` to its variant. Unknown codes
  /// collapse to [UnexpectedFailure] — the client never crashes on a code
  /// added server-side before the app updates (BIS §12.2 tolerance rule).
  factory AppFailure.fromCode(String code, {String? requestId}) {
    return switch (code) {
      'E-PORTAL-DOWN' => PortalDownFailure(requestId: requestId),
      'E-DB-FAIL' => DbFailure(requestId: requestId),
      'E-NET-TIMEOUT' => NetTimeoutFailure(requestId: requestId),
      'E-SYNC-FAIL' => SyncFailure(requestId: requestId),
      'E-COOKIE-EXPIRED' => CookieExpiredFailure(requestId: requestId),
      'E-PERM-DENIED' => PermDeniedFailure(requestId: requestId),
      'E-PARSE-DRIFT' => ParseDriftFailure(requestId: requestId),
      'E-CAL-EXPAND' => CalExpandFailure(requestId: requestId),
      'E-NOTIF-FAIL' => NotifFailure(requestId: requestId),
      'E-PREF-SAVE' => PrefSaveFailure(requestId: requestId),
      'E-SYNC-TOTAL' => SyncTotalFailure(requestId: requestId),
      _ => UnexpectedFailure(requestId: requestId),
    };
  }

  /// The complete IRR §7 matrix — kept in code so tests can assert registry
  /// completeness against the ARB keys and the backend contract.
  static const List<String> registeredCodes = <String>[
    'E-PORTAL-DOWN',
    'E-DB-FAIL',
    'E-NET-TIMEOUT',
    'E-SYNC-FAIL',
    'E-COOKIE-EXPIRED',
    'E-PERM-DENIED',
    'E-PARSE-DRIFT',
    'E-CAL-EXPAND',
    'E-NOTIF-FAIL',
    'E-UNEXPECTED',
    'E-PREF-SAVE',
    'E-SYNC-TOTAL',
  ];
}

/// Portal unreachable — data shown as of `lastSyncedAt`; auto-retry runs.
final class PortalDownFailure extends AppFailure {
  const PortalDownFailure({this.lastSyncedAt, super.requestId});
  final DateTime? lastSyncedAt;
  @override
  String get code => 'E-PORTAL-DOWN';
}

/// Server-side persistence failure; user data is safe.
final class DbFailure extends AppFailure {
  const DbFailure({super.requestId});
  @override
  String get code => 'E-DB-FAIL';
}

/// Request timed out on the network path.
final class NetTimeoutFailure extends AppFailure {
  const NetTimeoutFailure({super.requestId});
  @override
  String get code => 'E-NET-TIMEOUT';
}

/// A sync run failed; data current as of `lastSyncedAt`.
final class SyncFailure extends AppFailure {
  const SyncFailure({this.lastSyncedAt, super.requestId});
  final DateTime? lastSyncedAt;
  @override
  String get code => 'E-SYNC-FAIL';
}

/// Portal session expired — sign-in required to resume sync.
final class CookieExpiredFailure extends AppFailure {
  const CookieExpiredFailure({super.requestId});
  @override
  String get code => 'E-COOKIE-EXPIRED';
}

/// Portal denied access to one category; others keep syncing.
final class PermDeniedFailure extends AppFailure {
  const PermDeniedFailure({this.category, super.requestId});
  final String? category;
  @override
  String get code => 'E-PERM-DENIED';
}

/// Portal markup changed — category paused while parsers adapt.
final class ParseDriftFailure extends AppFailure {
  const ParseDriftFailure({this.category, this.lastSyncedAt, super.requestId});
  final String? category;
  final DateTime? lastSyncedAt;
  @override
  String get code => 'E-PARSE-DRIFT';
}

/// Calendar expansion failed — last saved schedule shown.
final class CalExpandFailure extends AppFailure {
  const CalExpandFailure({super.requestId});
  @override
  String get code => 'E-CAL-EXPAND';
}

/// A notification could not be delivered; recorded in the Center.
final class NotifFailure extends AppFailure {
  const NotifFailure({super.requestId});
  @override
  String get code => 'E-NOTIF-FAIL';
}

/// Unclassified failure — reported, retryable.
final class UnexpectedFailure extends AppFailure {
  const UnexpectedFailure({super.requestId});
  @override
  String get code => 'E-UNEXPECTED';
}

/// A settings write failed.
final class PrefSaveFailure extends AppFailure {
  const PrefSaveFailure({super.requestId});
  @override
  String get code => 'E-PREF-SAVE';
}

/// Full-sync failure — semester data cannot load right now.
final class SyncTotalFailure extends AppFailure {
  const SyncTotalFailure({super.requestId});
  @override
  String get code => 'E-SYNC-TOTAL';
}
