import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../theme.dart';
import 'materials.dart';

// ═══════════════════════ Brushed-metal credit card ═══════════════════════
class MetalCard extends StatefulWidget {
  final String name;
  final double balance;
  const MetalCard({super.key, required this.name, required this.balance});

  @override
  State<MetalCard> createState() => _MetalCardState();
}

class _MetalCardState extends State<MetalCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(seconds: 9))
        ..repeat();
  Offset _target = Offset.zero;
  Offset _p = Offset.zero;
  bool _active = false;
  Size _size = const Size(1, 1);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _set(Offset local) {
    _target = Offset(
      (local.dx / _size.width * 2 - 1).clamp(-1.0, 1.0).toDouble(),
      (local.dy / _size.height * 2 - 1).clamp(-1.0, 1.0).toDouble(),
    );
    _active = true;
  }

  @override
  Widget build(BuildContext context) => Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: AspectRatio(
            aspectRatio: 1.586,
            child: LayoutBuilder(builder: (context, box) {
              _size = box.biggest;
              return MouseRegion(
                onHover: (e) => _set(e.localPosition),
                onExit: (_) => _active = false,
                child: Listener(
                  onPointerDown: (e) => _set(e.localPosition),
                  onPointerMove: (e) => _set(e.localPosition),
                  onPointerUp: (_) => _active = false,
                  onPointerCancel: (_) => _active = false,
                  child: AnimatedBuilder(
                    animation: _c,
                    builder: (context, _) {
                      final t = _c.value * 2 * math.pi;
                      final auto =
                          Offset(0.55 * math.sin(t), 0.35 * math.cos(t));
                      _p = Offset.lerp(_p, _active ? _target : auto, 0.10)!;
                      return _face(t);
                    },
                  ),
                ),
              );
            }),
          ),
        ),
      );

  Widget _face(double t) {
    final gold = Color.lerp(AppColors.goldLight, const Color(0xFFCBB98A), 0.45)!;
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.0011)
        ..rotateX(-_p.dy * 0.32)
        ..rotateY(_p.dx * 0.32),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.85),
                blurRadius: 40,
                offset: Offset(-_p.dx * 26, 26 - _p.dy * 10)),
            BoxShadow(
                color: AppColors.mustard.withOpacity(0.10), blurRadius: 50),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(fit: StackFit.expand, children: [
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF30363B),
                    Color(0xFF0F1214),
                    Color(0xFF242A2F),
                    Color(0xFF0B0D0F),
                  ],
                  stops: [0, 0.38, 0.7, 1],
                ),
              ),
            ),
            CustomPaint(painter: _BrushedPainter()),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(_p.dx, _p.dy),
                  radius: 0.85,
                  colors: [
                    Colors.white.withOpacity(0.22),
                    Colors.white.withOpacity(0.04),
                    Colors.transparent,
                  ],
                  stops: const [0, 0.4, 1],
                ),
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withOpacity(0.14)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    const GoldText('OBSIDIAN', size: 16, spacing: 5),
                    const Spacer(),
                    Icon(Icons.contactless,
                        color: AppColors.goldLight.withOpacity(0.8)),
                  ]),
                  const Spacer(),
                  Row(children: [
                    CustomPaint(
                        size: const Size(50, 38), painter: _ChipPainter()),
                    const SizedBox(width: 14),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text('4829  ••••  ••••  2026',
                            style: mono(13, gold, spacing: 2).copyWith(
                              shadows: const [
                                Shadow(
                                    color: Colors.black,
                                    offset: Offset(0, 1.5),
                                    blurRadius: 1)
                              ],
                            )),
                      ),
                    ),
                  ]),
                  const Spacer(),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('AVAILABLE BALANCE',
                                style: mono(9, AppColors.muted, spacing: 2.4)),
                            const SizedBox(height: 4),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0, end: widget.balance),
                                duration: const Duration(milliseconds: 1400),
                                curve: Curves.easeOutCubic,
                                builder: (_, v, __) =>
                                    GoldText(money(v), size: 32, spacing: 1),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: SweepGradient(
                            colors: const [
                              AppColors.teal,
                              AppColors.blue,
                              AppColors.mustard,
                              AppColors.green,
                              AppColors.teal,
                            ],
                            transform: GradientRotation(_p.dx * 3 + t),
                          ),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.35)),
                        ),
                        child: Icon(Icons.shield,
                            size: 20, color: Colors.black.withOpacity(0.55)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.name.trim().isEmpty
                        ? 'CARD HOLDER'
                        : widget.name.trim().toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: mono(12, gold, spacing: 2.5, weight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class _BrushedPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    final r = math.Random(5);
    final p = Paint()..strokeWidth = 0.7;
    for (var i = 0; i < 160; i++) {
      final y = r.nextDouble() * s.height;
      final x0 = r.nextDouble() * s.width * 0.5;
      final len = s.width * (0.3 + r.nextDouble() * 0.7);
      final light = r.nextBool();
      p.color = (light ? Colors.white : Colors.black)
          .withOpacity(0.015 + r.nextDouble() * 0.045);
      canvas.drawLine(Offset(x0, y), Offset(x0 + len, y), p);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class _ChipPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    final rr = RRect.fromRectAndRadius(Offset.zero & s, const Radius.circular(7));
    canvas.drawRRect(
      rr,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.goldLight, AppColors.mustard, Color(0xFFB8830A)],
        ).createShader(Offset.zero & s),
    );
    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = Colors.black.withOpacity(0.45);
    final w = s.width, h = s.height;
    canvas.drawLine(Offset(0, h * 0.33), Offset(w * 0.32, h * 0.33), line);
    canvas.drawLine(Offset(0, h * 0.66), Offset(w * 0.32, h * 0.66), line);
    canvas.drawLine(Offset(w * 0.68, h * 0.33), Offset(w, h * 0.33), line);
    canvas.drawLine(Offset(w * 0.68, h * 0.66), Offset(w, h * 0.66), line);
    canvas.drawLine(Offset(w * 0.32, h * 0.33), Offset(w * 0.32, h * 0.66), line);
    canvas.drawLine(Offset(w * 0.68, h * 0.33), Offset(w * 0.68, h * 0.66), line);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTRB(w * 0.32, h * 0.2, w * 0.68, h * 0.8),
          const Radius.circular(5)),
      line,
    );
    canvas.drawRRect(rr, line..color = Colors.white.withOpacity(0.35));
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ═══════════════════════ Analogue budget gauge ═══════════════════════
class GaugeDial extends StatelessWidget {
  final double fraction;
  final double size;
  const GaugeDial({super.key, required this.fraction, this.size = 250});

  @override
  Widget build(BuildContext context) {
    final f = fraction;
    final ledColor = f < 0.7
        ? AppColors.green
        : f <= 0.9
            ? AppColors.mustard
            : AppColors.red;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: f.clamp(0.0, 1.0).toDouble()),
      duration: const Duration(milliseconds: 2000),
      curve: Curves.elasticOut,
      builder: (context, v, _) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.85),
                blurRadius: 34,
                offset: const Offset(0, 18)),
          ],
        ),
        child: Stack(alignment: Alignment.center, children: [
          CustomPaint(size: Size(size, size), painter: _GaugePainter(v)),
          Positioned(
            bottom: size * 0.17,
            child: Inset(
              radius: 8,
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              child: LedText('${(f * 100).round()}%', ledColor, size: 16),
            ),
          ),
        ]),
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double needle;
  _GaugePainter(this.needle);

  static const _start = 3 * math.pi / 4;
  static const _sweep = 3 * math.pi / 2;

  Offset _dir(double a) => Offset(math.cos(a), math.sin(a));

  void _text(Canvas canvas, String s, Offset center, double size, Color color) {
    final tp = TextPainter(
      text: TextSpan(
          text: s,
          style: TextStyle(
              color: color, fontSize: size, fontWeight: FontWeight.w700)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final R = size.width / 2;
    final bezel = Rect.fromCircle(center: c, radius: R);

    canvas.drawCircle(
      c,
      R,
      Paint()
        ..shader = const SweepGradient(colors: [
          Color(0xFF6B747A),
          Color(0xFF1B2126),
          Color(0xFFA9B2B8),
          Color(0xFF20272C),
          Color(0xFF7A848B),
          Color(0xFF6B747A),
        ]).createShader(bezel),
    );
    canvas.drawCircle(c, R * 0.94, Paint()..color = const Color(0xFF05070A));
    final faceRect = Rect.fromCircle(center: c, radius: R * 0.91);
    canvas.drawCircle(
      c,
      R * 0.91,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.3, -0.4),
          colors: [Color(0xFF1B2227), Color(0xFF080B0D)],
        ).createShader(faceRect),
    );

    // colour zones
    final zoneRect = Rect.fromCircle(center: c, radius: R * 0.80);
    void zone(double a, double b, Color col) {
      final p = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = R * 0.045
        ..color = col.withOpacity(0.9);
      canvas.drawArc(
        zoneRect,
        _start + a * _sweep,
        (b - a) * _sweep,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = R * 0.045
          ..color = col.withOpacity(0.5)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );
      canvas.drawArc(zoneRect, _start + a * _sweep, (b - a) * _sweep, false, p);
    }

    zone(0, 0.69, AppColors.green);
    zone(0.70, 0.89, AppColors.mustard);
    zone(0.90, 1.0, AppColors.red);

    // ticks
    for (var i = 0; i <= 50; i++) {
      final f = i / 50;
      final a = _start + f * _sweep;
      final major = i % 5 == 0;
      final len = major ? R * 0.11 : R * 0.055;
      canvas.drawLine(
        c + _dir(a) * (R * 0.72),
        c + _dir(a) * (R * 0.72 - len),
        Paint()
          ..strokeWidth = major ? 2 : 1
          ..color = major ? AppColors.ink : AppColors.muted,
      );
    }
    for (final f in [0.0, 0.25, 0.5, 0.75, 1.0]) {
      final a = _start + f * _sweep;
      _text(canvas, '${(f * 100).round()}', c + _dir(a) * (R * 0.52), R * 0.075,
          AppColors.muted);
    }
    _text(canvas, 'BUDGET', c + Offset(0, -R * 0.28), R * 0.06, AppColors.muted);

    // needle
    final nf = needle.clamp(-0.03, 1.06).toDouble();
    final a = _start + nf * _sweep;
    final tip = c + _dir(a) * (R * 0.74);
    final tail = c - _dir(a) * (R * 0.14);
    canvas.drawLine(
      tail + const Offset(3, 4),
      tip + const Offset(3, 4),
      Paint()
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round
        ..color = Colors.black.withOpacity(0.6)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
    canvas.drawLine(
      tail,
      tip,
      Paint()
        ..strokeWidth = 3.5
        ..strokeCap = StrokeCap.round
        ..shader = const LinearGradient(
          colors: [AppColors.goldLight, AppColors.red],
        ).createShader(Rect.fromPoints(tail, tip)),
    );
    final hub = Rect.fromCircle(center: c, radius: R * 0.09);
    canvas.drawCircle(
      c,
      R * 0.09,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.4, -0.4),
          colors: [Color(0xFFC9D1D6), Color(0xFF3A4249)],
        ).createShader(hub),
    );
    canvas.drawCircle(c, R * 0.03, Paint()..color = const Color(0xFF0B0E10));

    // glass reflection
    canvas.drawCircle(
      c,
      R * 0.91,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.center,
          colors: [Colors.white.withOpacity(0.09), Colors.transparent],
        ).createShader(faceRect),
    );
  }

  @override
  bool shouldRepaint(covariant _GaugePainter old) => old.needle != needle;
}

// ═══════════════════════ Oscilloscope line chart ═══════════════════════
class Scope extends StatefulWidget {
  final List<double> values;
  final double height;
  const Scope({super.key, required this.values, this.height = 200});

  @override
  State<Scope> createState() => _ScopeState();
}

class _ScopeState extends State<Scope> with TickerProviderStateMixin {
  late final AnimationController _draw = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 2000))
    ..forward();
  late final AnimationController _scan =
      AnimationController(vsync: this, duration: const Duration(seconds: 6))
        ..repeat();

  @override
  void dispose() {
    _draw.dispose();
    _scan.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SizedBox(
        height: widget.height,
        child: AnimatedBuilder(
          animation: Listenable.merge([_draw, _scan]),
          builder: (_, __) => CustomPaint(
            size: Size.infinite,
            painter: _ScopePainter(
              widget.values,
              Curves.easeOutCubic.transform(_draw.value),
              _scan.value,
            ),
          ),
        ),
      );
}

class _ScopePainter extends CustomPainter {
  final List<double> values;
  final double draw;
  final double scan;
  _ScopePainter(this.values, this.draw, this.scan);

  Path _smooth(List<Offset> p, Rect r) {
    final path = Path()..moveTo(p[0].dx, p[0].dy);
    for (var i = 0; i < p.length - 1; i++) {
      final p0 = i == 0 ? p[0] : p[i - 1];
      final p1 = p[i];
      final p2 = p[i + 1];
      final p3 = i + 2 < p.length ? p[i + 2] : p2;
      final c1 = p1 + (p2 - p0) / 6;
      final c2 = p2 - (p3 - p1) / 6;
      path.cubicTo(
        c1.dx,
        c1.dy.clamp(r.top, r.bottom).toDouble(),
        c2.dx,
        c2.dy.clamp(r.top, r.bottom).toDouble(),
        p2.dx,
        p2.dy,
      );
    }
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;
    final r = Rect.fromLTRB(8, 14, size.width - 8, size.height - 24);
    final grid = Paint()
      ..strokeWidth = 1
      ..color = Colors.white.withOpacity(0.05);
    for (var i = 0; i <= 4; i++) {
      final y = r.top + r.height * i / 4;
      canvas.drawLine(Offset(r.left, y), Offset(r.right, y), grid);
    }
    final n = values.length;
    for (var i = 0; i < n; i++) {
      final x = r.left + r.width * i / (n - 1);
      canvas.drawLine(Offset(x, r.top), Offset(x, r.bottom), grid);
    }

    final maxV = values.fold(1.0, (a, b) => math.max(a, b));
    final pts = [
      for (var i = 0; i < n; i++)
        Offset(r.left + r.width * i / (n - 1),
            r.bottom - r.height * 0.92 * (values[i] / maxV)),
    ];
    final line = _smooth(pts, r);
    final metric = line.computeMetrics().first;
    final len = metric.length * draw;
    final tangent = metric.getTangentForOffset(len);
    final headX = tangent?.position.dx ?? r.left;

    // area fill revealed up to the head
    final area = Path.from(line)
      ..lineTo(r.right, r.bottom)
      ..lineTo(r.left, r.bottom)
      ..close();
    canvas.save();
    canvas.clipRect(Rect.fromLTRB(0, 0, headX, size.height));
    canvas.drawPath(
      area,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.teal.withOpacity(0.35),
            AppColors.teal.withOpacity(0.0),
          ],
        ).createShader(r),
    );
    canvas.restore();

    final drawn = metric.extractPath(0, len);
    final shader = const LinearGradient(
      colors: [AppColors.teal, AppColors.green, AppColors.mustard],
    ).createShader(r);
    canvas.drawPath(
      drawn,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..shader = shader
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7),
    );
    canvas.drawPath(
      drawn,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round
        ..shader = shader,
    );
    if (tangent != null) {
      canvas.drawCircle(
          tangent.position,
          7,
          Paint()
            ..color = AppColors.mustard.withOpacity(0.6)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));
      canvas.drawCircle(tangent.position, 3, Paint()..color = Colors.white);
    }

    // scanning beam
    final sx = r.left + r.width * scan;
    canvas.drawRect(
      Rect.fromLTRB(sx - 46, r.top, sx, r.bottom),
      Paint()
        ..shader = LinearGradient(
          colors: [
            AppColors.teal.withOpacity(0),
            AppColors.teal.withOpacity(0.14)
          ],
        ).createShader(Rect.fromLTRB(sx - 46, r.top, sx, r.bottom)),
    );
    canvas.drawLine(
      Offset(sx, r.top),
      Offset(sx, r.bottom),
      Paint()
        ..strokeWidth = 1.2
        ..color = AppColors.teal.withOpacity(0.55),
    );

    // x labels
    final today = DateTime.now();
    for (var i = 0; i < n; i += 3) {
      final d = today.subtract(Duration(days: n - 1 - i));
      final tp = TextPainter(
        text: TextSpan(text: '${d.day}', style: mono(9, AppColors.muted)),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(pts[i].dx - tp.width / 2, r.bottom + 6));
    }
  }

  @override
  bool shouldRepaint(covariant _ScopePainter old) => true;
}

// ═══════════════════════ 70-day heatmap ═══════════════════════
class Heatmap extends StatelessWidget {
  final List<double> days; // oldest first, length 70
  const Heatmap({super.key, required this.days});

  Color _color(double v, double maxV) {
    if (v <= 0) return Colors.white.withOpacity(0.05);
    final t = (v / maxV).clamp(0.0, 1.0).toDouble();
    if (t < 0.5) {
      return Color.lerp(
          AppColors.blue.withOpacity(0.55), AppColors.teal, t * 2)!;
    }
    return Color.lerp(AppColors.teal, AppColors.mustard, (t - 0.5) * 2)!;
  }

  @override
  Widget build(BuildContext context) {
    final maxV = days.fold(1.0, (a, b) => math.max(a, b));
    const rows = 7;
    final cols = days.length ~/ rows;
    final today = DateTime.now();
    return Column(children: [
      ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Column(children: [
          for (var r = 0; r < rows; r++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2.5),
              child: Row(children: [
                for (var c = 0; c < cols; c++)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2.5),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: _cell(c * rows + r, maxV, today),
                      ),
                    ),
                  ),
              ]),
            ),
        ]),
      ),
      const SizedBox(height: 12),
      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
        Text('LESS', style: mono(9, AppColors.muted, spacing: 2)),
        const SizedBox(width: 8),
        for (final t in [0.0, 0.2, 0.45, 0.7, 1.0])
          Container(
            width: 14,
            height: 14,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: _color(t, 1.0),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        const SizedBox(width: 8),
        Text('MORE', style: mono(9, AppColors.muted, spacing: 2)),
      ]),
    ]);
  }

  Widget _cell(int idx, double maxV, DateTime today) {
    final v = days[idx];
    final col = _color(v, maxV);
    final d = today.subtract(Duration(days: days.length - 1 - idx));
    return Tooltip(
      message: '${fmtDate(d)} · ${money(v)}',
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: Duration(milliseconds: 350 + idx * 14),
        curve: Curves.easeOutBack,
        builder: (_, a, __) => Transform.scale(
          scale: a.clamp(0.0, 1.2).toDouble(),
          child: Container(
            decoration: BoxDecoration(
              color: col,
              borderRadius: BorderRadius.circular(5),
              boxShadow: v / maxV > 0.6
                  ? [BoxShadow(color: col.withOpacity(0.55), blurRadius: 8)]
                  : [],
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════ Category bars ═══════════════════════
class CategoryBars extends StatelessWidget {
  final Map<Category, double> data;
  const CategoryBars({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final entries = data.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    if (entries.isEmpty) {
      return const Text('No expenses this month yet.',
          style: TextStyle(color: AppColors.muted));
    }
    final maxV = entries.first.value;
    return Column(children: [
      for (var i = 0; i < entries.length; i++)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 7),
          child: Column(children: [
            Row(children: [
              Icon(entries[i].key.icon, size: 16, color: entries[i].key.color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(entries[i].key.label,
                    style: const TextStyle(color: AppColors.ink)),
              ),
              Text(money(entries[i].value),
                  style: mono(13, AppColors.ink)),
            ]),
            const SizedBox(height: 6),
            Inset(
              radius: 8,
              padding: const EdgeInsets.all(3),
              child: SizedBox(
                height: 10,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: entries[i].value / maxV),
                  duration: Duration(milliseconds: 800 + i * 150),
                  curve: Curves.easeOutCubic,
                  builder: (_, f, __) => Align(
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: f.clamp(0.02, 1.0).toDouble(),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          gradient: LinearGradient(colors: [
                            entries[i].key.color.withOpacity(0.55),
                            entries[i].key.color,
                          ]),
                          boxShadow: [
                            BoxShadow(
                                color: entries[i].key.color.withOpacity(0.55),
                                blurRadius: 10)
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ]),
        ),
    ]);
  }
}

// ═══════════════════════ Combination dial (intro) ═══════════════════════
class DialRing extends StatelessWidget {
  final double size;
  final double rotation;
  final double glow;
  final bool open;
  const DialRing({
    super.key,
    required this.size,
    required this.rotation,
    required this.glow,
    required this.open,
  });

  @override
  Widget build(BuildContext context) => SizedBox(
        width: size,
        height: size,
        child: Stack(alignment: Alignment.center, children: [
          CustomPaint(
              size: Size(size, size), painter: _DialPainter(rotation, glow)),
          Icon(
            open ? Icons.lock_open_rounded : Icons.lock_rounded,
            size: size * 0.2,
            color: AppColors.goldLight,
            shadows: [
              Shadow(
                  color: AppColors.mustard.withOpacity(0.9),
                  blurRadius: 18 + 20 * glow),
            ],
          ),
        ]),
      );
}

class _DialPainter extends CustomPainter {
  final double rot;
  final double glow;
  _DialPainter(this.rot, this.glow);

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final R = size.width / 2 - 14;
    final rect = Rect.fromCircle(center: c, radius: R);

    if (glow > 0) {
      canvas.drawCircle(
          c,
          R * 1.02,
          Paint()
            ..color = AppColors.mustard.withOpacity(0.55 * glow)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 26));
    }
    canvas.drawCircle(
        c,
        R,
        Paint()
          ..color = Colors.black.withOpacity(0.8)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18));
    canvas.drawCircle(
      c,
      R,
      Paint()
        ..shader = SweepGradient(
          colors: const [
            Color(0xFF6B747A),
            Color(0xFF1B2126),
            Color(0xFFA9B2B8),
            Color(0xFF20272C),
            Color(0xFF7A848B),
            Color(0xFF6B747A),
          ],
          transform: GradientRotation(rot),
        ).createShader(rect),
    );
    canvas.drawCircle(c, R * 0.90, Paint()..color = const Color(0xFF07090B));

    for (var i = 0; i < 72; i++) {
      final a = rot + i * 2 * math.pi / 72 - math.pi / 2;
      final major = i % 6 == 0;
      final d = Offset(math.cos(a), math.sin(a));
      canvas.drawLine(
        c + d * (R * 0.86),
        c + d * (R * (0.86 - (major ? 0.10 : 0.05))),
        Paint()
          ..strokeWidth = major ? 2.2 : 1.2
          ..color = major ? AppColors.goldLight : const Color(0xFF8A97A0),
      );
    }

    final inner = Rect.fromCircle(center: c, radius: R * 0.64);
    canvas.drawCircle(
      c,
      R * 0.64,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.3, -0.4),
          colors: [Color(0xFF222A30), Color(0xFF0A0D10)],
        ).createShader(inner),
    );
    canvas.drawCircle(
      c,
      R * 0.64,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = AppColors.mustard.withOpacity(0.55 + 0.4 * glow),
    );

    // fixed index marker
    final tri = Path()
      ..moveTo(c.dx, c.dy - R + 8)
      ..lineTo(c.dx - 9, c.dy - R - 10)
      ..lineTo(c.dx + 9, c.dy - R - 10)
      ..close();
    canvas.drawPath(
        tri,
        Paint()
          ..color = AppColors.mustard.withOpacity(0.7)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));
    canvas.drawPath(tri, Paint()..color = AppColors.goldLight);
  }

  @override
  bool shouldRepaint(covariant _DialPainter old) =>
      old.rot != rot || old.glow != glow;
}
