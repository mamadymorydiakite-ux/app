import 'package:flutter/material.dart';

import '../state/link_controller.dart';
import '../theme.dart';
import '../widgets/link_widgets.dart';
import '../widgets/prototype_state_card.dart';
import 'desktop_shell.dart';

class DesktopSettingsScreen extends StatefulWidget {
  const DesktopSettingsScreen({super.key, required this.controller, required this.go});

  final LinkController controller;
  final ValueChanged<DesktopSection> go;

  @override
  State<DesktopSettingsScreen> createState() => _DesktopSettingsScreenState();
}

class _DesktopSettingsScreenState extends State<DesktopSettingsScreen> {
  late final TextEditingController _port = TextEditingController(text: widget.controller.preferredPort);

  @override
  void dispose() {
    _port.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    return DesktopScreen(
      title: 'Settings',
      subtitle: 'Link stays offline — every option below is stored on this computer.',
      trailing: const StatusBadge(label: 'Local Connection Only', tone: BadgeTone.ok),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
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
                            Expanded(
                              child: Text('Language', style: LinkText.body.copyWith(fontWeight: FontWeight.w600)),
                            ),
                            DropdownButton<String>(
                              value: c.language,
                              underline: const SizedBox.shrink(),
                              style: LinkText.body.copyWith(
                                fontWeight: FontWeight.w700,
                                color: LinkColors.accent,
                              ),
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
                          label: 'Start on Boot',
                          subtitle: 'Launch Link with Windows',
                          value: c.startOnBoot,
                          onChanged: c.setStartOnBoot,
                        ),
                        const Divider(height: 12),
                        LinkSwitchRow(
                          icon: Icons.notifications_rounded,
                          label: 'Notifications',
                          subtitle: 'Transfer and pairing alerts',
                          value: c.notifications,
                          onChanged: c.setNotifications,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  _ConnectionCard(controller: c, port: _port),
                  const SizedBox(height: 14),
                  _SecurityCard(controller: c),
                  const SizedBox(height: 14),
                  _AboutCard(controller: c),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                children: [
                  PrototypeStateCard(controller: c),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ConnectionCard extends StatelessWidget {
  const _ConnectionCard({required this.controller, required this.port});

  final LinkController controller;
  final TextEditingController port;

  @override
  Widget build(BuildContext context) {
    final c = controller;
    return LinkCard(
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
                    Text('Port', style: LinkText.body.copyWith(fontWeight: FontWeight.w600)),
                    Text('Local listening port', style: LinkText.small),
                  ],
                ),
              ),
              SizedBox(
                width: 96,
                child: TextField(
                  controller: port,
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
            subtitle: 'Reconnect to the last phone',
            value: c.autoConnect,
            onChanged: c.setAutoConnect,
          ),
          const Divider(height: 12),
          Row(
            children: [
              const IconTile(icon: Icons.timer_outlined, size: 34),
              const SizedBox(width: 12),
              Expanded(
                child: Text('Timeout', style: LinkText.body.copyWith(fontWeight: FontWeight.w600)),
              ),
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
    );
  }
}

class _SecurityCard extends StatelessWidget {
  const _SecurityCard({required this.controller});

  final LinkController controller;

  @override
  Widget build(BuildContext context) {
    final c = controller;
    return LinkCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionLabel('Security'),
          const SizedBox(height: 6),
          LinkSwitchRow(
            icon: Icons.pin_rounded,
            label: 'Require PIN for pairing',
            subtitle: 'Ask for the PIN on the first connection',
            value: c.requirePin,
            onChanged: c.setRequirePin,
          ),
          const Divider(height: 12),
          LinkSwitchRow(
            icon: Icons.lock_rounded,
            label: 'Local TLS Encryption',
            subtitle: 'Encrypt local traffic between devices',
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
                    Text('Allowed Devices', style: LinkText.body.copyWith(fontWeight: FontWeight.w600)),
                    Text('${c.allowedDevices} devices approved', style: LinkText.small),
                  ],
                ),
              ),
              PillButton(label: 'Add device', dense: true, tone: PillTone.soft, onPressed: c.addAllowedDevice),
            ],
          ),
        ],
      ),
    );
  }
}


class _AboutCard extends StatelessWidget {
  const _AboutCard({required this.controller});

  final LinkController controller;

  @override
  Widget build(BuildContext context) {
    final c = controller;
    return LinkCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionLabel('About'),
          const SizedBox(height: 12),
          Row(
            children: [
              const LinkLogo(size: 40, showWord: false),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Link for Windows', style: LinkText.body.copyWith(fontWeight: FontWeight.w700)),
                    Text('Version ${c.appVersion}', style: LinkText.small),
                  ],
                ),
              ),
              const StatusBadge(label: 'Offline', tone: BadgeTone.ok),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              PillButton(
                label: 'Check Now',
                icon: Icons.refresh_rounded,
                dense: true,
                onPressed: () => showLinkToast(context, 'You are running the latest local build'),
              ),
              const SizedBox(width: 10),
              PillButton(
                label: 'Open-source licences',
                tone: PillTone.white,
                dense: true,
                onPressed: () => showLinkToast(context, 'Licences are bundled offline with the app'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

