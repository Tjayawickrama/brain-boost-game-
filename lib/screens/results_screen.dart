import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confetti/confetti.dart';
import '../theme/app_colors.dart';
import '../widgets/app_button.dart';
import '../widgets/star_rating.dart';

/// Displayed after every game session showing score, stars, and actions.
class ResultsScreen extends StatefulWidget {
  final int score;
  final int accuracy; // 0-100
  final String gameName;
  final bool won;
  final VoidCallback onRetry;

  const ResultsScreen({
    super.key,
    required this.score,
    required this.accuracy,
    required this.gameName,
    required this.won,
    required this.onRetry,
  });

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<int> _scoreAnim;
  late ConfettiController _confetti;

  int get _stars {
    if (widget.accuracy >= 90) return 3;
    if (widget.accuracy >= 60) return 2;
    return 1;
  }

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _scoreAnim = IntTween(begin: 0, end: widget.score).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic),
    );
    _confetti = ConfettiController(duration: const Duration(seconds: 3));
    _ctrl.forward();
    if (widget.won && _stars == 3) {
      Future.delayed(const Duration(milliseconds: 400), _confetti.play);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6FAFA),
      body: Stack(children: [
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),

                // Result icon
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.elasticOut,
                  builder: (_, v, child) =>
                      Transform.scale(scale: v, child: child),
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: widget.won
                            ? AppColors.primaryGradient
                            : [Colors.orange.shade300, Colors.orange.shade600],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (widget.won ? AppColors.primary : Colors.orange)
                              .withOpacity(0.4),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        )
                      ],
                    ),
                    child: Icon(
                      widget.won
                          ? Icons.emoji_events_rounded
                          : Icons.sentiment_neutral_rounded,
                      color: Colors.white,
                      size: 50,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Text(widget.won ? '🎉 Excellent!' : 'Keep Practicing!',
                    style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark))
                    .animate().fadeIn(delay: 200.ms),

                const SizedBox(height: 4),

                Text(widget.gameName,
                    style: const TextStyle(
                        fontSize: 14, color: AppColors.textLight))
                    .animate().fadeIn(delay: 300.ms),

                const SizedBox(height: 28),

                // Stars
                StarRating(stars: _stars),

                const SizedBox(height: 28),

                // Score counter
                AnimatedBuilder(
                  animation: _scoreAnim,
                  builder: (_, __) => Text(
                    '${_scoreAnim.value}',
                    style: const TextStyle(
                      fontSize: 64,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary,
                      height: 1,
                    ),
                  ),
                ).animate().fadeIn(delay: 100.ms),

                const Text('points',
                    style: TextStyle(
                        fontSize: 14, color: AppColors.textLight)),

                const SizedBox(height: 28),

                // Stats row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _StatBox(label: 'Accuracy',
                        value: '${widget.accuracy}%',
                        color: AppColors.primary),
                    Container(
                        width: 1, height: 40, color: AppColors.divider),
                    _StatBox(label: 'Stars',
                        value: '$_stars / 3',
                        color: AppColors.starGold),
                  ],
                ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),

                const SizedBox(height: 36),

                // Buttons
                AppButton(
                  label: 'Play Again',
                  onTap: widget.onRetry,
                  prefixIcon: const Icon(Icons.replay_rounded,
                      color: Colors.white, size: 18),
                ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1),

                const SizedBox(height: 12),

                AppButton(
                  label: 'Back to Home',
                  isOutlined: true,
                  onTap: () =>
                      Navigator.of(context).popUntil((r) => r.isFirst),
                  prefixIcon: const Icon(Icons.home_rounded,
                      color: AppColors.primary, size: 18),
                ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.1),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),

        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confetti,
            blastDirectionality: BlastDirectionality.explosive,
            colors: const [
              AppColors.primary, AppColors.starGold,
              AppColors.orange, AppColors.purple,
            ],
            numberOfParticles: 40,
          ),
        ),
      ]),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatBox({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Text(value,
          style: TextStyle(
              fontSize: 24, fontWeight: FontWeight.w800, color: color)),
      const SizedBox(height: 2),
      Text(label,
          style: const TextStyle(fontSize: 12, color: AppColors.textLight)),
    ]);
  }
}
