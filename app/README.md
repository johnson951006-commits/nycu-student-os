# NYCU Student OS — Client (Flutter)

Local-first Flutter app (FA §1). This is the **scaffold** (INFRA-008): the
flash-free bootstrap sequence, the composition root, and the `core/{db,storage}`
shells. The token-generated theme, `AppFailure`, localization (ARB), and the
component library are added by INFRA-009; routing and features by their own tasks.

## First-time setup (requires the pinned Flutter SDK — see `../.fvmrc`)

```bash
cd app
flutter create .          # generates the native platform shells (android/ios/web)
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # drift codegen (*.g.dart)
```

`flutter create .` and `build_runner` are tool-generated steps (like `pnpm install`
for the backend); the authored source lives under `lib/` and `test/`.

## Run (flavors — FA §8)

```bash
flutter run --flavor dev --target lib/main.dart
flutter run --flavor staging --target lib/main.dart
flutter run --flavor prod --target lib/main.dart
```

## Test

```bash
flutter test              # bootstrap widget test + store-open smoke
flutter analyze
```

## Bootstrap order (FA §4 — no flash-of-wrong-theme)

`main()` → `bootstrap()`:
1. secure storage → SQLCipher key (FES §13)
2. drift(SQLCipher) → domain database
3. Hive → structured caches
4. SharedPreferences → theme/locale snapshot (read synchronously)

…then `runApp(ProviderScope(overrides: …))` seeds the stores + snapshot so the
first frame already uses the persisted theme mode and locale.

## Store roles (FA §9.2)

| Store | Holds |
|---|---|
| drift (SQLCipher) | the local-first domain database (encrypted) |
| Hive | structured caches (config/layout/snapshot/jwks) — safe to lose |
| SharedPreferences | primitives (theme mode, locale, flags) |
| flutter_secure_storage | sensitive material only (SQLCipher key; JWT later) |
