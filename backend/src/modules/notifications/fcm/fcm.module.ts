import { Module } from '@nestjs/common';
import { App, cert, getApps, initializeApp } from 'firebase-admin/app';
import { getMessaging } from 'firebase-admin/messaging';
import { childLogger } from '../../../shared/logging/logger';
import {
  FCM_SENDER,
  FcmPush,
  FcmSendResult,
  FcmSender,
} from './fcm-sender';

/**
 * firebase-admin adapter for the [FcmSender] port (BIS §4.2 / DV1): HTTP v1
 * `sendEach`, batches ≤500, iOS via FCM's APNs relay (the APNs .p8 key lives
 * in the Firebase project — infra/README.md runbook). Credentials come from
 * the `fcm-service-account` Secret Manager secret mounted as
 * FCM_SERVICE_ACCOUNT_JSON (OPS §1.2); absent locally, initialization is
 * deferred so importing this module never requires live credentials.
 */
export class FirebaseFcmSender extends FcmSender {
  private readonly log = childLogger('fcm');
  private app: App | null = null;

  async sendEach(messages: readonly FcmPush[]): Promise<FcmSendResult[]> {
    const messaging = getMessaging(this.firebase());
    const results: FcmSendResult[] = [];

    for (let i = 0; i < messages.length; i += FcmSender.maxBatch) {
      const batch = messages.slice(i, i + FcmSender.maxBatch);
      const response = await messaging.sendEach(
        batch.map((m) => ({
          token: m.token,
          notification: m.notification,
          data: m.data,
          android: { notification: { channelId: m.androidChannel } },
          apns: m.apnsInterruptionLevel
            ? { payload: { aps: { 'interruption-level': m.apnsInterruptionLevel } } }
            : undefined,
        })),
      );
      response.responses.forEach((r, idx) => {
        const token = batch[idx].token;
        if (r.success) {
          results.push({ token, status: 'sent' });
          return;
        }
        const code = r.error?.code ?? 'unknown';
        // Token-lifecycle mapping (BIS §4.2): dead registrations are
        // permanent; everything else is retryable per §4.3.
        const invalid =
          code === 'messaging/registration-token-not-registered' ||
          code === 'messaging/invalid-registration-token' ||
          code === 'messaging/invalid-argument';
        results.push({
          token,
          status: invalid ? 'invalid_token' : 'transient_error',
          errorCode: code,
        });
      });
    }
    this.log.debug({ count: messages.length }, 'fcm sendEach complete');
    return results;
  }

  private firebase(): App {
    if (this.app) {
      return this.app;
    }
    const existing = getApps();
    if (existing.length > 0) {
      this.app = existing[0];
      return this.app;
    }
    const raw = process.env.FCM_SERVICE_ACCOUNT_JSON;
    if (!raw) {
      throw new Error(
        'fcm: FCM_SERVICE_ACCOUNT_JSON is not configured (Secret Manager mount, OPS §1.2)',
      );
    }
    this.app = initializeApp({
      credential: cert(JSON.parse(raw) as Record<string, string>),
    });
    return this.app;
  }
}

/** Binds the production adapter to the [FCM_SENDER] port. */
@Module({
  providers: [{ provide: FCM_SENDER, useClass: FirebaseFcmSender }],
  exports: [FCM_SENDER],
})
export class FcmModule {}
