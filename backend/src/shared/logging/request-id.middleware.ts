import { randomUUID } from 'node:crypto';
import { Injectable, type NestMiddleware } from '@nestjs/common';
import type { NextFunction, Request, Response } from 'express';
import { runWithRequestContext } from './request-context';

const REQUEST_ID_HEADER = 'x-request-id';

/**
 * Establishes the per-request correlation id (BIS §1.6): reuse an inbound
 * `x-request-id` when a trusted upstream (Cloud Run / load balancer) supplied one,
 * otherwise mint a UUID. The id is echoed on the response and made ambient for the
 * duration of the request so logs and error bodies share it.
 */
@Injectable()
export class RequestIdMiddleware implements NestMiddleware {
  use(req: Request, res: Response, next: NextFunction): void {
    const inbound = req.headers[REQUEST_ID_HEADER];
    const requestId =
      (Array.isArray(inbound) ? inbound[0] : inbound)?.trim() || randomUUID();

    res.setHeader(REQUEST_ID_HEADER, requestId);
    runWithRequestContext({ requestId }, () => next());
  }
}
