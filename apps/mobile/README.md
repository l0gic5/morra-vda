# Morra Valdostana – Mobile app

Flutter app for **Morra Valdostana** tournaments. It is the player and scorekeeper client of the project described in the [root README](../../README.md).

## Structure

```
lib/
 ├─ main.dart
 ├─ presentation/    # screens and widgets
 └─ application/     # controllers, state management
```

The domain logic does **not** live in this app. Scoring, and later pairing and ranking, come from the shared package [`packages/morra_rules`](../../packages/morra_rules), declared in `pubspec.yaml` as a path dependency:

```yaml
dependencies:
  morra_rules:
    path: ../../packages/morra_rules
```

That keeps the rules free of Flutter dependencies, so the future Serverpod backend can use exactly the same code.

## Run

```bash
flutter pub get
flutter run
```

## Test and analyze

```bash
flutter analyze
flutter test
```

Rule tests (scoring, lowering the hand, game and match victory) live in the `morra_rules` package and run with `dart test`.

## Backend

The backend will be a Serverpod server in `apps/server`, and the app will talk to it through the generated client package. Until then the app works fully offline.

## Before releasing

The application ID is still the default `com.example.morra_vda`. Replace it before the first store release, because it cannot be changed afterwards.

Only Android and iOS are targeted. Other platform folders can be generated when needed, for example `flutter create --platforms=web .`.
