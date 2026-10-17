import 'package:flutter/material.dart';

import '../state/link_controller.dart';
import '../theme.dart';
import '../widgets/link_widgets.dart';
import 'mobile_files.dart';
import 'mobile_home.dart';
import 'mobile_settings.dart';
import 'mobile_tools.dart';

/// All navigable screens of the Android mockup.
enum MobileRoute {
  home,
  qrScanner,
  connecting,
  error,
  dashboard,
  sendFiles,
  fileTransfer,
  clipboard,
  keyboard,
  touchpad,
  ring,
  devices,
  screenShare,
  tools,
  settings,
}

class MobileTab {
  const MobileTab(this.label, this.icon, this.root);

  final String label;
  final IconData icon;
  final MobileRoute root;
}

const List<MobileTab> kMobileTabs = [
  MobileTab('Home', Icons.home_rounded, MobileRoute.home),
  MobileTab('Files', Icons.folder_rounded, MobileRoute.sendFiles),
  MobileTab('Clipboard', Icons.content_paste_rounded, MobileRoute.clipboard),
  MobileTab('Tools', Icons.widgets_rounded, MobileRoute.tools),
  MobileTab('Settings', Icons.settings_rounded, MobileRoute.settings),
];

/// Android shell: 390 × 844 device surface, bottom navigation, LOCAL badge.
class MobileApp extends StatefulWidget {
  const MobileApp({super.key, required this.controller});

  final LinkController controller;

  @override
  State<MobileApp> createState() => _MobileAppState();
}

class _MobileAppState extends State<MobileApp> {
  int _tab = 0;
  List<MobileRoute> _stack = [MobileRoute.home];

  MobileRoute get _current => _stack.last;

  void _go(MobileRoute route) => setState(() => _stack = [..._stack, route]);

  void _back() {
    if (_stack.length > 1) {
      setState(() => _stack = _stack.sublist(0, _stack.length - 1));
    }
  }

  void _selectTab(int index) {
    setState(() {
      _tab = index;
      _stack = [kMobileTabs[index].root];
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    return AnimatedBuilder(
      animation: c,
      builder: (context, _) {
        return Container(
          width: 390,
          height: 844,
          color: LinkColors.background,
          child: Column(
            children: [
              _StatusBar(controller: c),
              Expanded(
                child: MobileRouter(
                  route: _current,
                  controller: c,
                  go: _go,
                  back: _back,
                ),
              ),
              _BottomBar(tab: _tab, onSelect: _selectTab),
            ],
          ),
        );
      },
    );
  }
}

class _StatusBar extends StatelessWidget {
  const _StatusBar({required this.controller});

  final LinkController controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Row(
          children: [
            if (controller.status == LinkStatus.connected)
              const StatusBadge(label: 'Local', tone: BadgeTone.ok)
            else
              Text('9:41', style: LinkText.body.copyWith(fontWeight: FontWeight.w700, fontSize: 12.5)),
            const Spacer(),
            Text('9:41', style: LinkText.body.copyWith(fontWeight: FontWeight.w700, fontSize: 12.5)),
            const SizedBox(width: 8),
            const Icon(Icons.wifi_rounded, size: 15, color: LinkColors.text),
            const SizedBox(width: 5),
            const Icon(Icons.signal_cellular_alt_rounded, size: 15, color: LinkColors.text),
            const SizedBox(width: 5),
            const Icon(Icons.battery_full_rounded, size: 16, color: LinkColors.text),
          ],
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.tab, required this.onSelect});

  final int tab;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: LinkColors.card,
        border: Border(top: BorderSide(color: LinkColors.border)),
      ),
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 14),
      child: Row(
        children: [
          for (var i = 0; i < kMobileTabs.length; i++)
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onSelect(i),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                      decoration: BoxDecoration(
                        color: i == tab ? LinkColors.accentSoft : Colors.transparent,
                        borderRadius: BorderRadius.circular(LinkRadii.pill),
                      ),
                      child: Icon(
                        kMobileTabs[i].icon,
                        size: 20,
                        color: i == tab ? LinkColors.accent : LinkColors.faint,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      kMobileTabs[i].label,
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: i == tab ? LinkColors.accent : LinkColors.faint,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Shared mobile screen scaffold: optional back link, title block, scrollable body.
class MobileScreen extends StatelessWidget {
  const MobileScreen({
    super.key,
    required this.children,
    this.title,
    this.subtitle,
    this.showBack = false,
    this.onBack,
    this.trailing,
    this.padding = const EdgeInsets.fromLTRB(18, 6, 18, 22),
    this.scroll = true,
  });

  final List<Widget> children;
  final String? title;
  final String? subtitle;
  final bool showBack;
  final VoidCallback? onBack;
  final Widget? trailing;
  final EdgeInsetsGeometry padding;
  final bool scroll;

  @override
  Widget build(BuildContext context) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showBack)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: GestureDetector(
              onTap: onBack,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.arrow_back_ios_new_rounded, size: 14, color: LinkColors.accent),
                  const SizedBox(width: 6),
                  Text('Back', style: LinkText.pill.copyWith(color: LinkColors.accent)),
                ],
              ),
            ),
          ),
        if (title != null)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title!, style: LinkText.h2),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(subtitle!, style: LinkText.small),
                    ],
                  ],
                ),
              ),
              ?trailing,
            ],
          ),
        if (title != null) const SizedBox(height: 14),
        ...children,
      ],
    );

    if (!scroll) return Padding(padding: padding, child: content);
    return SingleChildScrollView(padding: padding, child: content);
  }
}


/// Builds the widget for the current route.
class MobileRouter extends StatelessWidget {
  const MobileRouter({
    super.key,
    required this.route,
    required this.controller,
    required this.go,
    required this.back,
  });

  final MobileRoute route;
  final LinkController controller;
  final ValueChanged<MobileRoute> go;
  final VoidCallback back;

  @override
  Widget build(BuildContext context) {
    switch (route) {
      case MobileRoute.home:
        return controller.status == LinkStatus.connected
            ? MobileDashboardScreen(controller: controller, go: go, back: back)
            : MobileHomeScreen(controller: controller, go: go, back: back);
      case MobileRoute.qrScanner:
        return MobileQrScannerScreen(controller: controller, go: go, back: back);
      case MobileRoute.connecting:
        return controller.status == LinkStatus.connected
            ? MobileDashboardScreen(controller: controller, go: go, back: back)
            : MobileConnectingScreen(controller: controller, go: go, back: back);
      case MobileRoute.error:
        return MobileErrorScreen(controller: controller, go: go, back: back);
      case MobileRoute.dashboard:
        return MobileDashboardScreen(controller: controller, go: go, back: back);
      case MobileRoute.sendFiles:
        return MobileSendFilesScreen(controller: controller, go: go, back: back);
      case MobileRoute.fileTransfer:
        return MobileFileTransferScreen(controller: controller, go: go, back: back);
      case MobileRoute.clipboard:
        return MobileClipboardScreen(controller: controller, go: go, back: back);
      case MobileRoute.keyboard:
        return MobileKeyboardScreen(controller: controller, go: go, back: back);
      case MobileRoute.touchpad:
        return MobileTouchpadScreen(controller: controller, go: go, back: back);
      case MobileRoute.ring:
        return MobileRingScreen(controller: controller, go: go, back: back);
      case MobileRoute.devices:
        return MobileDevicesScreen(controller: controller, go: go, back: back);
      case MobileRoute.screenShare:
        return MobileScreenShareScreen(controller: controller, go: go, back: back);
      case MobileRoute.tools:
        return MobileToolsScreen(controller: controller, go: go, back: back);
      case MobileRoute.settings:
        return MobileSettingsScreen(controller: controller, go: go, back: back);
    }
  }
}

