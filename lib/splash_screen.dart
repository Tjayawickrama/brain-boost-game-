import 'dart:math';
import 'package:flutter/material.dart';

// ── Bubble palette ────────────────────────────────────────────────────────────
class _BData {
  final double cx; // 0..1 of width
  final double cy; // 0..1 of height
  final double r;
  final Color color;
  const _BData(this.cx, this.cy, this.r, this.color);
}

const _kBubbles = [
  _BData(0.14, 0.02,  90,  Color(0xE600BCBC)),
  _BData(0.56, -0.01, 110, Color(0xD900D2C8)),
  _BData(0.91, 0.08,  80,  Color(0xCC20E0BC)),
  _BData(0.06, 0.19,  75,  Color(0xBB64E6D2)),
  _BData(0.84, 0.27,  95,  Color(0xCC0AA5A5)),
  _BData(0.31, 0.31, 120,  Color(0xCC009B9B)),
  _BData(0.97, 0.48, 105,  Color(0xCC3CC3B9)),
  _BData(0.09, 0.53, 100,  Color(0xBB00BCBC)),
  _BData(0.63, 0.59, 115,  Color(0xCC00D2C8)),
  _BData(0.19, 0.78, 130,  Color(0xCC00BCBC)),
  _BData(0.91, 0.81,  95,  Color(0xCC64E6D2)),
  _BData(0.53, 0.94, 110,  Color(0xCC3CC3B9)),
];

// ── Splash Screen ─────────────────────────────────────────────────────────────
class SplashScreen extends StatefulWidget {
  final VoidCallback? onFinished;
  const SplashScreen({super.key, this.onFinished});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late List<Animation<double>> _scaleIn;
  late List<Animation<double>> _exitX;
  late List<Animation<double>> _exitY;
  late List<Animation<double>> _fade;
  late Animation<double> _logoOpacity;
  late Animation<double> _logoScale;

  static const double _introEnd = 0.36;
  static const double _holdEnd  = 0.50;
  static const double _exitEnd  = 1.00;
  static const double _logoAt   = 0.72;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2900));
    _build();
    _ctrl.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onFinished?.call();
      }
    });
    _ctrl.forward();
  }

  void _build() {
    final n = _kBubbles.length;

    _scaleIn = List.generate(n, (i) {
      final s = (i / n) * (_introEnd * 0.55);
      final e = (s + _introEnd * 0.55).clamp(0.0, _introEnd);
      return Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
          parent: _ctrl, curve: Interval(s, e, curve: Curves.easeOutBack)));
    });

    final exitCurve = CurvedAnimation(
        parent: _ctrl,
        curve: Interval(_holdEnd, _exitEnd, curve: Curves.easeInCubic));

    _exitX = _kBubbles.map((b) {
      final dx = b.cx - 0.5, dy = b.cy - 0.5;
      final len = sqrt(dx * dx + dy * dy).clamp(0.01, 1.0);
      return Tween<double>(begin: 0.0, end: (dx / len) * 700).animate(exitCurve);
    }).toList();

    _exitY = _kBubbles.map((b) {
      final dx = b.cx - 0.5, dy = b.cy - 0.5;
      final len = sqrt(dx * dx + dy * dy).clamp(0.01, 1.0);
      return Tween<double>(begin: 0.0, end: (dy / len) * 1000).animate(exitCurve);
    }).toList();

    _fade = List.generate(n, (_) => Tween<double>(begin: 1.0, end: 0.0).animate(
        CurvedAnimation(
            parent: _ctrl,
            curve: Interval(_holdEnd, _exitEnd, curve: Curves.easeOut))));

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: _ctrl, curve: Interval(_logoAt, 1.0, curve: Curves.easeOut)));
    _logoScale = Tween<double>(begin: 0.55, end: 1.0).animate(CurvedAnimation(
        parent: _ctrl,
        curve: Interval(_logoAt, 1.0, curve: Curves.elasticOut)));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(builder: (ctx, box) {
        final w = box.maxWidth;
        final h = box.maxHeight;
        return Stack(fit: StackFit.expand, children: [
          // ── bubbles ──────────────────────────────────────────────────────
          AnimatedBuilder(
            animation: _ctrl,
            builder: (_, __) => Stack(fit: StackFit.expand, children:
              List.generate(_kBubbles.length, (i) {
                final b = _kBubbles[i];
                return Positioned(
                  left: b.cx * w - b.r + _exitX[i].value,
                  top:  b.cy * h - b.r + _exitY[i].value,
                  child: Opacity(
                    opacity: _fade[i].value,
                    child: Transform.scale(
                      scale: _scaleIn[i].value,
                      child: _BubbleCircle(b),
                    ),
                  ),
                );
              }),
            ),
          ),
          // ── logo ─────────────────────────────────────────────────────────
          AnimatedBuilder(
            animation: _ctrl,
            builder: (_, __) => Opacity(
              opacity: _logoOpacity.value,
              child: Transform.scale(
                scale: _logoScale.value,
                child: const _LogoWidget(),
              ),
            ),
          ),
        ]);
      }),
    );
  }
}

class _BubbleCircle extends StatelessWidget {
  final _BData data;
  const _BubbleCircle(this.data);
  @override
  Widget build(BuildContext context) {
    return Container(
      width: data.r * 2,
      height: data.r * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          center: const Alignment(-0.4, -0.4),
          radius: 0.95,
          colors: [data.color, data.color.withOpacity(0.6)],
        ),
        boxShadow: [
          BoxShadow(
              color: data.color.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(-6, -6)),
          BoxShadow(
              color: Colors.white.withOpacity(0.25),
              blurRadius: 14,
              offset: const Offset(5, 5)),
        ],
      ),
    );
  }
}

class _LogoWidget extends StatelessWidget {
  const _LogoWidget();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        SizedBox(
            width: 140, height: 154, child: CustomPaint(painter: _BulbPainter())),
        const SizedBox(height: 20),
        const Text('BRAIN BOOST',
            style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                letterSpacing: 5,
                color: Color(0xFF0A7A7A))),
        const SizedBox(height: 6),
        const Text('PLAY  ·  THINK  ·  IMPROVE',
            style: TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w400,
                letterSpacing: 3,
                color: Color(0xFF26BFBF))),
      ]),
    );
  }
}

class _BulbPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height, cx = w / 2;
    final teal = const Color(0xFF00B0B0);
    final dark = const Color(0xFF0A7A8A);
    final cyan = const Color(0xFF00C8C8);

    // Rays
    final rp = Paint()
      ..color = cyan.withOpacity(0.7)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    void ray(double ax, double ay, double bx, double by) =>
        canvas.drawLine(Offset(ax, ay), Offset(bx, by), rp);
    ray(cx, h * .02, cx, h * .10);
    ray(cx + w * .165, h * .05, cx + w * .135, h * .12);
    ray(cx + w * .275, h * .15, cx + w * .245, h * .21);
    ray(cx + w * .315, h * .29, cx + w * .275, h * .29);
    ray(cx - w * .165, h * .05, cx - w * .135, h * .12);
    ray(cx - w * .275, h * .15, cx - w * .245, h * .21);
    ray(cx - w * .315, h * .29, cx - w * .275, h * .29);

    // Bulb
    final bt = h * .12, bb = h * .70, br = w * .40;
    final bulbPath = Path()
      ..addArc(Rect.fromCenter(center: Offset(cx, bt + br), width: br * 2, height: br * 2), -pi, pi)
      ..lineTo(cx + br * .65, bb)
      ..lineTo(cx - br * .65, bb)
      ..close();
    canvas.drawPath(bulbPath, Paint()
      ..shader = LinearGradient(
              colors: [const Color(0xFFE0FAFA), const Color(0xFFA8EDEC)],
              begin: Alignment.topCenter, end: Alignment.bottomCenter)
          .createShader(Rect.fromLTWH(0, bt, w, bb - bt)));
    canvas.drawPath(bulbPath, Paint()..color = teal..style = PaintingStyle.stroke..strokeWidth = 1.8);

    // Filaments
    final fp = Paint()..color = teal..strokeWidth = 2.2..strokeCap = StrokeCap.round;
    double fy = bb;
    for (final f in [1.0, 0.84, 0.68]) {
      canvas.drawLine(Offset(cx - br * .65 * f, fy), Offset(cx + br * .65 * f, fy), fp);
      fy += h * .04;
    }

    // Circuit
    final lp = Paint()..color = dark..strokeWidth = 1.5..strokeCap = StrokeCap.round..style = PaintingStyle.stroke;
    final dp = Paint()..color = cyan;
    double nx(double f) => cx + (f - .5) * w * .75;
    double ny(double f) => bt + f * (bb - bt - h * .08);

    canvas.drawLine(Offset(cx, ny(.04)), Offset(cx, ny(.95)), lp);
    canvas.drawPath(Path()
      ..moveTo(cx, ny(.09))
      ..cubicTo(nx(.20), ny(.15), nx(.15), ny(.45), cx, ny(.50))
      ..cubicTo(nx(.15), ny(.55), nx(.20), ny(.82), cx, ny(.90)), lp);
    canvas.drawPath(Path()
      ..moveTo(cx, ny(.09))
      ..cubicTo(nx(.80), ny(.15), nx(.85), ny(.45), cx, ny(.50))
      ..cubicTo(nx(.85), ny(.55), nx(.80), ny(.82), cx, ny(.90)), lp);

    for (final pos in [[.38, .20], [.62, .20], [.30, .50], [.70, .50], [.38, .78], [.62, .78]]) {
      canvas.drawCircle(Offset(nx(pos[0]), ny(pos[1])), 3.0, dp);
    }
    canvas.drawLine(Offset(nx(.38), ny(.20)), Offset(nx(.62), ny(.20)), lp);
    canvas.drawLine(Offset(nx(.30), ny(.50)), Offset(nx(.70), ny(.50)), lp);
    canvas.drawLine(Offset(nx(.38), ny(.78)), Offset(nx(.62), ny(.78)), lp);
    canvas.drawLine(Offset(nx(.38), ny(.20)), Offset(nx(.30), ny(.50)), lp);
    canvas.drawLine(Offset(nx(.62), ny(.20)), Offset(nx(.70), ny(.50)), lp);
    canvas.drawLine(Offset(nx(.30), ny(.50)), Offset(nx(.38), ny(.78)), lp);
    canvas.drawLine(Offset(nx(.70), ny(.50)), Offset(nx(.62), ny(.78)), lp);
  }

  @override
  bool shouldRepaint(_BulbPainter _) => false;
}
