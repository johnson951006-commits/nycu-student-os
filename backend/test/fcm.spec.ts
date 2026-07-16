import {
  FakeFcmSender,
  FcmPush,
  FcmSender,
} from '../src/modules/notifications/fcm/fcm-sender';

/** INFRA-010 DoD: the FCM stub sends via the fake, honouring BIS §4.2. */
describe('FcmSender port (BIS §4.2 / DV1)', () => {
  function push(i: number): FcmPush {
    return {
      token: `device-token-${i}`,
      notification: { title: 'Deadline soon', body: 'OS HW3 due in 3h' },
      data: {
        deepLink: 'nycuos://assignments/abc',
        centerEntryId: 'ce-1',
        scheduleId: 'sch-1',
        generation: '2',
      },
      androidChannel: 'deadlines',
      apnsInterruptionLevel: 'time-sensitive',
    };
  }

  it('sends and records the full payload contract', async () => {
    const fake = new FakeFcmSender();
    const results = await fake.sendEach([push(1)]);

    expect(results).toEqual([{ token: 'device-token-1', status: 'sent' }]);
    const sent = fake.sent[0];
    // scheduleId+generation present — client-side dedup contract (IRR §6.6)
    expect(sent.data.scheduleId).toBe('sch-1');
    expect(sent.data.generation).toBe('2');
    expect(sent.apnsInterruptionLevel).toBe('time-sensitive');
  });

  it('splits batches at the 500-message FCM limit', async () => {
    const fake = new FakeFcmSender();
    const messages = Array.from({ length: 1201 }, (_, i) => push(i));
    const results = await fake.sendEach(messages);

    expect(results).toHaveLength(1201);
    expect(fake.batchSizes).toEqual([500, 500, 201]);
    expect(FcmSender.maxBatch).toBe(500);
  });

  it('reports invalid tokens and transient errors per-message, in order', async () => {
    const fake = new FakeFcmSender();
    fake.failToken('device-token-1', 'invalid_token');
    fake.failToken('device-token-2', 'transient_error');

    const results = await fake.sendEach([push(0), push(1), push(2)]);

    expect(results.map((r) => r.status)).toEqual([
      'sent',
      'invalid_token',
      'transient_error',
    ]);
    expect(fake.sent).toHaveLength(1);
  });
});
