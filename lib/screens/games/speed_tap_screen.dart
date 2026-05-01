import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import '../../providers/auth_provider.dart';
import '../../providers/profile_provider.dart';
import '../../theme/app_colors.dart';
import '../results_screen.dart';

/// Speed Tap game — tap appearing circles before they disappear.
class SpeedTapScreen extends StatefulWidget {
  const SpeedTapScreen({super.key});

  @override
  State<SpeedTapScreen> createState() => _SpeedTapScreenState();
}

class _Circle {
  final int id;
  final double x; // 0.0 to 1.0
  final double y;
  final double size;
  bool tapped = false;
  final Timer timer;

  _Circle({
    required this.id,
    required this.x,
    required this.y,
    required this.size,
    required this.timer,
  });
}

class _SpeedTapScreenState extends State<SpeedTapScreen>
    with TickerProviderStateMixin {
  final _rng = Random();
  final List<_Circle> _circles = [];
  int _score = 0;
  int _missed = 0;
  int _timeLeft = 30;
  bool _started = false;
  bool _gameOver = false;
  int _circleIdCounter = 0;
  Timer? _gameTimer;
  Timer? _spawnTimer;
  late ConfettiController _confetti;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _spawnTimer?.cancel();
    for (final c in _circles) {
      c.timer.cancel();
    }
    _confetti.dispose();
    super.dispose();
  }

  void _startGame() {
    setState(() => _started = true);
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        if (_timeLeft > 0) {
          _timeLeft--;
        } else {
          _endGame();
        }
      });
    });
    _spawnTimer = Timer.periodic(const Duration(milliseconds: 900), (_) {
      if (!mounted || _gameOver) return;
      _spawnCircle();
    });
    _spawnCircle();
  }

  void _spawnCircle() {
    final id = _circleIdCounter++;
    final size = 54.0 + _rng.nextDouble() * 28;
    final circle = _Circle(
      id: id,
      x: 0.05 + _rng.nextDouble() * 0.82,
      y: 0.12 + _rng.nextDouble() * 0.68,
      size: size,
      timer: Timer(const Duration(milliseconds: 1400), () {
        if (!mounted) return;
        setState(() {
          _circles.removeWhere((c) => c.id == id && !c.tapped);
          if (!_gameOver) _missed++;
        });
      }),
    );
    setState(() => _circles.add(circle));
  }

  void _onCircleTap(int id) {
    HapticFeedback.lightImpact();
    final circle = _circles.firstWhere((c) => c.id == id, orElse: () => throw 0);
    circle.timer.cancel();
    setState(() {
      circle.tapped = true;
      _score += 5;
    });
    Future.delayed(const Duration(milliseconds: 200), () {
      if (!mounted) return;
      setState(() => _circles.removeWhere((c) => c.id == id));
    });
  }

  void _endGame() {
    _gameTimer?.cancel();
    _spawnTimer?.cancel();
    for (final c in _circles) {
      c.timer.cancel();
    }
    _circles.clear();
    _gameOver = true;

    if (_score > 50) _confetti.play();

    final total = _score ~/ 5 + _missed;
    final accuracy = total > 0 ? ((_score ~/ 5) / total * 100).round() : 0;

    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      context.read<AuthProvider>().addScore(_score);
      context.read<ProfileProvider>().addScoreToToday(_score);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResultsScreen(
            score: _score,
            accuracy: accuracy,
            gameName: 'Speed Tap',
            won: _score >= 50,
            onRetry: () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const SpeedTapScreen()));
            },
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final timerColor = _timeLeft <= 10 ? Colors.red : AppColors.orange;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF0F1F1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF162826),
        title: const Text('Speed Tap',
            style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: timerColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(children: [
                  Icon(Icons.timer_rounded, color: timerColor, size: 16),
                  const SizedBox(width: 4),
                  Text('${_timeLeft}s',
                      style: TextStyle(
                          color: timerColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 15)),
                ]),
              ),
            ),
          ),
        ],
      ),
      body: Stack(children: [
        // Score row
        Positioned(
          top: 0, left: 0, right: 0,
          child: Container(
            color: const Color(0xFF162826),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _ScoreChip('Score', '$_score', AppColors.primary),
                _ScoreChip('Tapped', '${_score ~/ 5}', AppColors.green),
                _ScoreChip('Missed', '$_missed', Colors.red.shade300),
              ],
            ),
          ),
        ),

        // Game area — circles
        if (_started)
          ...List.generate(_circles.length, (i) {
            final c = _circles[i];
            return Positioned(
              left: c.x * (size.width - c.size),
              top: 80 + c.y * (size.height - 200 - c.size),
              child: _TapCircle(
                circle: c,
                onTap: () => _onCircleTap(c.id),
              ),
            );
          }),

        // Start overlay
        if (!_started)
          Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.orange.withOpacity(0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.orange, width: 2.5),
                ),
                child: const Icon(Icons.touch_app_rounded,
                    color: AppColors.orange, size: 48),
              ),
              const SizedBox(height: 24),
              const Text('Speed Tap!',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Text('Tap circles before they disappear',
                  style:
                      TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14)),
              const SizedBox(height: 32),
              GestureDetector(
                onTap: _startGame,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 40, vertical: 16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.orange, Color(0xFFE06020)],
                    ),
                    borderRadius: BorderRadius.circular(50),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.orange.withOpacity(0.5),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      )
                    ],
                  ),
                  child: const Text('Start!',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700)),
                ),
              ),
            ]),
          ),

        // Confetti
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confetti,
            blastDirectionality: BlastDirectionality.explosive,
            colors: const [AppColors.orange, AppColors.primary, AppColors.starGold],
            numberOfParticles: 20,
          ),
        ),
      ]),
    );
  }
}

/// An animated circle that appears then fades out.
class _TapCircle extends StatefulWidget {
  final _Circle circle;
  final VoidCallback onTap;

  const _TapCircle({required this.circle, required this.onTap});

  @override
  State<_TapCircle> createState() => _TapCircleState();
}

class _TapCircleState extends State<_TapCircle>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..forward();
    _scale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 15),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 65),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.8), weight: 20),
    ]).animate(_ctrl);
    _opacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 10),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 65),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 25),
    ]).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => GestureDetector(
        onTap: widget.onTap,
        child: Opacity(
          opacity: _opacity.value,
          child: Transform.scale(
            scale: _scale.value,
            child: Container(
              width: widget.circle.size,
              height: widget.circle.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.9),
                    AppColors.primaryDark,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.5),
                    blurRadius: 16,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Center(
                child: Icon(Icons.touch_app_rounded,
                    color: Colors.white70, size: 22),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ScoreChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _ScoreChip(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Text(value,
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.w800, color: color)),
      Text(label,
          style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.6))),
    ]);
  }
}
