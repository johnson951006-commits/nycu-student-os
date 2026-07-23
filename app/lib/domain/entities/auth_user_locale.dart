/// UI/content locale (DB §7 `users.locale` CHECK — the closed domain).
///
/// [wireValue] is the exact string the API and database use; the enum is the
/// in-app representation so a new locale breaks compilation at every
/// exhaustive `switch` (FES §2).
enum UserLocale {
  zhTw('zh-TW'),
  en('en');

  const UserLocale(this.wireValue);

  final String wireValue;
}
