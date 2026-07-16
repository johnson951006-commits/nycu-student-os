import { Inject, Injectable } from '@nestjs/common';
import { childLogger } from '../logging/logger';

/** DI token for the Cloud Pub/Sub client (BA §12 / BIS §1.5). */
export const PUBSUB_CLIENT = Symbol('PUBSUB_CLIENT');

/** Minimal publisher surface we depend on — keeps the service unit testable. */
export interface PubSubClientLike {
  topic(name: string): {
    publishMessage(message: {
      data: Buffer;
      attributes?: Record<string, string>;
      orderingKey?: string;
    }): Promise<string>;
  };
}

export interface PublishOptions {
  attributes?: Record<string, string>;
  orderingKey?: string;
}

/**
 * Typed Pub/Sub publisher (BIS §1.5). Serialises payloads as JSON, always stamps a
 * schema `type` attribute for consumer routing, and offers an explicit DLQ publish
 * for permanent failures a worker chooses to divert rather than let redelivery
 * exhaust. Topic names are resolved through env so dev/staging/prod stay isolated.
 */
@Injectable()
export class PubSubService {
  private readonly log = childLogger('pubsub');

  constructor(@Inject(PUBSUB_CLIENT) private readonly client: PubSubClientLike) {}

  async publish<T>(
    topic: string,
    type: string,
    payload: T,
    options: PublishOptions = {},
  ): Promise<string> {
    const data = Buffer.from(JSON.stringify(payload), 'utf8');
    const id = await this.client.topic(topic).publishMessage({
      data,
      attributes: { type, ...options.attributes },
      ...(options.orderingKey ? { orderingKey: options.orderingKey } : {}),
    });
    this.log.debug({ topic, type, messageId: id }, 'published');
    return id;
  }

  /** Divert a permanently-failed message to its dead-letter topic (BIS §1.5). */
  async publishToDlq<T>(
    dlqTopic: string,
    type: string,
    payload: T,
    reason: string,
  ): Promise<string> {
    this.log.warn({ dlqTopic, type, reason }, 'diverting message to DLQ');
    return this.publish(dlqTopic, type, payload, { attributes: { dlqReason: reason } });
  }
}
