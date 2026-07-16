import { Module, type DynamicModule } from '@nestjs/common';
import { AppConfigModule } from './config/config.module';
import { modulesForProfile } from './config/profiles';
import type { AppProfile } from './config/app-profile';

/**
 * Root module (BIS §1.1). Assembled per run profile: the always-present base set
 * (typed config) plus the profile-specific modules (BIS §1.2, see profiles.ts).
 */
@Module({})
export class AppModule {
  static register(profile: AppProfile): DynamicModule {
    return {
      module: AppModule,
      imports: [AppConfigModule, ...modulesForProfile(profile)],
    };
  }
}
