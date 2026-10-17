import 'package:flutter/material.dart';

import '../state/link_controller.dart';
import '../theme.dart';
import '../widgets/link_widgets.dart';
import 'mobile_shell.dart';

/// Tools hub — entry point of the Tools tab.
class MobileToolsScreen extends StatelessWidget {
  const MobileToolsScreen({super.key, required this.controller, required this.go, required this.back});

  final LinkController controller;
  final ValueChanged<MobileRoute> go;
  final VoidCallback back;

  @override
  Widget build(BuildContext context) {
    final c = controller;
    final entries = <_ToolEntry>[
      _ToolEntry(Icons.content_paste_rounded, 'Clipboard', 'Shared text, synced locally', MobileRoute.clipboard),
      _ToolEntry(Icons.keyboard_rounded, 'Remote Keyboard', 'Type on your computer', MobileRoute.keyboard),
      _ToolEntry(Icons.touch_app_rounded, 'Mouse & Trackpad', 'Move the cursor, click, scroll', MobileRoute.touchpad),
      _ToolEntry(Icons.notifications_active_rounded, 'Ring Phone', 'Loud alert even in silent mode', MobileRoute.ring),
      _ToolEntry(Icons.screen_share_rounded, 'Screen Share', 'Mirror your screen to the PC', MobileRoute.screenShare),
      _ToolEntry(Icons.devices_rounded, 'Connected Devices', '${c.devices.length} active • session stats', MobileRoute.devices),
    ];

    return MobileScreen(
      title: 'Tools',
      subtitle: 'Everything below runs on your local network only.',
      trailing: const StatusBadge(label: 'Local', tone: BadgeTone.ok),
      children: [
        for (final e in entries) ...[
          LinkCard(
            onTap: () => go(e.route),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                IconTile(icon: e.icon, size: 38),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(e.title, style: LinkText.body.copyWith(fontWeight: FontWeight.w700)),
                      Text(e.subtitle, style: LinkText.small),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, size: 20, color: LinkColors.faint),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
        const SizedBox(height: 6),
        Center(child: Text('No internet required. Paired locally.', style: LinkText.small)),
      ],
    );
  }
}

class _ToolEntry {
  const _ToolEntry(this.icon, this.title, this.subtitle, this.route);

  final IconData icon;
  final String title;
  final String subtitle;
  final MobileRoute route;
}

class MobileClipboardScreen extends StatelessWidget {
  const MobileClipboardScreen({super.key, required this.controller, required this.go, required this.back});

  final LinkController controller;
  final ValueChanged<MobileRoute> go;
  final VoidCallback back;

  @override
  Widget build(BuildContext context) {
    final c = controller;
    final entries = c.clipboard.where((e) => e.source == c.clipboardTab).toList();

    return MobileScreen(
      title: 'Clipboard Sync',
      subtitle: 'Text copied on either device is available instantly.',
      trailing: StatusBadge(
        label: c.clipboardSync ? 'Synced locally' : 'Paused',
        tone: c.clipboardSync ? BadgeTone.ok : BadgeTone.muted,
      ),
      children: [
        LinkCard(
          child: LinkSwitchRow(
            icon: Icons.sync_rounded,
            label: 'Clipboard Sync',
            subtitle: 'Kept on your two devices only',
            value: c.clipboardSync,
            onChanged: c.toggleClipboardSync,
          ),
        ),
        const SizedBox(height: 14),
        LinkTabs(
          labels: const ['Phone Clipboard', 'PC Clipboard'],
          index: c.clipboardTab == ClipboardSource.phone ? 0 : 1,
          onChanged: (i) => c.setClipboardTab(i == 0 ? ClipboardSource.phone : ClipboardSource.pc),
        ),
        const SizedBox(height: 14),
        for (final e in entries) ...[
          LinkCard(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(e.time, style: LinkText.pill.copyWith(color: LinkColors.muted)),
                    const SizedBox(width: 8),
                    StatusBadge(
                      label: e.source == ClipboardSource.pc ? 'From PC' : 'From Phone',
                      tone: e.source == ClipboardSource.pc ? BadgeTone.accent : BadgeTone.muted,
                      dot: false,
                    ),
                    const Spacer(),
                    const Icon(Icons.lock_outline_rounded, size: 14, color: LinkColors.faint),
                  ],
                ),
                const SizedBox(height: 10),
                Text(e.text, style: LinkText.body),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: PillButton(
                        label: 'Paste on Phone',
                        tone: PillTone.white,
                        dense: true,
                        expand: true,
                        onPressed: () {
                          c.pasteOnPhone(e);
                          showLinkToast(context, 'Pasted on phone');
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: PillButton(
                        label: 'Send to PC',
                        dense: true,
                        expand: true,
                        onPressed: () {
                          c.sendToPc(e);
                          showLinkToast(context, 'Sent to your computer');
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
        if (entries.isEmpty) Text('No clipboard items for this device yet.', style: LinkText.small),
      ],
    );
  }
}



class MobileKeyboardScreen extends StatefulWidget {
  const MobileKeyboardScreen({super.key, required this.controller, required this.go, required this.back});

  final LinkController controller;
  final ValueChanged<MobileRoute> go;
  final VoidCallback back;

  @override
  State<MobileKeyboardScreen> createState() => _MobileKeyboardScreenState();
}

class _MobileKeyboardScreenState extends State<MobileKeyboardScreen> {
  final TextEditingController _text = TextEditingController();

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    final typed = c.keyboardText.characters.toList();

    return MobileScreen(
      showBack: true,
      onBack: widget.back,
      title: 'Remote Input',
      subtitle: 'Your phone is the keyboard of ${c.pcName}.',
      children: [
        Container(
          decoration: BoxDecoration(
            color: LinkColors.accentSoft,
            borderRadius: BorderRadius.circular(LinkRadii.lg),
            border: Border.all(color: LinkColors.accent, width: 1.4),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: TextField(
            controller: _text,
            maxLines: 3,
            onChanged: c.setKeyboardText,
            style: LinkText.body.copyWith(fontSize: 16, fontWeight: FontWeight.w600),
            decoration: const InputDecoration(
              hintText: 'Start typing here...',
              filled: false,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Every character typed in this field will instantly appear on your connected computer.',
          style: LinkText.small,
        ),
        const SizedBox(height: 16),
        LinkCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionLabel('Live keycaps'),
              const SizedBox(height: 10),
              if (typed.isEmpty)
                Text('Nothing typed yet.', style: LinkText.small)
              else
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final ch in typed.take(24))
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(LinkRadii.sm),
                          border: Border.all(color: LinkColors.border),
                        ),
                        child: Text(
                          ch == ' ' ? '␣' : ch,
                          style: LinkText.body.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                  ],
                ),
              const SizedBox(height: 12),
              Row(
                children: [
                  StatusBadge(
                    label: c.keyboardActive ? 'Typing active' : 'Idle',
                    tone: c.keyboardActive ? BadgeTone.ok : BadgeTone.muted,
                  ),
                  const Spacer(),
                  Text('${typed.length} characters', style: LinkText.small),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        LinkCard(
          child: LinkSwitchRow(
            icon: Icons.keyboard_alt_rounded,
            label: 'Show on-screen keyboard',
            value: c.showOnScreenKeyboard,
            onChanged: c.setShowOnScreenKeyboard,
          ),
        ),
        const SizedBox(height: 14),
        PillButton(
          label: 'Activate Typing',
          expand: true,
          icon: Icons.play_arrow_rounded,
          onPressed: () {
            c.activateTyping();
            showLinkToast(context, 'Typing receiver armed on ${c.pcName}');
          },
        ),
        const SizedBox(height: 10),
        PillButton(
          label: 'Clear Text',
          tone: PillTone.white,
          expand: true,
          icon: Icons.backspace_rounded,
          onPressed: () {
            _text.clear();
            c.clearText();
          },
        ),
      ],
    );
  }
}


class MobileTouchpadScreen extends StatelessWidget {
  const MobileTouchpadScreen({super.key, required this.controller, required this.go, required this.back});

  final LinkController controller;
  final ValueChanged<MobileRoute> go;
  final VoidCallback back;

  @override
  Widget build(BuildContext context) {
    final c = controller;
    return MobileScreen(
      scroll: false,
      showBack: true,
      onBack: back,
      title: 'Mouse & Trackpad',
      subtitle: 'Control ${c.pcName} with gestures.',
      children: [
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) => GestureDetector(
              behavior: HitTestBehavior.opaque,
              onPanUpdate: (d) => c.moveTouchpad(
                d.delta.dx / constraints.maxWidth,
                d.delta.dy / constraints.maxHeight,
              ),
              onTap: () => c.click(right: false),
              onLongPress: () => c.click(right: true),
              onDoubleTap: () => c.scroll(1),
              child: Container(
                decoration: BoxDecoration(
                  color: LinkColors.card,
                  borderRadius: BorderRadius.circular(LinkRadii.xl),
                  border: Border.all(color: LinkColors.border),
                  boxShadow: kSoftShadow,
                ),
                child: Stack(
                  children: [
                    Positioned.fill(child: CustomPaint(painter: _TrackpadGridPainter())),
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 120),
                      left: 14 + c.touchpadPosition.x * (constraints.maxWidth - 46),
                      top: 14 + c.touchpadPosition.y * (constraints.maxHeight - 46),
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: const BoxDecoration(
                          color: LinkColors.accent,
                          shape: BoxShape.circle,
                          boxShadow: kAccentShadow,
                        ),
                      ),
                    ),
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.touch_app_rounded, size: 34, color: LinkColors.faint),
                          const SizedBox(height: 10),
                          Text(
                            'Swipe to move cursor\nTwo fingers to scroll • Tap to click',
                            textAlign: TextAlign.center,
                            style: LinkText.small,
                          ),
                        ],
                      ),
                    ),
                    const Positioned(
                      top: 12,
                      right: 12,
                      child: StatusBadge(label: 'Latency < 2ms', tone: BadgeTone.ok, dot: false),
                    ),
                    Positioned(
                      bottom: 12,
                      left: 14,
                      child: Text('${c.clickCount} clicks • ${c.scrollCount} scrolls', style: LinkText.small),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: PillButton(
                label: 'Left Click',
                expand: true,
                icon: Icons.mouse_rounded,
                onPressed: () {
                  c.click(right: false);
                  showLinkToast(context, 'Left click sent');
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: PillButton(
                label: 'Right Click',
                tone: PillTone.white,
                expand: true,
                icon: Icons.more_horiz_rounded,
                onPressed: () {
                  c.click(right: true);
                  showLinkToast(context, 'Right click sent');
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        LinkCard(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: LinkSwitchRow(
            icon: Icons.drag_indicator_rounded,
            label: 'Drag Lock',
            subtitle: 'Keep the button pressed while moving',
            value: c.dragLock,
            onChanged: c.setDragLock,
          ),
        ),
      ],
    );
  }
}

class _TrackpadGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x142A2420)
      ..strokeWidth = 1;
    for (var x = 1; x < 4; x++) {
      final dx = size.width * x / 4;
      canvas.drawLine(Offset(dx, 0), Offset(dx, size.height), paint);
    }
    for (var y = 1; y < 4; y++) {
      final dy = size.height * y / 4;
      canvas.drawLine(Offset(0, dy), Offset(size.width, dy), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


class MobileRingScreen extends StatelessWidget {
  const MobileRingScreen({super.key, required this.controller, required this.go, required this.back});

  final LinkController controller;
  final ValueChanged<MobileRoute> go;
  final VoidCallback back;

  @override
  Widget build(BuildContext context) {
    final c = controller;
    return MobileScreen(
      showBack: true,
      onBack: back,
      title: 'Find My Device',
      subtitle: 'Ring your phone at full volume from the computer.',
      children: [
        Center(
          child: SizedBox(
            width: 190,
            height: 190,
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (c.ringing)
                  for (var i = 0; i < 3; i++)
                    _RingWave(delay: i * 0.45, color: LinkColors.accent.withValues(alpha: 0.5)),
                Container(
                  width: 96,
                  height: 96,
                  decoration: const BoxDecoration(
                    color: LinkColors.accentSoft,
                    shape: BoxShape.circle,
                    boxShadow: kAccentShadow,
                  ),
                  child: const Icon(Icons.notifications_active_rounded, size: 42, color: LinkColors.accent),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        Center(
          child: Text(c.ringing ? 'Ringing Connected PC' : 'Ready to ring', style: LinkText.h3),
        ),
        const SizedBox(height: 6),
        Center(
          child: Text(
            c.ringing
                ? 'Playing a loud alert sound on ${c.pcName}'
                : '${c.pcName} can trigger a loud ringtone even in silent mode.',
            textAlign: TextAlign.center,
            style: LinkText.small,
          ),
        ),
        const SizedBox(height: 22),
        LinkCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionLabel('Volume'),
              Slider(value: c.ringVolume, onChanged: c.setRingVolume),
              Row(
                children: [
                  const Icon(Icons.volume_up_rounded, size: 16, color: LinkColors.accent),
                  const SizedBox(width: 6),
                  Text('${(c.ringVolume * 100).round()}% of device volume', style: LinkText.small),
                  const Spacer(),
                  const StatusBadge(label: 'Full volume', tone: BadgeTone.warn),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (c.ringing)
          PillButton(
            label: 'Stop Alert',
            tone: PillTone.danger,
            expand: true,
            icon: Icons.stop_rounded,
            onPressed: () {
              c.stopRinging();
              showLinkToast(context, 'Alert stopped');
            },
          )
        else
          PillButton(
            label: 'Ring Phone',
            expand: true,
            icon: Icons.notifications_active_rounded,
            onPressed: () {
              c.startRinging();
              showLinkToast(context, 'Ringing ${c.phoneName} over the local network');
            },
          ),
        const SizedBox(height: 14),
        Center(child: Text('Works even in silent mode or Do Not Disturb.', style: LinkText.small)),
      ],
    );
  }
}

class _RingWave extends StatefulWidget {
  const _RingWave({required this.delay, required this.color});

  final double delay;
  final Color color;

  @override
  State<_RingWave> createState() => _RingWaveState();
}

class _RingWaveState extends State<_RingWave> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  );

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(Duration(milliseconds: (widget.delay * 1000).round()), () {
      if (mounted) _controller.repeat();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final v = _controller.value;
        return Container(
          width: 96 + 90 * v,
          height: 96 + 90 * v,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: widget.color.withValues(alpha: 0.55 * (1 - v)), width: 2),
          ),
        );
      },
    );
  }
}

class MobileDevicesScreen extends StatelessWidget {
  const MobileDevicesScreen({super.key, required this.controller, required this.go, required this.back});

  final LinkController controller;
  final ValueChanged<MobileRoute> go;
  final VoidCallback back;

  @override
  Widget build(BuildContext context) {
    final c = controller;
    return MobileScreen(
      showBack: true,
      onBack: back,
      title: 'Connected Devices',
      subtitle: 'Only devices on your local Wi-Fi can appear here.',
      trailing: const StatusBadge(label: 'Local', tone: BadgeTone.ok),
      children: [
        for (final d in c.devices) ...[
          LinkCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const IconTile(icon: Icons.computer_rounded, size: 40),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(d.name, style: LinkText.body.copyWith(fontWeight: FontWeight.w700)),
                          Text('${d.ip} • Wi-Fi', style: LinkText.small),
                        ],
                      ),
                    ),
                    const StatusBadge(label: 'Active', tone: BadgeTone.ok),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(child: StatCard(label: 'Session', value: d.session)),
                    const SizedBox(width: 10),
                    Expanded(child: StatCard(label: 'Transferred', value: d.transferred)),
                    const SizedBox(width: 10),
                    Expanded(child: StatCard(label: 'Speed', value: d.speed, valueColor: LinkColors.ok)),
                  ],
                ),
                const SizedBox(height: 12),
                PillButton(
                  label: 'Disconnect Device',
                  tone: PillTone.danger,
                  expand: true,
                  icon: Icons.link_off_rounded,
                  onPressed: () {
                    c.disconnectDevice(d.name);
                    showLinkToast(context, '${d.name} disconnected from this session');
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
        if (c.devices.isEmpty)
          LinkCard(
            child: Text(
              'No phone connected right now. Scan the QR code again to pair.',
              style: LinkText.small,
            ),
          ),
        const SizedBox(height: 8),
        const SectionLabel('Connection History'),
        const SizedBox(height: 10),
        for (final h in c.history) ...[
          LinkCard(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                const IconTile(
                  icon: Icons.smartphone_rounded,
                  size: 36,
                  background: Color(0xFFEDE5D9),
                  color: LinkColors.muted,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(h.name, style: LinkText.body.copyWith(fontWeight: FontWeight.w600)),
                      Text('${h.ip} • ${h.transferred} transferred', style: LinkText.small),
                    ],
                  ),
                ),
                PillButton(
                  label: 'Connect',
                  dense: true,
                  onPressed: () {
                    c.connectHistoryDevice(h);
                    showLinkToast(context, '${h.name} added to this local session');
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}



class MobileScreenShareScreen extends StatelessWidget {
  const MobileScreenShareScreen({super.key, required this.controller, required this.go, required this.back});

  final LinkController controller;
  final ValueChanged<MobileRoute> go;
  final VoidCallback back;

  static const _qualities = ['Low', 'Balanced', 'High'];

  @override
  Widget build(BuildContext context) {
    final c = controller;
    return MobileScreen(
      showBack: true,
      onBack: back,
      title: 'Screen Share',
      subtitle: 'Mirror your phone screen to ${c.pcName}',
      trailing: c.screenSharing
          ? const StatusBadge(label: 'Live', tone: BadgeTone.err, pulse: true)
          : const StatusBadge(label: 'Local only', tone: BadgeTone.ok),
      children: [
        if (c.captureDialogVisible)
          _CapturePermissionCard(controller: c)
        else if (!c.screenSharing)
          LinkCard(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 26),
            child: Column(
              children: [
                const IconTile(icon: Icons.screen_share_rounded, size: 72),
                const SizedBox(height: 16),
                Text('Share this screen', style: LinkText.h3),
                const SizedBox(height: 6),
                Text(
                  'Your screen will be visible only on your local network. Nothing leaves your Wi-Fi.',
                  textAlign: TextAlign.center,
                  style: LinkText.small,
                ),
                const SizedBox(height: 18),
                PillButton(
                  label: 'Start Sharing',
                  expand: true,
                  icon: Icons.play_arrow_rounded,
                  onPressed: c.requestScreenShare,
                ),
                const SizedBox(height: 12),
                Text(
                  'Android will ask for permission to capture your screen.',
                  textAlign: TextAlign.center,
                  style: LinkText.small.copyWith(color: LinkColors.faint),
                ),
              ],
            ),
          )
        else
          Column(
            children: [
              LinkCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Container(
                      height: 190,
                      width: 104,
                      decoration: BoxDecoration(
                        color: LinkColors.dark,
                        borderRadius: BorderRadius.circular(LinkRadii.lg),
                        border: Border.all(color: LinkColors.accent, width: 2),
                      ),
                      child: Center(
                        child: Text(
                          'Sharing screen',
                          style: LinkText.small.copyWith(color: Colors.white70),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text('Sharing to ${c.pcName}', style: LinkText.h3),
                    const SizedBox(height: 4),
                    Text(
                      'Elapsed ${c.screenShareElapsed} • Latency ${c.latencyMs} ms',
                      style: LinkText.small,
                    ),
                  ],
                ),
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
                    Row(
                      children: [
                        const Icon(Icons.lock_outline_rounded, size: 14, color: LinkColors.faint),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Link is sharing your screen — persistent notification active.',
                            style: LinkText.small,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              PillButton(
                label: 'Stop Sharing',
                tone: PillTone.danger,
                expand: true,
                icon: Icons.stop_rounded,
                onPressed: () {
                  c.stopScreenShare();
                  showLinkToast(context, 'Screen sharing stopped');
                },
              ),
            ],
          ),
      ],
    );
  }
}

/// Simulated Android system dialog: “Start recording or casting with Link?”
class _CapturePermissionCard extends StatelessWidget {
  const _CapturePermissionCard({required this.controller});

  final LinkController controller;

  @override
  Widget build(BuildContext context) {
    return LinkCard(
      color: const Color(0xFF262220),
      borderColor: const Color(0xFF262220),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.screen_share_rounded, size: 18, color: Colors.white),
              const SizedBox(width: 8),
              Text('Link', style: LinkText.body.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Start recording or casting with Link?',
            style: LinkText.body.copyWith(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15),
          ),
          const SizedBox(height: 6),
          Text(
            'Link will capture everything on your screen. This stays on your local Wi-Fi network.',
            style: LinkText.small.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: controller.cancelScreenShare,
                child: Text('Cancel', style: LinkText.pill.copyWith(color: Colors.white70)),
              ),
              const SizedBox(width: 20),
              GestureDetector(
                onTap: () {
                  controller.confirmScreenShare();
                  showLinkToast(context, 'Screen sharing started on the local network');
                },
                child: Text('Start now', style: LinkText.pill.copyWith(color: LinkColors.accent)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
