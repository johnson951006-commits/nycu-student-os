import { NodeSDK } from '@opentelemetry/sdk-node';
import { getNodeAutoInstrumentations } from '@opentelemetry/auto-instrumentations-node';
import { OTLPTraceExporter } from '@opentelemetry/exporter-trace-otlp-http';

let sdk: NodeSDK | undefined;

/**
 * Initialises OpenTelemetry tracing (BIS §1.7). Called once at process bootstrap
 * before the Nest app is created so auto-instrumentation can patch pg/redis/http.
 * Traces export via OTLP to the collector at `OTEL_EXPORTER_OTLP_ENDPOINT`; when
 * unset (local/CI) the SDK stays inert. Service identity comes from env-based
 * resource detection — the bootstrap defaults `OTEL_SERVICE_NAME` from the active
 * `APP_PROFILE` so api/worker spans are distinguishable.
 */
export function initTelemetry(): void {
  if (sdk || !process.env.OTEL_EXPORTER_OTLP_ENDPOINT) {
    return;
  }
  process.env.OTEL_SERVICE_NAME ??= `nycu-student-os-${process.env.APP_PROFILE ?? 'api'}`;

  sdk = new NodeSDK({
    traceExporter: new OTLPTraceExporter(),
    instrumentations: [
      getNodeAutoInstrumentations({
        // fs spans are noisy and low-value for this workload.
        '@opentelemetry/instrumentation-fs': { enabled: false },
      }),
    ],
  });
  sdk.start();
}

export async function shutdownTelemetry(): Promise<void> {
  await sdk?.shutdown();
  sdk = undefined;
}
