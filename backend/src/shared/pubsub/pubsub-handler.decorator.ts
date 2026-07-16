import { SetMetadata } from '@nestjs/common';

export const PUBSUB_HANDLER_METADATA = Symbol('PUBSUB_HANDLER_METADATA');

export interface PubSubHandlerMetadata {
  /** The subscription this method consumes. */
  subscription: string;
  /** Optional schema-type filter; when set, only matching messages are dispatched. */
  type?: string;
}

/**
 * Marks a worker method as the consumer for a Pub/Sub subscription (BIS §1.5). The
 * worker bootstrap (sync/notif profiles) scans providers for this metadata and binds
 * each handler to its subscription; the handler classifies failures via
 * TransientError (nack → redeliver) vs PermanentError (ack → DLQ).
 */
export const PubSubHandler = (metadata: PubSubHandlerMetadata): MethodDecorator =>
  SetMetadata(PUBSUB_HANDLER_METADATA, metadata);

/** Reads handler metadata off a method (used by the worker binder). */
export function getPubSubHandlerMetadata(
  target: object,
): PubSubHandlerMetadata | undefined {
  return Reflect.getMetadata(PUBSUB_HANDLER_METADATA, target) as
    | PubSubHandlerMetadata
    | undefined;
}
