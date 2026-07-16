import type { DynamicModule, Type } from '@nestjs/common';
import type { AppProfile } from './app-profile';

/**
 * Profile → module wiring (BIS §1.2).
 *
 * Returns the profile-specific Nest modules to import, on top of the always-present
 * base set (AppConfigModule, imported by AppModule). Feature and infrastructure tasks
 * register their modules here as they land:
 *   - api          → HTTP controllers (auth, courses, assignments, … + health)
 *   - sync-worker  → sync consumers + PortalModule
 *   - notif-worker → notification consumers + dispatcher
 *   - jobs         → scheduler
 * At scaffold time no feature modules exist yet, so every profile loads only the
 * base set (an empty extra-module list). The switch is exhaustive so a new profile
 * cannot be added without a compile error here.
 */
export function modulesForProfile(
  profile: AppProfile,
): Array<Type<unknown> | DynamicModule> {
  switch (profile) {
    case 'api':
      return [];
    case 'sync-worker':
      return [];
    case 'notif-worker':
      return [];
    case 'jobs':
      return [];
    default: {
      const exhaustive: never = profile;
      throw new Error(`Unhandled APP_PROFILE: ${String(exhaustive)}`);
    }
  }
}
