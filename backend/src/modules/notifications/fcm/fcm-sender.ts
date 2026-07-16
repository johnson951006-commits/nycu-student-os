/**
 * FcmSender port (BIS §4.2 / DV1): push delivery is FCM-only — one sender
 * path, one retry policy, one token lifecycle. This is the seam the notif
 * pipeline (DEADLINE tasks) injects and tests against; production binds the
 * firebase-admin adapter (fcm.module.ts), tests bind [FakeFcmSender].
 */

/** DI token for the bound sender implementation. */
export const FCM_SENDER = Symbol('FCM_SENDER');

/** Payload contract (BIS §4.2) — every push carries exactly this shape. */
export interface FcmPush {
  /** Target device push token (devices.push_token). */
  token: string;
  notification: { title: string; body: string };
  data: {
    deepLink: string;
    centerEntryId: string;
    /** scheduleId + generation enable client-side dedup (IRR §6.6). */
    scheduleId: string;
    generation: string;
  };
  /** Android notification channel per kind (BIS §4.2). */
  androidChannel: string;
  /** APNs interruption level; time-sensitive for <24h deadline reminders. */
  apnsInterruptionLevel?: 'passive' | 'active' | 'time-sensitive';
}

export type FcmSendStatus = 'sent' | 'invalid_token' | 'transient_error';

export interface FcmSendResult {
  token: string;
  status: FcmSendStatus;
  /** Provider error code when status ≠ sent (diagnostics only, never PII). */
  errorCode?: string;
}

export abstract class FcmSender {
  /** FCM HTTP v1 sendEach hard batch limit (BIS §4.2). */
  static readonly maxBatch = 500;

  /**
   * Sends every message, batching at [maxBatch]; returns one result per input
   * in order. `invalid_token` feeds the token lifecycle
   * (devices.push_enabled=false — owned by the notif pipeline tasks);
   * `transient_error` is retryable per BIS §4.3.
   */
  abstract sendEach(messages: readonly FcmPush[]): Promise<FcmSendResult[]>;
}

/**
 * In-memory fake for tests (DoD: "FCM stub sends via fake"): records every
 * push, honours the batch contract, and simulates failures per token.
 */
export class FakeFcmSender extends FcmSender {
  readonly sent: FcmPush[] = [];
  readonly batchSizes: number[] = [];
  private readonly failWith = new Map<string, FcmSendStatus>();

  /** Makes every send to [token] report [status]. */
  failToken(token: string, status: Exclude<FcmSendStatus, 'sent'>): void {
    this.failWith.set(token, status);
  }

  async sendEach(messages: readonly FcmPush[]): Promise<FcmSendResult[]> {
    const results: FcmSendResult[] = [];
    for (let i = 0; i < messages.length; i += FcmSender.maxBatch) {
      const batch = messages.slice(i, i + FcmSender.maxBatch);
      this.batchSizes.push(batch.length);
      for (const message of batch) {
        const failure = this.failWith.get(message.token);
        if (failure) {
          results.push({ token: message.token, status: failure });
        } else {
          this.sent.push(message);
          results.push({ token: message.token, status: 'sent' });
        }
      }
    }
    return results;
  }
}
