import 'package:flutter/material.dart';

import '../state/link_controller.dart';
import '../theme.dart';
import '../widgets/link_widgets.dart';
import 'desktop_shell.dart';

class DesktopOverviewScreen extends StatelessWidget {
  const DesktopOverviewScreen({super.key, required this.controller, required this.go});

  final LinkController controller;
  final ValueChanged<DesktopSection> go;

  @override
  Widget build(BuildContext context) {
    switch (controller.status) {
      case LinkStatus.disconnected:
        return _ReadyToConnect(controller: controller);
      case LinkStatus.connecting:
        return _Connecting(controller: controller);
      case LinkStatus.error:
        return _ConnectionFailed(controller: controller);
      case LinkStatus.connected:
        return _Connected(controller: controller, go: go);
    }
  }
}

class _ReadyToConnect extends StatelessWidget {
  const _ReadyToConnect({required this.controller});

  final LinkController controller;

  @override
  Widget build(BuildContext context) {
    return DesktopScreen(
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              children: [
                const IconTile(icon: Icons.link_rounded, size: 58),
                const SizedBox(height: 16),
                Text('Connect your phone', style: LinkText.h1, textAlign: TextAlign.center),
                const SizedBox(height: 8),
                Text(
                  'Open Link on your Android device and scan the QR code to pair over local Wi-Fi.',
                  textAlign: TextAlign.center,
                  style: LinkText.body.copyWith(color: LinkColors.muted),
                ),
                const SizedBox(height: 22),
                LinkCard(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    children: [
                      const FakeQrCode(size: 210),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const StatusBadge(
                            label: 'Local IP: 192.168.1.42',
                            tone: BadgeTone.muted,
                            dot: false,
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => showLinkToast(context, 'Local IP copied to the clipboard'),
                            child: const Icon(Icons.copy_rounded, size: 15, color: LinkColors.accent),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: controller.connect,
                  child: Text(
                    'Connect with IP Address instead',
                    style: LinkText.pill.copyWith(color: LinkColors.accent),
                  ),
                ),
                const SizedBox(height: 18),
                LinkCard(
                  color: LinkColors.warnSoft,
                  borderColor: LinkColors.warnSoft,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 15,
                        height: 15,
                        child: CircularProgressIndicator(strokeWidth: 2.2),
                      ),
                      const SizedBox(width: 12),
                      Text('Waiting for device…', style: LinkText.body.copyWith(fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'No account, no cloud. The QR code only contains your local address.',
                  textAlign: TextAlign.center,
                  style: LinkText.small,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Deterministic QR-looking placeholder (no network, no dependency).
class FakeQrCode extends StatelessWidget {
  const FakeQrCode({super.key, this.size = 200});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(LinkRadii.md),
        border: Border.all(color: LinkColors.border),
      ),
      padding: const EdgeInsets.all(12),
      child: CustomPaint(painter: _QrPainter()),
    );
  }
}

class _QrPainter extends CustomPainter {
  static const _modules = 21;

  @override
  void paint(Canvas canvas, Size size) {
    final cell = size.width / _modules;
    final paint = Paint()..color = LinkColors.text;

    bool inBox(int x, int y, int ox, int oy) => x >= ox && x < ox + 7 && y >= oy && y < oy + 7;
    bool isFinder(int x, int y) =>
        inBox(x, y, 0, 0) || inBox(x, y, _modules - 7, 0) || inBox(x, y, 0, _modules - 7);

    void drawFinder(int ox, int oy) {
      canvas.drawRect(Rect.fromLTWH(ox * cell, oy * cell, 7 * cell, 7 * cell), paint);
      final inner = Paint()..color = Colors.white;
      canvas.drawRect(Rect.fromLTWH((ox + 1) * cell, (oy + 1) * cell, 5 * cell, 5 * cell), inner);
      canvas.drawRect(Rect.fromLTWH((ox + 2) * cell, (oy + 2) * cell, 3 * cell, 3 * cell), paint);
    }

    drawFinder(0, 0);
    drawFinder(_modules - 7, 0);
    drawFinder(0, _modules - 7);

    // Deterministic pseudo-random data modules.
    var seed = 20260114;
    for (var y = 0; y < _modules; y++) {
      for (var x = 0; x < _modules; x++) {
        if (isFinder(x, y)) continue;
        seed = (seed * 1103515245 + 12345) & 0x7fffffff;
        if (seed % 3 != 0) continue;
        canvas.drawRect(
          Rect.fromLTWH(x * cell + 0.4, y * cell + 0.4, cell - 0.8, cell - 0.8),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _Connecting extends StatelessWidget {
  const _Connecting({required this.controller});

  final LinkController controller;

  @override
  Widget build(BuildContext context) {
    return DesktopScreen(
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Column(
              children: [
                const LinkSpinner(size: 62),
                const SizedBox(height: 20),
                Text('Connecting to ${controller.phoneName}', style: LinkText.h2, textAlign: TextAlign.center),
                const SizedBox(height: 8),
                Text(
                  'Confirming safe pairing sequence over your local Wi-Fi router.',
                  textAlign: TextAlign.center,
                  style: LinkText.small,
                ),
                const SizedBox(height: 20),
                LinkCard(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const LinkSpinner(size: 34),
                      const SizedBox(width: 16),
                      Text('IP: ${controller.localIp}', style: LinkText.body.copyWith(fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                PillButton(
                  label: 'Cancel Connection',
                  tone: PillTone.white,
                  expand: true,
                  onPressed: controller.cancel,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ConnectionFailed extends StatelessWidget {
  const _ConnectionFailed({required this.controller});

  final LinkController controller;

  @override
  Widget build(BuildContext context) {
    return DesktopScreen(
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 470),
            child: Column(
              children: [
                const IconTile(
                  icon: Icons.close_rounded,
                  size: 72,
                  background: LinkColors.errSoft,
                  color: LinkColors.err,
                ),
                const SizedBox(height: 18),
                Text('Connection Failed', style: LinkText.h2),
                const SizedBox(height: 8),
                Text(
                  'The phone did not answer on the local network. Make sure both devices are on the same Wi-Fi '
                  'and that Link is open on the phone.',
                  textAlign: TextAlign.center,
                  style: LinkText.small,
                ),
                const SizedBox(height: 10),
                Text('Error code: LINK-1042', style: LinkText.small.copyWith(color: LinkColors.err)),
                const SizedBox(height: 20),
                PillButton(
                  label: 'Try Again',
                  expand: true,
                  onPressed: controller.retry,
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () => showLinkToast(context, 'Local network looks healthy — router reachable'),
                  child: Text(
                    'Troubleshoot network issues',
                    style: LinkText.pill.copyWith(color: LinkColors.accent),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}



class _Connected extends StatelessWidget {
  const _Connected({required this.controller, required this.go});

  final LinkController controller;
  final ValueChanged<DesktopSection> go;

  @override
  Widget build(BuildContext context) {
    final c = controller;
    return DesktopScreen(
      title: 'Welcome back to ${c.phoneName}',
      subtitle: 'Connected seamlessly over local network. No cellular data is being used.',
      trailing: const StatusBadge(label: 'Wi-Fi Direct', tone: BadgeTone.ok),
      children: [
        LinkCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const SectionLabel('Session'),
                  const Spacer(),
                  const StatusBadge(label: 'Local only', tone: BadgeTone.accent, dot: false),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: StatCard(label: 'Session Time', value: c.sessionTime, icon: Icons.timer_outlined),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      label: 'Local Speed',
                      value: '${c.localSpeedMbps.toStringAsFixed(0)} Mbps',
                      valueColor: LinkColors.ok,
                      icon: Icons.speed_rounded,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      label: 'Transferred',
                      value: c.transferredTotal,
                      icon: Icons.swap_vert_rounded,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        const SectionLabel('Connected phones'),
        const SizedBox(height: 10),
        LinkCard(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          child: Column(
            children: [
              for (final d in c.devices)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  child: Row(
                    children: [
                      const IconTile(icon: Icons.smartphone_rounded, size: 36),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(d.name, style: LinkText.body.copyWith(fontWeight: FontWeight.w700)),
                            Text('${d.ip} • ${d.session} • ${d.speed}', style: LinkText.small),
                          ],
                        ),
                      ),
                      const StatusBadge(label: 'Active', tone: BadgeTone.ok),
                      const SizedBox(width: 10),
                      PillButton(
                        label: 'Disconnect',
                        tone: PillTone.danger,
                        dense: true,
                        onPressed: () => c.disconnectDevice(d.name),
                      ),
                    ],
                  ),
                ),
              if (c.devices.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Text('No phone connected. Show the QR code again to pair.', style: LinkText.small),
                ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: PillButton(
                label: 'Open Files',
                tone: PillTone.white,
                expand: true,
                icon: Icons.folder_rounded,
                onPressed: () => go(DesktopSection.files),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: PillButton(
                label: 'Ring Phone',
                tone: PillTone.white,
                expand: true,
                icon: Icons.notifications_active_rounded,
                onPressed: () => go(DesktopSection.ring),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: PillButton(
                label: 'View Screen',
                tone: PillTone.white,
                expand: true,
                icon: Icons.cast_rounded,
                onPressed: () => go(DesktopSection.screen),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
