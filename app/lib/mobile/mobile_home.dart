import 'package:flutter/material.dart';

import '../state/link_controller.dart';
import '../theme.dart';
import '../widgets/link_widgets.dart';
import 'mobile_shell.dart';

class MobileHomeScreen extends StatefulWidget {
  const MobileHomeScreen({super.key, required this.controller, required this.go, required this.back});

  final LinkController controller;
  final ValueChanged<MobileRoute> go;
  final VoidCallback back;

  @override
  State<MobileHomeScreen> createState() => _MobileHomeScreenState();
}

class _MobileHomeScreenState extends State<MobileHomeScreen> {
  final TextEditingController _ip = TextEditingController();

  @override
  void dispose() {
    _ip.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    if (c.status == LinkStatus.connecting) {
      return MobileConnectingScreen(controller: c, go: widget.go, back: widget.back);
    }
    if (c.status == LinkStatus.error) {
      return MobileErrorScreen(controller: c, go: widget.go, back: widget.back);
    }

    return MobileScreen(
      children: [
        Row(
          children: [
            const LinkLogo(size: 40),
            const Spacer(),
            const StatusBadge(label: 'Offline first', tone: BadgeTone.accent),
          ],
        ),
        const SizedBox(height: 26),
        const IconTile(icon: Icons.wifi_tethering_rounded, size: 56),
        const SizedBox(height: 16),
        Text('Connect to your PC', style: LinkText.h1),
        const SizedBox(height: 8),
        Text(
          'Open Link on your computer and scan the QR code to easily link devices over local Wi-Fi.',
          style: LinkText.body.copyWith(color: LinkColors.muted),
        ),
        const SizedBox(height: 22),
        PillButton(
          label: 'Scan QR Code',
          icon: Icons.qr_code_scanner_rounded,
          expand: true,
          onPressed: () => widget.go(MobileRoute.qrScanner),
        ),
        const SizedBox(height: 22),
        Row(
          children: [
            const Expanded(child: Divider(color: LinkColors.border)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text('OR ENTER IP MANUALLY', style: LinkText.label),
            ),
            const Expanded(child: Divider(color: LinkColors.border)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _ip,
                keyboardType: TextInputType.number,
                style: LinkText.body,
                decoration: const InputDecoration(hintText: '192.168.1.42'),
              ),
            ),
            const SizedBox(width: 10),
            PillButton(
              label: 'Connect',
              tone: PillTone.dark,
              onPressed: () {
                c.connectWithIp(_ip.text);
                widget.go(MobileRoute.connecting);
              },
            ),
          ],
        ),
        const SizedBox(height: 18),
        LinkCard(
          color: LinkColors.warnSoft,
          borderColor: LinkColors.warnSoft,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2.2)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Looking for PC on network…',
                  style: LinkText.body.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Center(
          child: Text('No internet required. Paired locally.', style: LinkText.small),
        ),
      ],
    );
  }
}


/// Dark QR scanner screen with animated scan line (camera is simulated).
class MobileQrScannerScreen extends StatefulWidget {
  const MobileQrScannerScreen({super.key, required this.controller, required this.go, required this.back});

  final LinkController controller;
  final ValueChanged<MobileRoute> go;
  final VoidCallback back;

  @override
  State<MobileQrScannerScreen> createState() => _MobileQrScannerScreenState();
}

class _MobileQrScannerScreenState extends State<MobileQrScannerScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scan = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2200),
  )..repeat();

  @override
  void dispose() {
    _scan.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: LinkColors.dark,
      padding: const EdgeInsets.fromLTRB(18, 6, 18, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: widget.back,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.arrow_back_ios_new_rounded, size: 14, color: LinkColors.accent),
                const SizedBox(width: 6),
                Text('Back', style: LinkText.pill.copyWith(color: LinkColors.accent)),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const Text('Pair Device',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white)),
          const SizedBox(height: 6),
          const Text('Scan Desktop QR', style: TextStyle(fontSize: 13.5, color: Color(0xFF9E948A))),
          const SizedBox(height: 26),
          Center(
            child: SizedBox(
              width: 250,
              height: 250,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: LinkColors.accent, width: 3),
                        borderRadius: BorderRadius.circular(LinkRadii.xl),
                        color: const Color(0xFF242424),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.qr_code_2_rounded,
                          size: 120,
                          color: Colors.white.withValues(alpha: 0.16),
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(LinkRadii.xl),
                      child: AnimatedBuilder(
                        animation: _scan,
                        builder: (context, _) => Align(
                          alignment: Alignment(0, -1 + 2 * _scan.value),
                          child: Container(
                            height: 2.5,
                            margin: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: const BoxDecoration(
                              color: LinkColors.accent,
                              boxShadow: [BoxShadow(color: LinkColors.accent, blurRadius: 14)],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 22),
          Center(
            child: Text(
              'PAIRING VIA WI-FI DIRECT',
              style: LinkText.label.copyWith(color: const Color(0xFF9E948A)),
            ),
          ),
          const Spacer(),
          PillButton(
            label: 'Use IP Address',
            tone: PillTone.white,
            expand: true,
            icon: Icons.keyboard_rounded,
            onPressed: () {
              widget.controller.scanQrCode();
              widget.go(MobileRoute.connecting);
            },
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              'The camera detects the desktop code automatically.',
              style: LinkText.small.copyWith(color: const Color(0xFF9E948A)),
            ),
          ),
        ],
      ),
    );
  }
}

class MobileConnectingScreen extends StatelessWidget {
  const MobileConnectingScreen({super.key, required this.controller, required this.go, required this.back});

  final LinkController controller;
  final ValueChanged<MobileRoute> go;
  final VoidCallback back;

  @override
  Widget build(BuildContext context) {
    final c = controller;
    return MobileScreen(
      scroll: false,
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
      children: [
        const Spacer(),
        Center(child: const LinkSpinner(size: 68)),
        const SizedBox(height: 22),
        Center(child: Text('Connecting to ${c.pcName}…', style: LinkText.h2)),
        const SizedBox(height: 8),
        Center(child: Text('IP Address: ${c.localIp}', style: LinkText.small)),
        const SizedBox(height: 4),
        Center(
          child: Text(
            'Ensure both devices are on the same Wi-Fi network.',
            textAlign: TextAlign.center,
            style: LinkText.small,
          ),
        ),
        const SizedBox(height: 22),
        LinkCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionLabel('Local handshake'),
              const SizedBox(height: 10),
              _CheckRow(label: 'Device discovered on LAN', done: true),
              _CheckRow(label: 'Wi-Fi Direct channel open', done: true),
              _CheckRow(label: 'Encrypted local session', done: c.status == LinkStatus.connected),
            ],
          ),
        ),
        const Spacer(),
        PillButton(
          label: 'Cancel Connection',
          tone: PillTone.white,
          expand: true,
          onPressed: () {
            c.cancel();
            back();
          },
        ),
      ],
    );
  }
}

class _CheckRow extends StatelessWidget {
  const _CheckRow({required this.label, required this.done});

  final String label;
  final bool done;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(
            done ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
            size: 17,
            color: done ? LinkColors.ok : LinkColors.faint,
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(label, style: LinkText.body)),
        ],
      ),
    );
  }
}

class MobileErrorScreen extends StatelessWidget {
  const MobileErrorScreen({super.key, required this.controller, required this.go, required this.back});

  final LinkController controller;
  final ValueChanged<MobileRoute> go;
  final VoidCallback back;

  @override
  Widget build(BuildContext context) {
    return MobileScreen(
      scroll: false,
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
      children: [
        const Spacer(),
        const Center(
          child: IconTile(
            icon: Icons.error_outline_rounded,
            size: 74,
            background: LinkColors.errSoft,
            color: LinkColors.err,
          ),
        ),
        const SizedBox(height: 20),
        Center(child: Text('Connection Failed', style: LinkText.h2)),
        const SizedBox(height: 8),
        Center(
          child: Text(
            'We could not reach ${controller.pcName} on your local network. '
            'Check that Link is open on your computer and both devices share the same Wi-Fi.',
            textAlign: TextAlign.center,
            style: LinkText.small,
          ),
        ),
        const SizedBox(height: 12),
        Center(child: Text('Error code: LINK-1042', style: LinkText.small.copyWith(color: LinkColors.err))),
        const Spacer(),
        PillButton(
          label: 'Retry Connection',
          expand: true,
          onPressed: () {
            controller.retry();
            go(MobileRoute.connecting);
          },
        ),
        const SizedBox(height: 12),
        Center(
          child: GestureDetector(
            onTap: () => go(MobileRoute.qrScanner),
            child: Text('Scan QR Code Instead', style: LinkText.pill.copyWith(color: LinkColors.accent)),
          ),
        ),
      ],
    );
  }
}



class MobileDashboardScreen extends StatelessWidget {
  const MobileDashboardScreen({super.key, required this.controller, required this.go, required this.back});

  final LinkController controller;
  final ValueChanged<MobileRoute> go;
  final VoidCallback back;

  @override
  Widget build(BuildContext context) {
    final c = controller;
    final tiles = <Widget>[
      _DashTile(
        icon: Icons.upload_file_rounded,
        title: 'Send Files',
        subtitle: '${c.queuedCount} in queue',
        onTap: () => go(MobileRoute.sendFiles),
      ),
      _DashTile(
        icon: Icons.content_paste_rounded,
        title: 'Clipboard',
        badge: c.clipboardSync ? 'ACTIVE' : 'PAUSED',
        badgeTone: c.clipboardSync ? BadgeTone.ok : BadgeTone.muted,
        onTap: () => go(MobileRoute.clipboard),
      ),
      _DashTile(
        icon: Icons.keyboard_rounded,
        title: 'Keyboard',
        subtitle: 'Remote input',
        onTap: () => go(MobileRoute.keyboard),
      ),
      _DashTile(
        icon: Icons.touch_app_rounded,
        title: 'Touchpad',
        subtitle: 'Move the cursor',
        onTap: () => go(MobileRoute.touchpad),
      ),
      _DashTile(
        icon: Icons.notifications_active_rounded,
        title: 'Ring Phone',
        subtitle: c.ringing ? 'Ringing now' : 'Find your device',
        onTap: () => go(MobileRoute.ring),
      ),
      _DashTile(
        icon: Icons.lan_rounded,
        title: 'Connection',
        subtitle: '${c.localIp} • Wi-Fi',
        onTap: () => go(MobileRoute.devices),
      ),
      _DashTile(
        icon: Icons.screen_share_rounded,
        title: 'Screen Share',
        badge: c.screenSharing ? 'LIVE' : 'NEW',
        badgeTone: c.screenSharing ? BadgeTone.err : BadgeTone.accent,
        onTap: () => go(MobileRoute.screenShare),
      ),
      _DashTile(
        icon: Icons.devices_rounded,
        title: 'Devices',
        subtitle: '${c.devices.length} connected',
        onTap: () => go(MobileRoute.devices),
      ),
    ];

    return MobileScreen(
      children: [
        Row(
          children: [
            const LinkLogo(size: 38, showWord: false),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(c.pcName, style: LinkText.h3),
                  const SizedBox(height: 4),
                  const StatusBadge(label: 'Connected Seamlessly', tone: BadgeTone.ok),
                ],
              ),
            ),
            PillButton(
              label: 'Stop',
              tone: PillTone.danger,
              dense: true,
              onPressed: () {
                c.disconnect();
                go(MobileRoute.home);
              },
            ),
          ],
        ),
        const SizedBox(height: 18),
        LinkCard(
          color: LinkColors.okSoft,
          borderColor: LinkColors.okSoft,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              const Icon(Icons.wifi_rounded, size: 18, color: LinkColors.ok),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Paired locally over Wi-Fi Direct. No internet used.',
                  style: LinkText.body.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Wrap(spacing: 12, runSpacing: 12, children: tiles),
        const SizedBox(height: 18),
        LinkCard(
          child: Row(
            children: [
              const IconTile(icon: Icons.speed_rounded, size: 38),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Direct Local Speed', style: LinkText.body.copyWith(fontWeight: FontWeight.w700)),
                    Text(
                      '${c.localSpeedMbps.toStringAsFixed(0)} Mbps • ${c.sessionTime} session',
                      style: LinkText.small,
                    ),
                  ],
                ),
              ),
              const StatusBadge(label: 'Local', tone: BadgeTone.ok),
            ],
          ),
        ),
      ],
    );
  }
}

class _DashTile extends StatelessWidget {
  const _DashTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.badge,
    this.badgeTone = BadgeTone.accent,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final String? badge;
  final BadgeTone badgeTone;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 171,
      child: LinkCard(
        onTap: onTap,
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconTile(icon: icon, size: 36),
                const Spacer(),
                if (badge != null) StatusBadge(label: badge!, tone: badgeTone, dot: false),
              ],
            ),
            const SizedBox(height: 12),
            Text(title, style: LinkText.body.copyWith(fontWeight: FontWeight.w700)),
            if (subtitle != null)
              Text(subtitle!, style: LinkText.small, maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}
