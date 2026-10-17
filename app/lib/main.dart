import 'package:flutter/material.dart';

import 'desktop/desktop_shell.dart';
import 'mobile/mobile_shell.dart';
import 'state/link_controller.dart';
import 'theme.dart';
import 'widgets/link_widgets.dart';

void main() => runApp(const LinkMockupApp());

/// Offline interactive mockup of Link: Android phone + Windows computer.
class LinkMockupApp extends StatelessWidget {
  const LinkMockupApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Link — interactive mockup',
      debugShowCheckedModeBanner: false,
      theme: buildLinkTheme(),
      home: const LinkHub(),
    );
  }
}

enum HubView { both, mobile, desktop }

class LinkHub extends StatefulWidget {
  const LinkHub({super.key});

  @override
  State<LinkHub> createState() => _LinkHubState();
}

class _LinkHubState extends State<LinkHub> {
  final LinkController _controller = LinkController();
  HubView _view = HubView.both;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDE5D7),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth > 1300;
            final view = wide ? HubView.both : (_view == HubView.both ? HubView.mobile : _view);
            return Column(
              children: [
                _HubHeader(
                  view: _view,
                  wide: wide,
                  onViewChanged: (v) => setState(() => _view = v),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 6, 20, 20),
                    child: _HubBody(view: view, controller: _controller, available: constraints),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _HubHeader extends StatelessWidget {
  const _HubHeader({required this.view, required this.wide, required this.onViewChanged});

  final HubView view;
  final bool wide;
  final ValueChanged<HubView> onViewChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 10),
      child: Row(
        children: [
          const LinkLogo(size: 44),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Link — interactive mockup', style: LinkText.h2),
                Text(
                  'Pair an Android phone and a Windows computer directly over the local Wi-Fi. '
                  'No account, no cloud, no internet.',
                  style: LinkText.small,
                ),
              ],
            ),
          ),
          if (!wide) ...[
            SizedBox(
              width: 210,
              child: LinkTabs(
                labels: const ['Mobile', 'Desktop'],
                index: view == HubView.desktop ? 1 : 0,
                onChanged: (i) => onViewChanged(i == 1 ? HubView.desktop : HubView.mobile),
              ),
            ),
            const SizedBox(width: 12),
          ],
          const StatusBadge(label: 'Offline first', tone: BadgeTone.ok),
          const SizedBox(width: 8),
          const StatusBadge(label: 'New: screen share', tone: BadgeTone.accent, dot: false),
        ],
      ),
    );
  }
}

class _HubBody extends StatelessWidget {
  const _HubBody({required this.view, required this.controller, required this.available});

  final HubView view;
  final LinkController controller;
  final BoxConstraints available;

  @override
  Widget build(BuildContext context) {
    final phone = _PhoneFrame(child: MobileApp(controller: controller));
    final desktop = _WindowFrame(child: DesktopApp(controller: controller));

    if (view == HubView.mobile) {
      return SingleChildScrollView(child: Center(child: _scaled(phone, 390, 844)));
    }
    if (view == HubView.desktop) {
      return SingleChildScrollView(child: Center(child: _scaled(desktop, 1100, 700)));
    }

    final scale = (available.maxWidth / 1560).clamp(0.35, 1.0);
    return Center(
      child: SingleChildScrollView(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _scaled(phone, 390, 844, scale: scale),
            SizedBox(width: 34 * scale + 16),
            _scaled(desktop, 1100, 700, scale: scale),
          ],
        ),
      ),
    );
  }

  Widget _scaled(Widget child, double width, double height, {double scale = 1}) {
    if (scale >= 1) return child;
    return SizedBox(
      width: width * scale,
      height: height * scale,
      child: Transform.scale(
        scale: scale,
        alignment: Alignment.topLeft,
        child: SizedBox(width: width, height: height, child: child),
      ),
    );
  }
}

/// Device shell drawn around the Android surface.
class _PhoneFrame extends StatelessWidget {
  const _PhoneFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(48),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF3A322C), Color(0xFF181512)],
        ),
        boxShadow: const [BoxShadow(color: Color(0x572A2420), blurRadius: 40, offset: Offset(0, 18))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(37),
        child: SizedBox(width: 390, height: 844, child: child),
      ),
    );
  }
}

/// Windows window chrome with traffic lights.
class _WindowFrame extends StatelessWidget {
  const _WindowFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(LinkRadii.xl + 4),
        boxShadow: const [BoxShadow(color: Color(0x472A2420), blurRadius: 46, offset: Offset(0, 20))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(LinkRadii.xl + 4),
        child: SizedBox(width: 1100, height: 700, child: child),
      ),
    );
  }
}

