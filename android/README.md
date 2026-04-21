# Android native scaffold maintenance

This directory should contain the Flutter-generated Android host project (`android/app`, Gradle wrapper, and root Gradle settings) used by CI and release builds.

## Regeneration policy
- Regenerate from repository root with: `flutter create .`
- Regenerate when:
  - upgrading Flutter across stable channels/major versions,
  - Android Gradle Plugin/Kotlin/Gradle wrapper templates drift from Flutter defaults,
  - native Android scaffold files are missing or corrupted.

## Flutter version expectations
- Use the Flutter SDK version pinned by the repository/tooling (CI should run the same version).
- Do not commit machine-specific output; only commit deterministic scaffold/config files required to build in CI.

## Ownership
- Primary owners: Mobile Platform / Build Infrastructure maintainers.
- Feature teams may edit app-level Android configuration, but scaffold regeneration decisions should be reviewed by owners.
