import 'package:flutter/material.dart';

import '../mobile/mobile_files.dart' show TransferRow;
import '../state/link_controller.dart';
import '../theme.dart';
import '../widgets/link_widgets.dart';
import 'desktop_shell.dart';

class DesktopFilesScreen extends StatelessWidget {
  const DesktopFilesScreen({super.key, required this.controller, required this.go});

  final LinkController controller;
  final ValueChanged<DesktopSection> go;

  @override
  Widget build(BuildContext context) {
    final c = controller;
    final pending = c.transfers.where((t) => t.state != TransferState.done).toList();
    final done = c.transfers.where((t) => t.state == TransferState.done).toList();

    return DesktopScreen(
      title: 'Files',
      subtitle: 'Send files both ways over your local Wi-Fi. Nothing is uploaded.',
      trailing: const StatusBadge(label: 'Local', tone: BadgeTone.ok),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _FileColumn(
                title: 'Phone (${c.phoneName})',
                icon: Icons.smartphone_rounded,
                files: c.phoneFiles,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: LinkCard(
                dashed: true,
                shadow: false,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 30),
                onTap: () {
                  c.startTransfer();
                  showLinkToast(context, 'File queued for the local transfer');
                },
                child: Column(
                  children: [
                    const IconTile(icon: Icons.cloud_upload_rounded, size: 52),
                    const SizedBox(height: 12),
                    Text(
                      'Drag files here to send instantly',
                      textAlign: TextAlign.center,
                      style: LinkText.body.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Or click to browse this computer',
                      textAlign: TextAlign.center,
                      style: LinkText.small,
                    ),
                    const SizedBox(height: 12),
                    const StatusBadge(label: 'Peer to peer', tone: BadgeTone.accent, dot: false),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _FileColumn(
                title: 'Computer (Local)',
                icon: Icons.computer_rounded,
                files: c.computerFiles,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        if (pending.isEmpty && done.isNotEmpty)
          _TransferComplete(controller: c, go: go)
        else ...[
          SectionLabel(
            'Recent Transfers',
            trailing: Text('${pending.length} in progress', style: LinkText.small),
          ),
          const SizedBox(height: 10),
          LinkCard(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            child: Column(
              children: [
                for (final t in c.transfers) TransferRow(item: t),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _FileColumn extends StatelessWidget {
  const _FileColumn({required this.title, required this.icon, required this.files});

  final String title;
  final IconData icon;
  final List<String> files;

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
              Expanded(
                child: Text(
                  title,
                  style: LinkText.body.copyWith(fontWeight: FontWeight.w700),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (final f in files)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  const Icon(Icons.insert_drive_file_rounded, size: 16, color: LinkColors.faint),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(f, style: LinkText.body, maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
                  const Icon(Icons.drag_indicator_rounded, size: 15, color: LinkColors.faint),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _TransferComplete extends StatelessWidget {
  const _TransferComplete({required this.controller, required this.go});

  final LinkController controller;
  final ValueChanged<DesktopSection> go;

  @override
  Widget build(BuildContext context) {
    final done = controller.transfers.where((t) => t.state == TransferState.done).toList();
    return LinkCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const IconTile(
                icon: Icons.check_rounded,
                size: 44,
                background: LinkColors.okSoft,
                color: LinkColors.ok,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Transfer Complete', style: LinkText.h3),
                    const SizedBox(height: 3),
                    Text(
                      '${done.length} files sent successfully • Total size: 14.2 MB',
                      style: LinkText.small,
                    ),
                  ],
                ),
              ),
              const StatusBadge(label: 'Delivered locally', tone: BadgeTone.ok),
            ],
          ),
          const SizedBox(height: 14),
          for (final t in done)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, size: 16, color: LinkColors.ok),
                  const SizedBox(width: 9),
                  Expanded(child: Text(t.name, style: LinkText.body)),
                  Text(t.size, style: LinkText.small),
                ],
              ),
            ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: PillButton(
                  label: 'Send More Files',
                  expand: true,
                  icon: Icons.add_rounded,
                  onPressed: () {
                    controller.resetTransfers();
                    showLinkToast(context, 'New local transfer started');
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: PillButton(
                  label: 'Done',
                  tone: PillTone.white,
                  expand: true,
                  onPressed: () => go(DesktopSection.overview),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

