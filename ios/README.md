# iOS native scaffold maintenance

This directory should contain the Flutter-generated iOS host project (`Runner.xcodeproj`, `Runner.xcworkspace`, and Flutter/Xcode build settings) used by CI and release builds.

## Regeneration policy
- Regenerate from repository root with: `flutter create .`
- Regenerate when:
  - upgrading Flutter across stable channels/major versions,
  - iOS project template settings drift from Flutter defaults,
  - native iOS scaffold files are missing or corrupted.

## Flutter version expectations
- Use the Flutter SDK version pinned by the repository/tooling (CI should run the same version).
- Commit only deterministic build inputs; do not commit local IDE/user state files.

## Ownership
- Primary owners: Mobile Platform / Build Infrastructure maintainers.
- Feature teams may change app-level iOS settings, but scaffold regeneration should be reviewed by owners.
