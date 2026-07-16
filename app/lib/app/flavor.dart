import 'package:flutter/foundation.dart' show appFlavor;

/// Build flavors (FA §8). Selected at build/run time via Flutter's `--flavor`
/// (see .vscode/launch.json), read back at runtime through [appFlavor]. Defaults
/// to [Flavor.dev] when no flavor is set (e.g. in tests).
enum Flavor { dev, staging, prod }

Flavor get currentFlavor {
  switch (appFlavor) {
    case 'prod':
      return Flavor.prod;
    case 'staging':
      return Flavor.staging;
    case 'dev':
    default:
      return Flavor.dev;
  }
}
