import { Global, Module, type Provider } from '@nestjs/common';
import { KeyManagementServiceClient } from '@google-cloud/kms';
import { KMS_CLIENT, KmsEnvelopeService } from './kms-envelope.service';

/**
 * Provides the Cloud KMS client and the envelope service (BIS §7). The client is
 * constructed lazily by the Google SDK (no network call until first use), so
 * importing this module is safe at boot without live credentials.
 */
const kmsClientProvider: Provider = {
  provide: KMS_CLIENT,
  useFactory: () => new KeyManagementServiceClient(),
};

@Global()
@Module({
  providers: [kmsClientProvider, KmsEnvelopeService],
  exports: [KmsEnvelopeService],
})
export class CryptoModule {}
