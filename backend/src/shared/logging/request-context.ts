import { AsyncLocalStorage } from 'node:async_hooks';

/**
 * Per-request ambient context (BIS §1.6). Carries the correlation id through async
 * call chains without threading it manually, so every log line and problem+json
 * body can be tied back to one request. Backed by Node's AsyncLocalStorage — no
 * external dependency.
 */
export interface RequestContext {
  requestId: string;
}

const storage = new AsyncLocalStorage<RequestContext>();

export function runWithRequestContext<T>(ctx: RequestContext, fn: () => T): T {
  return storage.run(ctx, fn);
}

export function getRequestId(): string | undefined {
  return storage.getStore()?.requestId;
}
