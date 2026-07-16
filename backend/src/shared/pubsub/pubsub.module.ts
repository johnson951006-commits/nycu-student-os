import { Global, Module, type Provider } from '@nestjs/common';
import { PubSub } from '@google-cloud/pubsub';
import { PUBSUB_CLIENT, PubSubService } from './pubsub.service';

/**
 * Provides the Cloud Pub/Sub client and publisher (BIS §1.5). The client honours
 * PUBSUB_EMULATOR_HOST when set (local/CI), and constructs without any network call,
 * so importing this module is boot-safe.
 */
const pubsubClientProvider: Provider = {
  provide: PUBSUB_CLIENT,
  useFactory: () => new PubSub(),
};

@Global()
@Module({
  providers: [pubsubClientProvider, PubSubService],
  exports: [PubSubService],
})
export class PubSubModule {}
