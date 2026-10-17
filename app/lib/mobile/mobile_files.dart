import 'package:flutter/material.dart';

import '../state/link_controller.dart';
import '../theme.dart';
import '../widgets/link_widgets.dart';
import 'mobile_shell.dart';

class MobileSendFilesScreen extends StatelessWidget {
  const MobileSendFilesScreen({super.key, required this.controller, required this.go, required this.back});

  final LinkController controller;
  final ValueChanged<MobileRoute> go;
  final VoidCallback back;

  @override
  Widget build(BuildContext context) {
    final c = controller;
    final activeList = c.transfers.where((t) => t.state == TransferState.active).toList();
    final active = activeList.isEmpty ? null : activeList.first;

    return MobileScreen(
      title: 'Send Files',
      subtitle: 'Transfers stay on your local Wi-Fi network.',
      trailing: const StatusBadge(label: 'Local', tone: BadgeTone.ok),
      children: [
        LinkCard(
          dashed: true,
          shadow: false,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 26),
          onTap: () {
            c.startTransfer();
            showLinkToast(context, 'File added to the local transfer queue');
          },
          child: Column(
            children: [
              const IconTile(icon: Icons.add_rounded, size: 52),
              const SizedBox(height: 12),
              Text('Select files to send', style: LinkText.body.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(
                'Share photos, videos or files instantly',
                textAlign: TextAlign.center,
                style: LinkText.small,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        SectionLabel(
          'Recent Transfers',
          trailing: Text('${c.transfers.length} files', style: LinkText.small),
        ),
        const SizedBox(height: 10),
        LinkCard(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          child: Column(
            children: [
              for (final t in c.transfers)
                TransferRow(
                  item: t,
                  onTap: t.state == TransferState.active ? () => go(MobileRoute.fileTransfer) : null,
                ),
            ],
          ),
        ),
        if (active != null) ...[
          const SizedBox(height: 14),
          PillButton(
            label: 'View transfer progress',
            tone: PillTone.white,
            expand: true,
            icon: Icons.timelapse_rounded,
            onPressed: () => go(MobileRoute.fileTransfer),
          ),
        ],
      ],
    );
  }
}

/// One row of the transfer list, shared by the phone and desktop shells.
class TransferRow extends StatelessWidget {
  const TransferRow({super.key, required this.item, this.onTap, this.showProgressBar = true});

  final TransferItem item;
  final VoidCallback? onTap;
  final bool showProgressBar;

  @override
  Widget build(BuildContext context) {
    final done = item.state == TransferState.done;
    final active = item.state == TransferState.active;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 9),
        child: Column(
          children: [
            Row(
              children: [
                IconTile(
                  icon: item.isUpload ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                  size: 34,
                  background: done ? LinkColors.okSoft : LinkColors.accentSoft,
                  color: done ? LinkColors.ok : LinkColors.accent,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: LinkText.body.copyWith(fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        active
                            ? '${item.size} • ${(item.progress * 100).round()}% Completed'
                            : '${item.size} • ${item.isUpload ? 'Phone → PC' : 'PC → Phone'}',
                        style: LinkText.small,
                      ),
                    ],
                  ),
                ),
                if (done)
                  const Icon(Icons.check_circle_rounded, size: 19, color: LinkColors.ok)
                else if (active)
                  Text('${(item.progress * 100).round()}%',
                      style: LinkText.pill.copyWith(color: LinkColors.accent))
                else
                  Text('Queued', style: LinkText.pill.copyWith(color: LinkColors.faint)),
              ],
            ),
            if (showProgressBar && active) ...[
              const SizedBox(height: 8),
              LinkProgressBar(value: item.progress, height: 5),
            ],
          ],
        ),
      ),
    );
  }
}

class MobileFileTransferScreen extends StatelessWidget {
  const MobileFileTransferScreen({super.key, required this.controller, required this.go, required this.back});

  final LinkController controller;
  final ValueChanged<MobileRoute> go;
  final VoidCallback back;

  @override
  Widget build(BuildContext context) {
    final c = controller;
    final activeList = c.transfers.where((t) => t.state == TransferState.active).toList();
    final active = activeList.isEmpty ? null : activeList.first;
    final queued = c.transfers.where((t) => t.state == TransferState.queued).toList();

    return MobileScreen(
      showBack: true,
      onBack: back,
      title: 'Sending to ${c.pcName}',
      subtitle: 'Direct device-to-device transfer over local Wi-Fi.',
      children: [
        if (active == null)
          LinkCard(
            color: LinkColors.okSoft,
            borderColor: LinkColors.okSoft,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              children: [
                const Icon(Icons.check_circle_rounded, size: 40, color: LinkColors.ok),
                const SizedBox(height: 10),
                Text('All transfers complete', style: LinkText.body.copyWith(fontWeight: FontWeight.w700)),
                Text('Nothing left in the local queue.', style: LinkText.small),
              ],
            ),
          )
        else
          LinkCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const IconTile(icon: Icons.description_rounded, size: 40),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(active.name, style: LinkText.body.copyWith(fontWeight: FontWeight.w700)),
                          Text(
                            '${active.size} • ${(active.progress * 100).round()}% Completed',
                            style: LinkText.small,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                LinkProgressBar(value: active.progress, height: 8),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.speed_rounded, size: 15, color: LinkColors.accent),
                    const SizedBox(width: 6),
                    Text(active.speed, style: LinkText.pill.copyWith(color: LinkColors.accent)),
                    const Spacer(),
                    Text(active.remaining, style: LinkText.small),
                  ],
                ),
              ],
            ),
          ),
        const SizedBox(height: 14),
        PillButton(
          label: 'Cancel Transfer',
          tone: PillTone.danger,
          expand: true,
          onPressed: () {
            c.cancelTransfer();
            showLinkToast(context, 'Transfer cancelled — file moved back to the queue');
          },
        ),
        const SizedBox(height: 20),
        SectionLabel(
          'Queue (${queued.length} files remaining)',
          trailing: GestureDetector(
            onTap: c.clearQueue,
            child: Text('Clear All', style: LinkText.pill.copyWith(color: LinkColors.accent)),
          ),
        ),
        const SizedBox(height: 10),
        if (queued.isEmpty)
          Text('The queue is empty.', style: LinkText.small)
        else
          LinkCard(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            child: Column(
              children: [for (final t in queued) TransferRow(item: t, showProgressBar: false)],
            ),
          ),
        const SizedBox(height: 14),
        Center(child: Text('Everything transfers locally — nothing is uploaded.', style: LinkText.small)),
      ],
    );
  }
}

