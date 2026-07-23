/// State of the user's NYCU Portal session (DB §7 `portal_sessions.status`
/// CHECK). Drives the session-expiry UX (IRR §3): the client renders the
/// server's verdict, it never infers Portal state itself.
enum PortalSessionStatus {
  active('ACTIVE'),
  stale('STALE'),
  expired('EXPIRED'),
  reauthRequired('REAUTH_REQUIRED');

  const PortalSessionStatus(this.wireValue);

  final String wireValue;
}
