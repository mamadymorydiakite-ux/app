import 'package:flutter/material.dart';

import '../state/link_controller.dart';
import '../theme.dart';
import '../widgets/link_widgets.dart';
import 'desktop_files.dart';
import 'desktop_overview.dart';
import 'desktop_settings.dart';
import 'desktop_tools.dart';

/// Sidebar destinations of the Windows app.
enum DesktopSection {
  overview,
  files,
  clipboard,
  keyboard,
  mouse,
  screen,
  ring,
  settings,
}

class DesktopNavItem {
  const DesktopNavItem(this.section, this.label, this.icon);

  final DesktopSection section;
  final String label;
  final IconData icon;
}

const List<DesktopNavItem> kDesktopNav = [
  DesktopNavItem(DesktopSection.overview, 'Overview', Icons.dashboard_rounded),
  DesktopNavItem(DesktopSection.files, 'Files', Icons.folder_rounded),
  DesktopNavItem(DesktopSection.clipboard, 'Clipboard', Icons.content_paste_rounded),
  DesktopNavItem(DesktopSection.keyboard, 'Keyboard', Icons.keyboard_rounded),
  DesktopNavItem(DesktopSection.mouse, 'Mouse', Icons.mouse_rounded),
  DesktopNavItem(DesktopSection.screen, 'Screen', Icons.cast_rounded),
  DesktopNavItem(DesktopSection.ring, 'Ring Phone', Icons.notifications_active_rounded),
  DesktopNavItem(DesktopSection.settings, 'Settings', Icons.settings_rounded),
];

/// Windows shell: 1100 × 700 window with traffic lights, sidebar and title bar.
class DesktopApp extends StatefulWidget {
  const DesktopApp({super.key, required this.controller});

  final LinkController controller;

  @override
  State<DesktopApp> createState() => _DesktopAppState();
}

class _DesktopAppState extends State<DesktopApp> {
  DesktopSection _section = DesktopSection.overview;

  void _select(DesktopSection section) => setState(() => _section = section);

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    return AnimatedBuilder(
      animation: c,
      builder: (context, _) {
        return Container(
          width: 1100,
          height: 700,
          decoration: BoxDecoration(
            color: LinkColors.background,
            borderRadius: BorderRadius.circular(LinkRadii.xl),
            border: Border.all(color: const Color(0xFFD8CEBE)),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              _TitleBar(controller: c, section: _section),
              Expanded(
                child: Row(
                  children: [
                    _Sidebar(
                      section: _section,
                      controller: c,
                      onSelect: _select,
                    ),
                    Expanded(
                      child: DesktopRouter(
                        section: _section,
                        controller: c,
                        go: _select,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TitleBar extends StatelessWidget {
  const _TitleBar({required this.controller, required this.section});

  final LinkController controller;
  final DesktopSection section;

  String get _title => switch (section) {
        DesktopSection.overview => 'Overview',
        DesktopSection.files => 'Files',
        DesktopSection.clipboard => 'Clipboard Sync',
        DesktopSection.keyboard => 'Remote Keyboard',
        DesktopSection.mouse => 'Remote Touchpad',
        DesktopSection.screen => 'Screen',
        DesktopSection.ring => 'Ring Phone',
        DesktopSection.settings => 'Settings',
      };

  @override
  Widget build(BuildContext context) {
    final connected = controller.status == LinkStatus.connected;
    return Container(
      height: 46,
      decoration: const BoxDecoration(
        color: LinkColors.card,
        border: Border(bottom: BorderSide(color: LinkColors.border)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          for (final color in const [Color(0xFFE5645A), Color(0xFFE6B64C), Color(0xFF63C066)])
            Container(
              width: 11,
              height: 11,
              margin: const EdgeInsets.only(right: 7),
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
          const SizedBox(width: 10),
          Text(_title, style: LinkText.pill.copyWith(color: LinkColors.muted)),
          const Spacer(),
          StatusBadge(
            label: connected ? controller.phoneName : 'Offline Mode',
            tone: connected ? BadgeTone.ok : BadgeTone.muted,
          ),
        ],
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({required this.section, required this.controller, required this.onSelect});

  final DesktopSection section;
  final LinkController controller;
  final ValueChanged<DesktopSection> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 216,
      decoration: const BoxDecoration(
        color: LinkColors.card,
        border: Border(right: BorderSide(color: LinkColors.border)),
      ),
      padding: const EdgeInsets.fromLTRB(14, 18, 14, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 6, bottom: 18),
            child: LinkLogo(size: 36),
          ),
          for (final item in kDesktopNav) ...[
            _NavButton(
              item: item,
              selected: item.section == section,
              onTap: () => onSelect(item.section),
            ),
            const SizedBox(height: 4),
          ],
          const Spacer(),
          PillButton(
            label: 'Disconnect',
            tone: PillTone.danger,
            expand: true,
            icon: Icons.link_off_rounded,
            onPressed: controller.disconnect,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.lan_rounded, size: 14, color: LinkColors.faint),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  'Local Connection Only',
                  style: LinkText.small.copyWith(fontSize: 11.5),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({required this.item, required this.selected, required this.onTap});

  final DesktopNavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(LinkRadii.md),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          color: selected ? LinkColors.accent : Colors.transparent,
          borderRadius: BorderRadius.circular(LinkRadii.md),
        ),
        child: Row(
          children: [
            Icon(item.icon, size: 17, color: selected ? Colors.white : LinkColors.muted),
            const SizedBox(width: 11),
            Text(
              item.label,
              style: LinkText.body.copyWith(
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white : LinkColors.text,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Desktop content scaffold: scrollable body with an optional header.
class DesktopScreen extends StatelessWidget {
  const DesktopScreen({
    super.key,
    required this.children,
    this.title,
    this.subtitle,
    this.trailing,
    this.padding = const EdgeInsets.fromLTRB(26, 22, 26, 26),
  });

  final List<Widget> children;
  final String? title;
  final String? subtitle;
  final Widget? trailing;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                        const SizedBox(height: 5),
                        Text(subtitle!, style: LinkText.small),
                      ],
                    ],
                  ),
                ),
                ?trailing,
              ],
            ),
          if (title != null) const SizedBox(height: 18),
          ...children,
        ],
      ),
    );
  }
}

class DesktopRouter extends StatelessWidget {
  const DesktopRouter({super.key, required this.section, required this.controller, required this.go});

  final DesktopSection section;
  final LinkController controller;
  final ValueChanged<DesktopSection> go;

  @override
  Widget build(BuildContext context) {
    switch (section) {
      case DesktopSection.overview:
        return DesktopOverviewScreen(controller: controller, go: go);
      case DesktopSection.files:
        return DesktopFilesScreen(controller: controller, go: go);
      case DesktopSection.clipboard:
        return DesktopClipboardScreen(controller: controller, go: go);
      case DesktopSection.keyboard:
        return DesktopKeyboardScreen(controller: controller, go: go);
      case DesktopSection.mouse:
        return DesktopMouseScreen(controller: controller, go: go);
      case DesktopSection.screen:
        return DesktopScreenView(controller: controller, go: go);
      case DesktopSection.ring:
        return DesktopRingScreen(controller: controller, go: go);
      case DesktopSection.settings:
        return DesktopSettingsScreen(controller: controller, go: go);
    }
  }
}

