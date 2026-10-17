import 'package:flutter/material.dart';

import '../state/link_controller.dart';
import '../theme.dart';
import '../widgets/link_widgets.dart';
import 'desktop_shell.dart';

class DesktopClipboardScreen extends StatelessWidget {
  const DesktopClipboardScreen({super.key, required this.controller, required this.go});

  final LinkController controller;
  final ValueChanged<DesktopSection> go;

  @override
  Widget build(BuildContext context) {
    final c = controller;
    final phoneEntries = c.clipboard.where((e) => e.source == ClipboardSource.phone).toList();
    final pcEntries = c.clipboard.where((e) => e.source == ClipboardSource.pc).toList();

    return DesktopScreen(
      title: 'Clipboard Sync',
      subtitle: 'Text copied on either device is instantly available on the other.',
      trailing: const StatusBadge(label: 'Synced Locally', tone: BadgeTone.ok),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _ClipboardColumn(
                title: 'Phone Clipboard',
                icon: Icons.smartphone_rounded,
                entries: phoneEntries,
                actionLabel: 'Copy to PC',
                onAction: (e) {
                  c.sendToPc(e);
                  showLinkToast(context, 'Copied to the computer clipboard');
                },
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _ClipboardColumn(
                title: 'PC Clipboard',
                icon: Icons.computer_rounded,
                entries: pcEntries,
                actionLabel: 'Copy to Phone',
                onAction: (e) {
                  c.pasteOnPhone(e);
                  showLinkToast(context, 'Copied to the phone clipboard');
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        LinkCard(
          child: LinkSwitchRow(
            icon: Icons.sync_rounded,
            label: 'Clipboard Sync',
            subtitle: 'Both clips stay on your two devices — nothing is sent to a server.',
            value: c.clipboardSync,
            onChanged: c.toggleClipboardSync,
          ),
        ),
      ],
    );
  }
}

class _ClipboardColumn extends StatelessWidget {
  const _ClipboardColumn({
    required this.title,
    required this.icon,
    required this.entries,
    required this.actionLabel,
    required this.onAction,
  });

  final String title;
  final IconData icon;
  final List<ClipboardEntry> entries;
  final String actionLabel;
  final ValueChanged<ClipboardEntry> onAction;

  @override
  Widget build(BuildContext context) {
    return LinkCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconTile(icon: icon, size: 32),
              const SizedBox(width: 10),
              Expanded(child: Text(title, style: LinkText.body.copyWith(fontWeight: FontWeight.w700))),
              Text('${entries.length} items', style: LinkText.small),
            ],
          ),
          const SizedBox(height: 12),
          for (final e in entries)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(LinkRadii.md),
                  border: Border.all(color: LinkColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(e.time, style: LinkText.pill.copyWith(color: LinkColors.muted)),
                    const SizedBox(height: 6),
                    Text(e.text, style: LinkText.body, maxLines: 3, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 10),
                    PillButton(
                      label: actionLabel,
                      tone: PillTone.soft,
                      dense: true,
                      onPressed: () => onAction(e),
                    ),
                  ],
                ),
              ),
            ),
          if (entries.isEmpty) Text('Nothing copied yet.', style: LinkText.small),
        ],
      ),
    );
  }
}

class DesktopKeyboardScreen extends StatelessWidget {
  const DesktopKeyboardScreen({super.key, required this.controller, required this.go});

  final LinkController controller;
  final ValueChanged<DesktopSection> go;

  @override
  Widget build(BuildContext context) {
    final c = controller;
    return DesktopScreen(
      title: 'Remote Keyboard',
      subtitle: 'Type on your computer using your phone',
      trailing: StatusBadge(
        label: c.keyboardActive ? 'Receiver active' : 'Idle',
        tone: c.keyboardActive ? BadgeTone.ok : BadgeTone.muted,
      ),
      children: [
        LinkCard(
          child: Row(
            children: [
              const IconTile(icon: Icons.keyboard_rounded, size: 44),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${c.phoneName} ↔ Your Computer', style: LinkText.h3),
                    const SizedBox(height: 4),
                    Text(
                      'Keystrokes travel directly over Wi-Fi — no internet hop.',
                      style: LinkText.small,
                    ),
                  ],
                ),
              ),
              const StatusBadge(label: 'Wi-Fi Direct', tone: BadgeTone.accent, dot: false),
            ],
          ),
        ),
        const SizedBox(height: 14),
        LinkCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionLabel('Received text'),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                constraints: const BoxConstraints(minHeight: 92),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(LinkRadii.md),
                  border: Border.all(color: LinkColors.border),
                ),
                child: Text(
                  c.keyboardText.isEmpty ? 'Waiting for the phone keyboard…' : c.keyboardText,
                  style: LinkText.body.copyWith(
                    fontSize: 15,
                    color: c.keyboardText.isEmpty ? LinkColors.faint : LinkColors.text,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  PillButton(
                    label: 'Start Keyboard Receiver',
                    icon: Icons.play_arrow_rounded,
                    onPressed: () {
                      c.activateTyping();
                      showLinkToast(context, 'Keyboard receiver listening on port ${c.preferredPort}');
                    },
                  ),
                  const SizedBox(width: 10),
                  PillButton(label: 'Clear', tone: PillTone.white, onPressed: c.clearText),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class DesktopMouseScreen extends StatelessWidget {
  const DesktopMouseScreen({super.key, required this.controller, required this.go});

  final LinkController controller;
  final ValueChanged<DesktopSection> go;

  static const _gestures = <(String, String)>[
    ('Left Click', 'Tap with one finger'),
    ('Right Click', 'Tap with two fingers'),
    ('Scroll Page', 'Drag with two fingers'),
    ('Drag Lock', 'Hold and move with two fingers'),
  ];

  @override
  Widget build(BuildContext context) {
    final c = controller;
    return DesktopScreen(
      title: 'Remote Touchpad',
      subtitle: 'Control your computer using your phone',
      trailing: const StatusBadge(label: 'Latency < 2ms', tone: BadgeTone.ok),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: LinkCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const IconTile(icon: Icons.touch_app_rounded, size: 58),
                    const SizedBox(height: 14),
                    Text('Virtual Trackpad Active', style: LinkText.h3),
                    const SizedBox(height: 6),
                    Text(
                      'Your phone screen now moves the pointer of this computer.',
                      textAlign: TextAlign.center,
                      style: LinkText.small,
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const StatusBadge(label: 'Wi-Fi Direct', tone: BadgeTone.accent, dot: false),
                        const SizedBox(width: 8),
                        StatusBadge(label: '${c.clickCount} clicks', tone: BadgeTone.muted, dot: false),
                      ],
                    ),
                    const SizedBox(height: 16),
                    PillButton(
                      label: 'Start Mouse Control',
                      expand: true,
                      icon: Icons.play_arrow_rounded,
                      onPressed: () {
                        c.click(right: false);
                        showLinkToast(context, 'Mouse control armed for ${c.phoneName}');
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: LinkCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionLabel('Supported Gestures'),
                    const SizedBox(height: 12),
                    for (final (name, hint) in _gestures)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 7),
                        child: Row(
                          children: [
                            const IconTile(icon: Icons.gesture_rounded, size: 30),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(name, style: LinkText.body.copyWith(fontWeight: FontWeight.w600)),
                                  Text(hint, style: LinkText.small),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}



class DesktopRingScreen extends StatelessWidget {
  const DesktopRingScreen({super.key, required this.controller, required this.go});

  final LinkController controller;
  final ValueChanged<DesktopSection> go;

  @override
  Widget build(BuildContext context) {
    final c = controller;
    return DesktopScreen(
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: c.ringing ? LinkColors.accentSoft : LinkColors.card,
                    shape: BoxShape.circle,
                    border: Border.all(color: LinkColors.border),
                    boxShadow: kSoftShadow,
                  ),
                  child: Icon(
                    Icons.notifications_active_rounded,
                    size: 52,
                    color: c.ringing ? LinkColors.accent : LinkColors.faint,
                  ),
                ),
                const SizedBox(height: 20),
                Text('Ring Your Phone', style: LinkText.h1, textAlign: TextAlign.center),
                const SizedBox(height: 8),
                Text(
                  "Can't find your phone nearby? Force it to play a loud ringtone even if silent mode "
                  'or Do Not Disturb is enabled.',
                  textAlign: TextAlign.center,
                  style: LinkText.body.copyWith(color: LinkColors.muted),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: PillButton(
                        label: 'Ring Phone',
                        expand: true,
                        icon: Icons.notifications_active_rounded,
                        onPressed: () {
                          c.startRinging();
                          showLinkToast(context, 'Ringing ${c.phoneName} at full volume');
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: PillButton(
                        label: 'Stop Ringing',
                        tone: PillTone.white,
                        expand: true,
                        icon: Icons.stop_rounded,
                        onPressed: c.stopRinging,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                StatusBadge(
                  label: c.ringing ? 'Ringing ${c.phoneName} now' : 'Your phone will ring at full volume',
                  tone: c.ringing ? BadgeTone.err : BadgeTone.warn,
                  pulse: c.ringing,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class DesktopScreenView extends StatelessWidget {
  const DesktopScreenView({super.key, required this.controller, required this.go});

  final LinkController controller;
  final ValueChanged<DesktopSection> go;

  @override
  Widget build(BuildContext context) {
    final c = controller;
    if (c.screenSharing && c.screenShareInterrupted) {
      return _Interrupted(controller: c);
    }
    if (!c.screenSharing) {
      return _Waiting(controller: c);
    }
    return _Live(controller: c);
  }
}

class _Waiting extends StatelessWidget {
  const _Waiting({required this.controller});

  final LinkController controller;

  @override
  Widget build(BuildContext context) {
    return DesktopScreen(
      title: 'Screen',
      subtitle: 'View your Android screen on this computer',
      trailing: const StatusBadge(label: 'Local network only', tone: BadgeTone.ok),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              children: [
                LinkCard(
                  padding: const EdgeInsets.all(22),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          const IconTile(icon: Icons.smartphone_rounded, size: 54),
                          const SizedBox(height: 8),
                          Text(controller.phoneName, style: LinkText.small),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 18),
                        child: Icon(Icons.arrow_forward_rounded, color: LinkColors.accent),
                      ),
                      Column(
                        children: [
                          const IconTile(icon: Icons.computer_rounded, size: 54),
                          const SizedBox(height: 8),
                          Text('Your Computer', style: LinkText.small),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Start Screen Share on your phone to see it here. Everything stays on your local network.',
                  textAlign: TextAlign.center,
                  style: LinkText.body.copyWith(color: LinkColors.muted),
                ),
                const SizedBox(height: 18),
                PillButton(
                  label: 'Simulate incoming screen share',
                  expand: true,
                  icon: Icons.cast_connected_rounded,
                  onPressed: controller.confirmScreenShare,
                ),
                const SizedBox(height: 10),
                Text(
                  'Nothing is recorded and nothing leaves your Wi-Fi.',
                  textAlign: TextAlign.center,
                  style: LinkText.small.copyWith(color: LinkColors.faint),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}



class _Live extends StatelessWidget {
  const _Live({required this.controller});

  final LinkController controller;

  static const _qualities = ['Low', 'Balanced', 'High'];

  @override
  Widget build(BuildContext context) {
    final c = controller;
    return DesktopScreen(
      title: 'Screen',
      subtitle: 'Live view of ${c.phoneName} — mirrored over Wi-Fi Direct.',
      trailing: const StatusBadge(label: 'Live', tone: BadgeTone.err, pulse: true),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: LinkCard(
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: Container(
                    width: 230,
                    height: 450,
                    decoration: BoxDecoration(
                      color: LinkColors.dark,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: const Color(0xFF3A322C), width: 6),
                    ),
                    child: Column(
                      children: [
                        Container(
                          margin: const EdgeInsets.all(10),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: LinkColors.err,
                            borderRadius: BorderRadius.circular(LinkRadii.pill),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const PulseDot(color: Colors.white, size: 6),
                              const SizedBox(width: 6),
                              Text('LIVE', style: LinkText.pill.copyWith(color: Colors.white)),
                            ],
                          ),
                        ),
                        const Spacer(),
                        Text(
                          c.phoneName,
                          style: LinkText.body.copyWith(color: Colors.white70, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Elapsed ${c.screenShareElapsed}',
                          style: LinkText.small.copyWith(color: Colors.white38),
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: StatCard(label: 'Latency', value: '${c.latencyMs} ms', icon: Icons.timer_outlined),
                      ),
                      const SizedBox(width: 10),
                      Expanded(child: StatCard(label: 'FPS', value: '${c.fps} fps', icon: Icons.speed_rounded)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          label: 'Resolution',
                          value: c.resolution,
                          icon: Icons.aspect_ratio_rounded,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: StatCard(
                          label: 'Bitrate',
                          value: '8.4 Mbps',
                          valueColor: LinkColors.ok,
                          icon: Icons.network_check_rounded,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  LinkCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionLabel('Quality'),
                        const SizedBox(height: 10),
                        LinkTabs(
                          labels: _qualities,
                          index: _qualities.indexOf(c.screenQuality).clamp(0, 2),
                          onChanged: (i) => c.setScreenQuality(_qualities[i]),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Shared from the phone — you can stop it from either device.',
                          style: LinkText.small,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: PillButton(
                          label: 'Fullscreen',
                          tone: PillTone.white,
                          expand: true,
                          dense: true,
                          icon: Icons.fullscreen_rounded,
                          onPressed: () => showLinkToast(context, 'Fullscreen view on this computer'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: PillButton(
                          label: 'Screenshot',
                          tone: PillTone.white,
                          expand: true,
                          dense: true,
                          icon: Icons.photo_camera_rounded,
                          onPressed: () => showLinkToast(context, 'Screenshot saved locally'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  PillButton(
                    label: 'Stop',
                    tone: PillTone.danger,
                    expand: true,
                    icon: Icons.stop_rounded,
                    onPressed: c.stopScreenShare,
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () {
                      c.interruptScreenShare();
                      showLinkToast(context, 'Simulating a Wi-Fi hiccup');
                    },
                    child: Text(
                      'Simulate connection loss',
                      style: LinkText.pill.copyWith(color: LinkColors.accent),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}


class _Interrupted extends StatelessWidget {
  const _Interrupted({required this.controller});

  final LinkController controller;

  @override
  Widget build(BuildContext context) {
    final c = controller;
    return DesktopScreen(
      title: 'Screen',
      subtitle: 'Live view of ${c.phoneName}',
      trailing: const StatusBadge(label: 'Reconnecting', tone: BadgeTone.warn, pulse: true),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: LinkCard(
              color: LinkColors.warnSoft,
              borderColor: LinkColors.warnSoft,
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const IconTile(
                    icon: Icons.wifi_tethering_error_rounded,
                    size: 62,
                    background: Colors.white,
                    color: LinkColors.warn,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Screen share interrupted — Reconnecting…',
                    style: LinkText.h3,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'The local connection dropped briefly. Link keeps everything on your Wi-Fi while it retries.',
                    textAlign: TextAlign.center,
                    style: LinkText.small,
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: PillButton(
                          label: 'Reconnect now',
                          expand: true,
                          icon: Icons.refresh_rounded,
                          onPressed: () {
                            c.confirmScreenShare();
                            showLinkToast(context, 'Screen share restored');
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: PillButton(
                          label: 'Stop',
                          tone: PillTone.white,
                          expand: true,
                          icon: Icons.stop_rounded,
                          onPressed: c.stopScreenShare,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
