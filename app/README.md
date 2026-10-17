# Link — Flutter app

Offline interactive mockup of **Link**: an Android phone and a Windows computer paired directly
over their local Wi-Fi (no account, no cloud, no internet).

* `lib/main.dart` — hub: phone (390 × 844) and desktop window (1100 × 700) side by side.
* `lib/mobile/` — Android shell (bottom navigation: Home, Files, Clipboard, Tools, Settings).
* `lib/desktop/` — Windows shell (sidebar: Overview, Files, Clipboard, Keyboard, Mouse, Screen,
  Ring Phone, Settings).
* `lib/state/link_controller.dart` — shared state machine and all mock data.
* `lib/theme.dart`, `lib/widgets/` — design system (palette, cards, pill buttons, badges, tabs,
  progress bars, spinner, prototype state switcher). Outfit is bundled in `assets/fonts/`.

## Getting started

```bash
flutter pub get
flutter test        # 14 tests: state machine, mobile journey, desktop journey, design system
flutter run         # -d chrome, -d android, -d windows …
flutter build apk   # or: flutter build web
```

**SDK compatibility.** Only the Flutter SDK is used (no third-party packages) and the Dart
constraint is wide (`>=3.8.0 <4.0.0`). Verified with Flutter 3.44.9 / Dart 3.12.2 and
Flutter 3.47.7 / Dart 3.13.5. `pubspec.lock` is intentionally not committed.

See the repository root `README.md` for the full description of both the Flutter app and the
original HTML mockup.

