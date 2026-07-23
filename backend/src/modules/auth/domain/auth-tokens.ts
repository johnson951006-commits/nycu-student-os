/**
 * Token value object — the access/refresh pair the auth endpoints return
 * (BIS §5 `POST /auth/portal-session` · `/auth/refresh`). Immutable and
 * self-validating: the contract declares both tokens required, so a blank
 * token is never a valid value of this type.
 *
 * Holds the RAW refresh token (what the client receives). The server persists
 * only its hash — see `AppSession.refreshHash` (BIS §7 A02).
 */
export class AuthTokens {
  private constructor(
    readonly accessToken: string,
    readonly refreshToken: string,
  ) {}

  /**
   * @throws {RangeError} when either token is empty/blank — the invariant this
   * value object exists to guarantee.
   */
  static create(accessToken: string, refreshToken: string): AuthTokens {
    if (accessToken.trim().length === 0) {
      throw new RangeError('AuthTokens: accessToken must not be empty');
    }
    if (refreshToken.trim().length === 0) {
      throw new RangeError('AuthTokens: refreshToken must not be empty');
    }
    return Object.freeze(new AuthTokens(accessToken, refreshToken));
  }

  equals(other: AuthTokens): boolean {
    return (
      this.accessToken === other.accessToken &&
      this.refreshToken === other.refreshToken
    );
  }
}
