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
      child: Image.asset(
        'assets/logo.png',
        width: 200,
        fit: BoxFit.contain,
      ),
    );
  }
}
