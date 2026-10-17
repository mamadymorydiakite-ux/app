import 'package:flutter/material.dart';

import '../state/link_controller.dart';
import '../theme.dart';
import 'link_widgets.dart';

/// Prototype helper shared by both shells: jump between the four connection states.
class PrototypeStateCard extends StatelessWidget {
  const PrototypeStateCard({super.key, required this.controller, this.compact = false});

  final LinkController controller;
  final bool compact;

  static const _states = <(LinkStatus, String)>[
    (LinkStatus.disconnected, 'Disconnected'),
    (LinkStatus.connecting, 'Connecting'),
    (LinkStatus.connected, 'Connected'),
    (LinkStatus.error, 'Error'),
  ];

  @override
  Widget build(BuildContext context) {
    final c = controller;
    return LinkCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionLabel('Prototype'),
          const SizedBox(height: 8),
          Text(
            'Jump between the connection states to review every screen.',
            style: LinkText.small,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final (status, label) in _states)
                PillButton(
                  label: label,
                  dense: true,
                  tone: c.status == status ? PillTone.accent : PillTone.white,
                  onPressed: () => c.setStatus(status),
                ),
            ],
          ),
          const SizedBox(height: 6),
          LinkSwitchRow(
            icon: Icons.warning_amber_rounded,
            label: 'Simulate failure on next attempt',
            value: c.failNextAttempt,
            onChanged: (v) {
              c.failNextAttempt = v;
              c.setStatus(c.status);
            },
          ),
          if (!compact)
            Text(
              'Connection is simulated locally: the mockup never contacts a server.',
              style: LinkText.small.copyWith(color: LinkColors.faint),
            ),
        ],
      ),
    );
  }
}
