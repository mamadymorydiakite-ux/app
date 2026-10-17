# Link — interactive mockup

Link connects an **Android phone** and a **Windows computer** directly over their local
Wi-Fi network. Everything is 100 % offline: no account, no cloud, no internet server and no
remote database. Data never leaves the two devices — it works even when the local network has
no internet access.

This repository contains **two implementations of the same interactive mockup**:

| Implementation | Folder | What it is |
| --- | --- | --- |
| Flutter (Dart) app | `app/` | The real cross-platform app: Android phone shell + Windows desktop shell, all screens and interactions, 100 % offline. **Recommended.** |
| HTML/CSS/JS mockup | `index.html`, `mobile.html`, `desktop.html`, `assets/` | The original browser prototype of the very same design. |

## Flutter app (`app/`)

Built with the Flutter SDK only — no third-party packages, no network calls, no analytics.
The Outfit typeface is bundled in `app/assets/fonts/`, so the app renders identically with no
internet connection.

| Path | What it is |
| --- | --- |
| `app/lib/main.dart` | Hub: shows the phone (390 × 844) and the desktop window (1100 × 700) side by side, or one at a time on small screens. |
| `app/lib/theme.dart` | Design system: palette, radii, shadows, typography (`Outfit`). |
| `app/lib/state/link_controller.dart` | Single source of truth shared by both shells: connection state machine (`disconnected → connecting → connected → error`), transfers, clipboard, devices, settings, screen share. |
| `app/lib/widgets/` | Shared UI kit: cards, pill buttons, status badges, tabs, progress bars, spinners, prototype state switcher. |
| `app/lib/mobile/` | Android shell: bottom navigation (Home, Files, Clipboard, Tools, Settings) and all phone screens. |
| `app/lib/desktop/` | Windows shell: sidebar (Overview, Files, Clipboard, Keyboard, Mouse, Screen, Ring Phone, Settings) and all desktop screens. |
| `app/test/link_app_test.dart` | 14 tests: state machine, mobile journey, desktop journey, screen-share flow, design system. |

```bash
cd app
flutter pub get
flutter test          # 14 tests
flutter run           # -d chrome, -d android, -d windows …
flutter build web     # or: flutter build apk
```

**SDK compatibility.** The project only depends on the Flutter SDK itself, and the Dart
constraint is deliberately wide (`>=3.8.0 <4.0.0`). It is verified on both **Flutter 3.44.9 /
Dart 3.12.2** and **Flutter 3.47.7 / Dart 3.13.5** (`flutter pub get`, `flutter analyze`,
`flutter test`, `flutter build web`). If `flutter pub get` reports a version-solving error,
your Flutter is older than 3.32 (Dart 3.8): run `flutter upgrade`, or widen the constraint
further. `pubspec.lock` is not committed on purpose — it is regenerated for whatever SDK you
use.

Both shells share one `LinkController`, so the phone and the computer always show the same
state — exactly like the *Sync both* button of the HTML hub. Settings → **Prototype** in either
shell jumps between the four connection states (and can simulate a failed pairing).

### Behaviour

* Full navigation in both apps (bottom bar / sidebar), including back links on every sub-screen.
* State machine — **disconnected → connecting → connected → error** — driven by scanning the QR
  code, entering an IP, retrying, cancelling or disconnecting.
* Animated progress bars, connection spinner, pulsing `LIVE` badge, scan line, ringing waves,
  live trackpad and keyboard mirroring.
* Interactive switches, tabs, segmented quality control, sliders and a working trackpad.
* “Everything is local” is reinforced everywhere: `LOCAL` badge, *Local Connection Only*,
  *No internet required*, *Synced locally*, *Wi-Fi Direct*.

## HTML/CSS/JS mockup

No build step, no dependencies — open `index.html` in a browser (or `mobile.html` /
`desktop.html` directly).

| File | What it is |
| --- | --- |
| `index.html` | Hub: shows the phone (390 × 844) and the desktop window (1100 × 700) side by side, with a state switcher that drives both. **Start here.** |
| `mobile.html` | The Android app on its own (390 × 844). |
| `desktop.html` | The Windows app on its own (1100 × 700 window chrome). |
| `assets/css/base.css` | Shared design system: palette, cards, buttons, badges, switches, tabs, progress bars, animations. |
| `assets/css/mobile.css` | Android phone layout. |
| `assets/css/desktop.css` | Desktop window layout. |
| `assets/js/ui.js` | Shared runtime: inline SVG icon set, tiny observable store, helpers, toast, postMessage bridge. |
| `assets/js/mobile.js` | Android mockup behaviour. |
| `assets/js/desktop.js` | Desktop mockup behaviour. |

No build step, no dependencies — open `index.html` in a browser (or `mobile.html` /
`desktop.html` directly).

## Design language

Adwaita-inspired, warm autumn palette, very rounded shapes.

| Token | Value | Usage |
| --- | --- | --- |
| Background | `#F0E9DD` | App background |
| Card | `#FBF7F1` | Cards, 1 px `#E0D6C6` border, 16 px radius, soft shadow |
| Accent | `#DD5B35` | Primary buttons, active tab, progress bars, active icons |
| Accent soft | `#F7DDD1` | Icon backgrounds |
| Text / secondary | `#2A2420` / `#8A8074` | Body / muted copy |
| Success | `#4C8C4E` on `#E3EFE0` | Done, active, local badges |
| Error | `#C0392B` on `#F6E1DD` | Failures, destructive actions |
| Waiting | `#DD9A35` on `#F7EBD6` | Pending states |
| Dark | `#1A1A1A` | QR scanner screen only |

Typeface: geometric sans-serif (Outfit, falling back to Inter / system sans).
Logo: two interlinked chain links in terracotta next to the word **Link**.

## Mobile app (390 × 844)

Bottom navigation with 5 tabs — **Home, Files, Clipboard, Tools, Settings** — and a `LOCAL`
badge in the status bar once paired.

1. **Home** — offline-first pairing, *Connect to your PC*, orange *Scan QR Code*, manual IP entry, *Looking for PC on network…* pill, *No internet required. Paired locally.*
2. **QR Scanner** — dark screen, orange rounded frame with animated scan line, *Use IP Address*, *PAIRING VIA WI-FI DIRECT* (the camera detects the desktop code automatically after a few seconds).
3. **Connecting** — animated spinner, *Connecting to Desktop-PC…*, IP address, local handshake checklist, *Cancel Connection*.
4. **Error** — *Connection Failed*, error code, *Retry Connection*, *Scan QR Code Instead*.
5. **Dashboard** — *Connected Seamlessly*, *Stop*, 2-column tile grid (Send Files, Clipboard `ACTIVE`, Keyboard, Touchpad, Ring Phone, Connection `192.168.1.42 • Wi-Fi`, Screen Share) and *Direct Local Speed 340 Mbps*.
6. **Send Files** — dashed orange drop zone, *Recent Transfers* with live progress, completed checks and direction arrows.
7. **File Transfer** — progress bar, speed, time remaining, *Cancel Transfer*, queue with *Clear All*.
8. **Clipboard** — *Clipboard Sync* + *Synced locally*, Phone / PC tabs, history cards with *Paste on Phone* / *Send to PC*.
9. **Keyboard** — big orange input, live keycaps, *Show on-screen keyboard*, *Activate Typing*, *Clear Text*.
10. **Mouse & Trackpad** — real draggable trackpad (swipe = move, two fingers = scroll, tap = left click, two-finger tap = right click), *Drag Lock*.
11. **Ring Phone** — pulsing bell, *Ringing Connected PC*, volume slider, *Stop Alert*.
12. **Connected Devices** — active device card with session stats, *Disconnect Device*, connection history.
13. **Screen Share** *(new)* — idle state, simulated Android *“Start recording or casting with Link?”* dialog, then live preview with pulsing `LIVE` badge, elapsed time, latency, Low / Balanced / High quality, *Stop Sharing* and the persistent notification.
14. **Settings** — language, start on boot, notifications, preferred port, timeout, pairing PIN, local TLS, allowed devices, version, licences, plus a **Prototype** card to switch states.

## Desktop app (1100 × 700)

Rounded window with red / yellow / green traffic lights, the screen name in the title bar and a
status pill (`● Pixel 8 Pro` when connected, `Offline Mode` otherwise). Left sidebar: brand,
**Overview, Files, Clipboard, Keyboard, Mouse, Screen, Ring Phone, Settings**, then a pink
*Disconnect* button and *Local Connection Only*.

1. **Ready to Connect** — real placeholder QR code, *Local IP: 192.168.1.42* with copy button, *Connect with IP Address instead*, *Waiting for device…*.
2. **Connecting** — spinner, IP card, *Cancel Connection*.
3. **Connection Failed** — red ✕, *Try Again*, *Troubleshoot network issues*.
4. **Connected** — welcome back copy, Wi-Fi Direct badge, Session Time / Local Speed / Transferred stats and the list of connected phones with a disconnect button per device.
5. **Files** — 3 columns: Phone, dashed *Drag files here to send instantly*, Computer, plus *Recent Transfers* with progress and statuses.
6. **File Transfer Complete** — green check, 3 files / 14.2 MB, file list, *Send More Files*, *Done*.
7. **Clipboard Sync** — *Synced Locally*, two columns with time stamps and *Copy to PC* / *Copy to Phone*.
8. **Remote Keyboard** — Pixel 8 Pro ↔ Your Computer diagram, live *Received text* field, *Start Keyboard Receiver*.
9. **Remote Touchpad** — *Virtual Trackpad Active*, *Latency < 2ms*, supported gestures, *Start Mouse Control*.
10. **Screen** *(new)* — waiting state with the phone → computer diagram, live state with the phone frame, `LIVE` badge, latency / FPS / resolution / bitrate, Low-Balanced-High quality, *Fullscreen / Screenshot / Stop* toolbar, and an interrupted state (*Screen share interrupted — Reconnecting…*).
11. **Ring Phone** — bell, *Ring Phone* / *Stop Ringing*, *Your phone will ring at full volume*.
12. **Settings** — General, Connection (port 8080, auto-connect, 30 s timeout), Security (PIN, local TLS, allowed devices), About (1.0.0 Stable, check for updates, licences) and a Prototype panel.

## Behaviour

* Full navigation in both apps (bottom bar / sidebar), including back links on every sub-screen.
* State machine — **disconnected → connecting → connected → error** — driven from the hub buttons, from Settings → Prototype, or by using the app (scan the QR code, enter an IP, retry, cancel, disconnect).
* Animated progress bars, connection spinner, pulsing `LIVE` badge, scan line, ringing waves.
* Interactive switches, tabs, segmented quality control, sliders and a working trackpad.
* “Everything is local” is reinforced everywhere: `LOCAL` badge, *Local Connection Only*, *No internet required*, *Synced locally*, *Wi-Fi Direct*.
* The two frames talk over `postMessage`, so pressing *Sync both* keeps the phone and the computer in the same state.
