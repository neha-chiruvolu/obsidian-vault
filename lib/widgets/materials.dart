import 'dart:math' as math;
import 'dart:ui' show PointMode;
import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../theme.dart';

// ───────────────────────── Studio-lit background ─────────────────────────
class StudioBackground extends StatefulWidget {
  const StudioBackground({super.key});

  @override
  State<StudioBackground> createState() => _StudioBackgroundState();
}

class _StudioBackgroundState extends State<StudioBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(seconds: 30))
        ..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => RepaintBoundary(
        child: AnimatedBuilder(
          animation: _c,
          builder: (_, __) => CustomPaint(
            size: Size.infinite,
            painter: _StudioPainter(_c.value),
          ),
        ),
      );
}

class _StudioPainter extends CustomPainter {
  final double v;
  _StudioPainter(this.v);

  @override
  void paint(Canvas canvas, Size s) {
    final full = Offset.zero & s;
    canvas.drawRect(full, Paint()..color = AppColors.bg);
    final t = v * 2 * math.pi;
    final big = math.max(s.width, s.height);

    void spot(Offset c, double r, Color col, double op) {
      canvas.drawCircle(
        c,
        r,
        Paint()
          ..shader = RadialGradient(
            colors: [col.withOpacity(op), col.withOpacity(0)],
          ).createShader(Rect.fromCircle(center: c, radius: r)),
      );
    }

    spot(Offset(s.width * 0.10, -s.height * 0.05), big * 0.75,
        AppColors.teal, 0.13 + 0.03 * math.sin(t));
    spot(Offset(s.width * 0.95, s.height * 1.02), big * 0.65,
        AppColors.mustard, 0.10 + 0.03 * math.cos(t));
    spot(Offset(s.width * 0.55, s.height * 0.35), big * 0.5, AppColors.blue,
        0.05);

    canvas.drawRect(
      full,
      Paint()
        ..shader = RadialGradient(
          radius: 1.1,
          colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
          stops: const [0.55, 1.0],
        ).createShader(full),
    );

    final rnd = math.Random(7);
    final pts = <Offset>[
      for (var i = 0; i < 700; i++)
        Offset(rnd.nextDouble() * s.width, rnd.nextDouble() * s.height),
    ];
    canvas.drawPoints(
      PointMode.points,
      pts,
      Paint()
        ..color = Colors.white.withOpacity(0.05)
        ..strokeWidth = 1.2,
    );
  }

  @override
  bool shouldRepaint(covariant _StudioPainter old) => old.v != v;
}

// ───────────────────────── Matte metal panel ─────────────────────────
class Panel extends StatefulWidget {
  final Widget child;
  final EdgeInsets padding;
  final double radius;
  final Color? glow;
  const Panel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.radius = 24,
    this.glow,
  });

  @override
  State<Panel> createState() => _PanelState();
}

class _PanelState extends State<Panel> {
  bool _h = false;

  @override
  Widget build(BuildContext context) {
    final glow = widget.glow ?? AppColors.mustard;
    return MouseRegion(
      onEnter: (_) => setState(() => _h = true),
      onExit: (_) => setState(() => _h = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, _h ? -3 : 0, 0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.radius),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.panelTop, AppColors.panelBottom],
          ),
          border: Border.all(
              color: _h
                  ? glow.withOpacity(0.45)
                  : Colors.white.withOpacity(0.07)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.75),
                blurRadius: 30,
                offset: const Offset(0, 16)),
            if (_h)
              BoxShadow(color: glow.withOpacity(0.12), blurRadius: 34),
          ],
        ),
        child: Stack(
          fit: StackFit.passthrough,
          children: [
            Padding(padding: widget.padding, child: widget.child),
            Positioned(
              top: 0,
              left: widget.radius,
              right: widget.radius,
              height: 1,
              child: const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    Color(0x00FFFFFF),
                    Color(0x44FFFFFF),
                    Color(0x00FFFFFF),
                  ]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Recessed well (like an engraved display window).
class Inset extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final double radius;
  const Inset(
      {super.key,
      required this.child,
      this.padding = const EdgeInsets.all(14),
      this.radius = 16});

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: AppColors.well,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: Colors.black),
          boxShadow: [
            BoxShadow(
                color: Colors.white.withOpacity(0.07),
                offset: const Offset(0, 1)),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: Stack(
            fit: StackFit.passthrough,
            children: [
              Padding(padding: padding, child: child),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 12,
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.6),
                          Colors.transparent
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}

class PressScale extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  const PressScale({super.key, required this.child, required this.onTap});

  @override
  State<PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<PressScale> {
  bool _down = false;

  @override
  Widget build(BuildContext context) => MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (_) => setState(() => _down = true),
          onTapUp: (_) => setState(() => _down = false),
          onTapCancel: () => setState(() => _down = false),
          onTap: widget.onTap,
          child: AnimatedScale(
            scale: _down ? 0.95 : 1,
            duration: const Duration(milliseconds: 90),
            child: widget.child,
          ),
        ),
      );
}

class FadeIn extends StatelessWidget {
  final Widget child;
  final int delayMs;
  const FadeIn({super.key, required this.child, this.delayMs = 0});

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: Duration(milliseconds: 650 + delayMs),
        curve: Curves.easeOutCubic,
        builder: (context, v, c) => Opacity(
          opacity: v.clamp(0.0, 1.0).toDouble(),
          child: Transform.translate(offset: Offset(0, 40 * (1 - v)), child: c),
        ),
        child: child,
      );
}

// ───────────────────────── Gold embossed text / button ─────────────────────────
class GoldText extends StatelessWidget {
  final String text;
  final double size;
  final double spacing;
  final FontWeight weight;
  const GoldText(this.text,
      {super.key,
      this.size = 18,
      this.spacing = 4,
      this.weight = FontWeight.w900});

  @override
  Widget build(BuildContext context) {
    final base = TextStyle(
        fontSize: size, letterSpacing: spacing, fontWeight: weight);
    return Stack(children: [
      Transform.translate(
        offset: const Offset(0, 1.5),
        child: Text(text,
            style: base.copyWith(color: Colors.black.withOpacity(0.75))),
      ),
      ShaderMask(
        blendMode: BlendMode.srcIn,
        shaderCallback: (b) => const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.goldLight, AppColors.mustard, AppColors.goldDark],
        ).createShader(b),
        child: Text(text, style: base.copyWith(color: Colors.white)),
      ),
    ]);
  }
}

class GoldButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  const GoldButton(
      {super.key,
      required this.label,
      required this.icon,
      required this.onPressed});

  @override
  Widget build(BuildContext context) => PressScale(
        onTap: onPressed,
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.goldLight, AppColors.mustard, Color(0xFFB8830A)],
            ),
            border: Border.all(color: Colors.white.withOpacity(0.4)),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.6),
                  blurRadius: 18,
                  offset: const Offset(0, 8)),
              BoxShadow(
                  color: AppColors.mustard.withOpacity(0.28), blurRadius: 26),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 26,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withOpacity(0.38),
                        Colors.white.withOpacity(0)
                      ],
                    ),
                  ),
                ),
              ),
              Center(
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(icon, color: AppColors.onGold, size: 20),
                  const SizedBox(width: 10),
                  Text(label,
                      style: const TextStyle(
                          color: AppColors.onGold,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.5,
                          fontSize: 14)),
                ]),
              ),
            ]),
          ),
        ),
      );
}

class SectionLabel extends StatelessWidget {
  final String text;
  final Widget? trailing;
  const SectionLabel(this.text, {super.key, this.trailing});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Row(children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: AppColors.mustard,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                    color: AppColors.mustard.withOpacity(0.8), blurRadius: 8)
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text.toUpperCase(),
                style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 11,
                    letterSpacing: 2.6,
                    fontWeight: FontWeight.w800)),
          ),
          if (trailing != null) trailing!,
        ]),
      );
}

class LedText extends StatelessWidget {
  final String text;
  final Color color;
  final double size;
  const LedText(this.text, this.color, {super.key, this.size = 20});

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: mono(size, color).copyWith(shadows: [
          Shadow(color: color.withOpacity(0.85), blurRadius: 12),
        ]),
      );
}

String _money(double v) => money(v);

class StatLed extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  final String Function(double) fmt;
  const StatLed({
    super.key,
    required this.label,
    required this.value,
    required this.color,
    this.fmt = _money,
  });

  @override
  Widget build(BuildContext context) => Inset(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: mono(10, AppColors.muted, spacing: 2.4)),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: value),
                duration: const Duration(milliseconds: 1100),
                curve: Curves.easeOutCubic,
                builder: (_, v, __) => LedText(fmt(v), color, size: 20),
              ),
            ),
          ],
        ),
      );
}

class PillToggle extends StatelessWidget {
  final List<String> labels;
  final int index;
  final ValueChanged<int> onChanged;
  const PillToggle(
      {super.key,
      required this.labels,
      required this.index,
      required this.onChanged});

  @override
  Widget build(BuildContext context) => Row(children: [
        for (var i = 0; i < labels.length; i++)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: PressScale(
              onTap: () => onChanged(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: i == index
                      ? const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [AppColors.goldLight, AppColors.mustard])
                      : null,
                  color: i == index ? null : const Color(0xFF0B0E10),
                  border: Border.all(
                      color: Colors.white.withOpacity(i == index ? 0.4 : 0.08)),
                  boxShadow: i == index
                      ? [
                          BoxShadow(
                              color: AppColors.mustard.withOpacity(0.35),
                              blurRadius: 14)
                        ]
                      : [],
                ),
                child: Text(labels[i],
                    style: mono(
                        11,
                        i == index ? AppColors.onGold : AppColors.muted,
                        spacing: 1.8)),
              ),
            ),
          ),
      ]);
}

/// Embossed round medallion + title + amount, used in lists.
class TxRow extends StatelessWidget {
  final TransactionItem tx;
  const TxRow({super.key, required this.tx});

  @override
  Widget build(BuildContext context) {
    final c = tx.category.color;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const RadialGradient(
              center: Alignment(-0.3, -0.4),
              colors: [Color(0xFF2A3238), Color(0xFF0C1013)],
            ),
            border: Border.all(color: c.withOpacity(0.55)),
            boxShadow: [BoxShadow(color: c.withOpacity(0.25), blurRadius: 12)],
          ),
          child: Icon(tx.category.icon, color: c, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(tx.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: AppColors.ink, fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text('${tx.category.label} · ${fmtDate(tx.date)}',
                  style: const TextStyle(
                      color: AppColors.muted, fontSize: 12)),
            ],
          ),
        ),
        Text(
          '${tx.isIncome ? '+' : '-'}${money(tx.amount)}',
          style: mono(14, tx.isIncome ? AppColors.green : AppColors.ink),
        ),
      ]),
    );
  }
}
