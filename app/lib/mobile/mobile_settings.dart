import 'package:flutter/material.dart';

import '../state/link_controller.dart';
import '../theme.dart';
import '../widgets/link_widgets.dart';
import '../widgets/prototype_state_card.dart';
import 'mobile_shell.dart';

class MobileSettingsScreen extends StatefulWidget {
  const MobileSettingsScreen({super.key, required this.controller, required this.go, required this.back});

  final LinkController controller;
  final ValueChanged<MobileRoute> go;
  final VoidCallback back;

  @override
  State<MobileSettingsScreen> createState() => _MobileSettingsScreenState();
}

class _MobileSettingsScreenState extends State<MobileSettingsScreen> {
  late final TextEditingController _port = TextEditingController(text: widget.controller.preferredPort);

  @override
  void dispose() {
    _port.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    return MobileScreen(
      title: 'Settings',
      subtitle: 'Link works fully offline — these options stay on your device.',
      trailing: const StatusBadge(label: 'Local', tone: BadgeTone.ok),
      children: [
        LinkCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionLabel('General'),
              const SizedBox(height: 6),
              Row(
                children: [
                  const IconTile(icon: Icons.language_rounded, size: 34),
                  const SizedBox(width: 12),
                  Expanded(child: Text('Language', style: LinkText.body.copyWith(fontWeight: FontWeight.w600))),
                  DropdownButton<String>(
                    value: c.language,
                    underline: const SizedBox.shrink(),
                    borderRadius: BorderRadius.circular(LinkRadii.md),
                    style: LinkText.body.copyWith(fontWeight: FontWeight.w700, color: LinkColors.accent),
                    items: const [
                      DropdownMenuItem(value: 'English', child: Text('English')),
                      DropdownMenuItem(value: 'Français', child: Text('Français')),
                      DropdownMenuItem(value: 'Español', child: Text('Español')),
                    ],
                    onChanged: (v) => c.setLanguage(v ?? 'English'),
                  ),
                ],
              ),
              const Divider(height: 22),
              LinkSwitchRow(
                icon: Icons.power_settings_new_rounded,
                label: 'Start on boot',
                subtitle: 'Open Link when the phone starts',
                value: c.startOnBoot,
                onChanged: c.setStartOnBoot,
              ),
              const Divider(height: 12),
              LinkSwitchRow(
                icon: Icons.notifications_rounded,
                label: 'Notifications',
                subtitle: 'Alerts for transfers and pairing',
                value: c.notifications,
                onChanged: c.setNotifications,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        LinkCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionLabel('Connection'),
              const SizedBox(height: 10),
              Row(
                children: [
                  const IconTile(icon: Icons.router_rounded, size: 34),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Preferred port', style: LinkText.body.copyWith(fontWeight: FontWeight.w600)),
                        Text('Used for the local handshake', style: LinkText.small),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 96,
                    child: TextField(
                      controller: _port,
                      onSubmitted: c.setPort,
                      textAlign: TextAlign.center,
                      style: LinkText.body.copyWith(fontWeight: FontWeight.w700),
                      decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(vertical: 10)),
                    ),
                  ),
                ],
              ),
              const Divider(height: 22),
              LinkSwitchRow(
                icon: Icons.bolt_rounded,
                label: 'Auto-connect',
                subtitle: 'Reconnect to the last computer',
                value: c.autoConnect,
                onChanged: c.setAutoConnect,
              ),
              const Divider(height: 12),
              Row(
                children: [
                  const IconTile(icon: Icons.timer_outlined, size: 34),
                  const SizedBox(width: 12),
                  Expanded(child: Text('Timeout', style: LinkText.body.copyWith(fontWeight: FontWeight.w600))),
                  DropdownButton<String>(
                    value: c.timeout,
                    underline: const SizedBox.shrink(),
                    style: LinkText.body.copyWith(fontWeight: FontWeight.w700, color: LinkColors.accent),
                    items: const [
                      DropdownMenuItem(value: '15 seconds', child: Text('15 seconds')),
                      DropdownMenuItem(value: '30 seconds', child: Text('30 seconds')),
                      DropdownMenuItem(value: '60 seconds', child: Text('60 seconds')),
                    ],
                    onChanged: (v) => c.setTimeout(v ?? '30 seconds'),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        LinkCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionLabel('Security'),
              const SizedBox(height: 6),
              LinkSwitchRow(
                icon: Icons.pin_rounded,
                label: 'Pairing PIN',
                subtitle: 'Require a PIN on first connection',
                value: c.requirePin,
                onChanged: c.setRequirePin,
              ),
              const Divider(height: 12),
              LinkSwitchRow(
                icon: Icons.lock_rounded,
                label: 'Local TLS encryption',
                subtitle: 'Encrypt traffic between your devices',
                value: c.localTls,
                onChanged: c.setLocalTls,
              ),
              const Divider(height: 12),
              Row(
                children: [
                  const IconTile(icon: Icons.verified_user_rounded, size: 34),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Allowed devices', style: LinkText.body.copyWith(fontWeight: FontWeight.w600)),
                        Text('${c.allowedDevices} devices approved', style: LinkText.small),
                      ],
                    ),
                  ),
                  PillButton(label: 'Add', dense: true, tone: PillTone.soft, onPressed: c.addAllowedDevice),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        LinkCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionLabel('About'),
              const SizedBox(height: 10),
              Row(
                children: [
                  const LinkLogo(size: 36, showWord: false),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Link', style: LinkText.body.copyWith(fontWeight: FontWeight.w700)),
                        Text('Version ${c.appVersion}', style: LinkText.small),
                      ],
                    ),
                  ),
                  const StatusBadge(label: 'Offline', tone: BadgeTone.ok),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: PillButton(
                      label: 'Check for updates',
                      tone: PillTone.white,
                      dense: true,
                      expand: true,
                      onPressed: () => showLinkToast(context, 'You are on the latest local build'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: PillButton(
                      label: 'Licences',
                      tone: PillTone.white,
                      dense: true,
                      expand: true,
                      onPressed: () => showLinkToast(context, 'Open-source licences (offline copy)'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        PrototypeStateCard(controller: c),

      ],
    );
  }
}
