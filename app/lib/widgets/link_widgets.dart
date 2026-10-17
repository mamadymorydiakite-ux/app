import 'package:flutter/material.dart';

import '../theme.dart';

/// Rounded soft card used across both shells.
class LinkCard extends StatelessWidget {
  const LinkCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.color = LinkColors.card,
    this.borderColor = LinkColors.border,
    this.radius = LinkRadii.lg,
    this.dashed = false,
    this.width,
    this.height,
    this.onTap,
    this.shadow = true,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color color;
  final Color borderColor;
  final double radius;
  final bool dashed;
  final double? width;
  final double? height;
  final VoidCallback? onTap;
  final bool shadow;

  @override
  Widget build(BuildContext context) {
    final content = Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: dashed ? Colors.transparent : color,
        borderRadius: BorderRadius.circular(radius),
        border: dashed ? null : Border.all(color: borderColor),
        boxShadow: shadow ? kSoftShadow : null,
      ),
      child: dashed
          ? CustomPaint(
              painter: _DashedBorderPainter(color: borderColor, radius: radius),
              child: child,
            )
          : child,
    );
    if (onTap == null) return content;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(radius),
      child: content,
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;
    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Radius.circular(radius),
      ));
    const dash = 7.0;
    const gap = 5.0;
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = (distance + dash).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance = next + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.radius != radius;
}

enum PillTone { accent, soft, white, dark, danger, ghost }

/// Pill-shaped button matching the mockup (fully rounded, white text on accent).
class PillButton extends StatelessWidget {
  const PillButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.tone = PillTone.accent,
    this.expand = false,
    this.dense = false,
    this.trailingIcon,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final PillTone tone;
  final bool expand;
  final bool dense;
  final IconData? trailingIcon;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, border) = switch (tone) {
      PillTone.accent => (LinkColors.accent, Colors.white, LinkColors.accent),
      PillTone.soft => (LinkColors.accentSoft, LinkColors.accent, LinkColors.accentSoft),
      PillTone.white => (Colors.white, LinkColors.text, LinkColors.border),
      PillTone.dark => (LinkColors.accentDark, Colors.white, LinkColors.accentDark),
      PillTone.danger => (LinkColors.errSoft, LinkColors.err, LinkColors.errSoft),
      PillTone.ghost => (Colors.transparent, LinkColors.accent, Colors.transparent),
    };
    final child = Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: dense ? 15 : 17, color: fg),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: fg,
              fontSize: dense ? 12.5 : 13.5,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.1,
            ),
          ),
        ),
        if (trailingIcon != null) ...[
          const SizedBox(width: 6),
          Icon(trailingIcon, size: dense ? 15 : 17, color: fg),
        ],
      ],
    );

    return Material(
      color: bg,
      shape: StadiumBorder(side: BorderSide(color: border)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: dense ? 14 : 18,
            vertical: dense ? 8 : 12,
          ),
          child: child,
        ),
      ),
    );
  }
}

enum BadgeTone { ok, warn, err, accent, muted, dark }

class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.label,
    this.tone = BadgeTone.muted,
    this.icon,
    this.dot = true,
    this.pulse = false,
  });

  final String label;
  final BadgeTone tone;
  final IconData? icon;
  final bool dot;
  final bool pulse;

  @override
  Widget build(BuildContext context) {
    final (fg, bg) = switch (tone) {
      BadgeTone.ok => (LinkColors.ok, LinkColors.okSoft),
      BadgeTone.warn => (LinkColors.warn, LinkColors.warnSoft),
      BadgeTone.err => (LinkColors.err, LinkColors.errSoft),
      BadgeTone.accent => (LinkColors.accent, LinkColors.accentSoft),
      BadgeTone.muted => (LinkColors.muted, const Color(0xFFEDE5D9)),
      BadgeTone.dark => (Colors.white, LinkColors.dark),
    };
    final marker = pulse
        ? PulseDot(color: fg)
        : (dot
            ? Container(
                width: 6.5,
                height: 6.5,
                decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
              )
            : null);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(LinkRadii.pill)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (marker != null) ...[marker, const SizedBox(width: 6)],
          if (icon != null) ...[Icon(icon, size: 13, color: fg), const SizedBox(width: 5)],
          Text(label.toUpperCase(), style: LinkText.pill.copyWith(color: fg)),
        ],
      ),
    );
  }
}

/// Pulsing dot used by LIVE badges and ringing waves.
class PulseDot extends StatefulWidget {
  const PulseDot({super.key, required this.color, this.size = 7});

  final Color color;
  final double size;

  @override
  State<PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<PulseDot> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.35, end: 1).animate(_controller),
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle),
      ),
    );
  }
}



/// Link brand mark: two interlinked chain links + wordmark.
class LinkLogo extends StatelessWidget {
  const LinkLogo({super.key, this.size = 44, this.showWord = true, this.wordColor = LinkColors.text});

  final double size;
  final bool showWord;
  final Color wordColor;

  @override
  Widget build(BuildContext context) {
    final mark = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: LinkColors.accent,
        borderRadius: BorderRadius.circular(size * 0.32),
        boxShadow: kAccentShadow,
      ),
      child: Icon(Icons.link_rounded, color: Colors.white, size: size * 0.56),
    );
    if (!showWord) return mark;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        mark,
        const SizedBox(width: 12),
        Text(
          'Link',
          style: TextStyle(
            fontSize: size * 0.58,
            fontWeight: FontWeight.w800,
            letterSpacing: -1,
            color: wordColor,
          ),
        ),
      ],
    );
  }
}

class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key, this.trailing});

  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final label = Text(text.toUpperCase(), style: LinkText.label);
    if (trailing == null) return label;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(child: label),
        const SizedBox(width: 10),
        trailing!,
      ],
    );
  }
}

class LinkSwitchRow extends StatelessWidget {
  const LinkSwitchRow({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.subtitle,
    this.icon,
  });

  final String label;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          if (icon != null) ...[
            IconTile(icon: icon!, size: 34),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: LinkText.body.copyWith(fontWeight: FontWeight.w600)),
                if (subtitle != null) Text(subtitle!, style: LinkText.small),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class LinkTabs extends StatelessWidget {
  const LinkTabs({super.key, required this.labels, required this.index, required this.onChanged});

  final List<String> labels;
  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFEDE5D9),
        borderRadius: BorderRadius.circular(LinkRadii.pill),
      ),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  decoration: BoxDecoration(
                    color: i == index ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(LinkRadii.pill),
                    boxShadow: i == index ? kSoftShadow : null,
                  ),
                  child: Text(
                    labels[i],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: i == index ? LinkColors.accent : LinkColors.muted,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class LinkProgressBar extends StatelessWidget {
  const LinkProgressBar({
    super.key,
    required this.value,
    this.height = 7,
    this.color = LinkColors.accent,
    this.track = LinkColors.accentSoft,
  });

  final double value;
  final double height;
  final Color color;
  final Color track;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value.clamp(0.0, 1.0)),
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOut,
      builder: (context, v, _) => ClipRRect(
        borderRadius: BorderRadius.circular(LinkRadii.pill),
        child: Stack(
          children: [
            Container(height: height, color: track),
            FractionallySizedBox(
              widthFactor: v,
              child: Container(height: height, color: color),
            ),
          ],
        ),
      ),
    );
  }
}

/// Orange sync spinner used on the connecting screens.
class LinkSpinner extends StatefulWidget {
  const LinkSpinner({super.key, this.size = 54, this.color = LinkColors.accent});

  final double size;
  final Color color;

  @override
  State<LinkSpinner> createState() => _LinkSpinnerState();
}

class _LinkSpinnerState extends State<LinkSpinner> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: widget.size,
            height: widget.size,
            child: CircularProgressIndicator(
              strokeWidth: 3.4,
              valueColor: AlwaysStoppedAnimation<Color>(widget.color),
              backgroundColor: LinkColors.accentSoft,
            ),
          ),
          RotationTransition(
            turns: _controller,
            child: Icon(Icons.sync_rounded, size: widget.size * 0.46, color: widget.color),
          ),
        ],
      ),
    );
  }
}

class IconTile extends StatelessWidget {
  const IconTile({
    super.key,
    required this.icon,
    this.size = 42,
    this.background = LinkColors.accentSoft,
    this.color = LinkColors.accent,
  });

  final IconData icon;
  final double size;
  final Color background;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(size * 0.3),
      ),
      child: Icon(icon, size: size * 0.5, color: color),
    );
  }
}

class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.label,
    required this.value,
    this.valueColor = LinkColors.text,
    this.icon,
  });

  final String label;
  final String value;
  final Color valueColor;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return LinkCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[Icon(icon, size: 13, color: LinkColors.faint), const SizedBox(width: 5)],
              Expanded(child: Text(label.toUpperCase(), style: LinkText.label, overflow: TextOverflow.ellipsis)),
            ],
          ),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: valueColor)),
        ],
      ),
    );
  }
}

/// Small toast used to confirm clipboard / transfer actions.
void showLinkToast(BuildContext context, String message) {
  final messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) return;
  messenger
    ..clearSnackBars()
    ..showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        backgroundColor: LinkColors.accentDark,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 1600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(LinkRadii.md)),
      ),
    );
}

