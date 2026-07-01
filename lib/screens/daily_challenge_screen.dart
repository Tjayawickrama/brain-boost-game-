import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/profile_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/app_button.dart';
import 'games/memory_game_screen.dart';
import 'games/puzzle_game_screen.dart';
import 'games/speed_tap_screen.dart';

/// Daily challenge screen with date-seeded random game.
class DailyChallengeScreen extends StatefulWidget {
  const DailyChallengeScreen({super.key});

  @override
  State<DailyChallengeScreen> createState() => _DailyChallengeScreenState();
}

class _DailyChallengeScreenState extends State<DailyChallengeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().fetchDailyChallenge();
    });
  }

  void _launchGame(String gameType) {
    Widget screen;
    switch (gameType) {
      case 'puzzle':
        screen = const PuzzleGameScreen();
        break;
      case 'speed_tap':
        screen = const SpeedTapScreen();
        break;
      default:
        screen = const MemoryGameScreen();
    }
    context.read<ProfileProvider>().completeChallenge();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>();
    final challenge = profile.dailyChallenge;

    final gameIcon = {
      'memory': Icons.grid_view_rounded,
      'puzzle': Icons.extension_rounded,
      'speed_tap': Icons.touch_app_rounded,
    };
    final gameColor = {
      'memory': AppColors.primary,
      'puzzle': AppColors.purple,
      'speed_tap': AppColors.primary,
    };
    final gameType = challenge?.gameType ?? 'memory';
    final color = gameColor[gameType] ?? AppColors.primary;

    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Daily Challenge'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
      ),
      body: profile.challengeLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(children: [
                // Challenge hero
                Container(
                  width: width,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color, Color.lerp(color, Colors.black, 0.20)!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.23),
                        blurRadius: 28,
                        offset: const Offset(0, 14),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Container(
                          width: 58,
                          height: 58,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(gameIcon[gameType] ?? Icons.games,
                              color: Colors.white, size: 32),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Today’s focus',
                                  style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500)),
                              const SizedBox(height: 8),
                              Text(
                                challenge?.title ?? 'Daily Challenge',
                                style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ]),
                      const SizedBox(height: 20),
                      Text(
                        challenge?.description ?? 'Complete today’s challenge!',
                        style: TextStyle(
                            fontSize: 15,
                            color: Colors.white.withOpacity(0.92),
                            height: 1.55),
                      ),
                      const SizedBox(height: 22),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '🎯 Target: ${challenge?.targetScore ?? 0} points',
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                )
                    .animate()
                    .fadeIn(duration: 400.ms)
                    .scale(begin: const Offset(0.97, 0.97)),

                const SizedBox(height: 22),

                Row(children: [
                  Expanded(
                    child: _FrameTile(
                      color: AppColors.greenLight,
                      icon: '🧠',
                      label: 'Memory',
                      value: '8 cards',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _FrameTile(
                      color: AppColors.greenLight,
                      icon: '🧩',
                      label: 'Puzzle',
                      value: '3×3 grid',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _FrameTile(
                      color: AppColors.greenLight,
                      icon: '⚡',
                      label: 'Speed',
                      value: '30 seconds',
                    ),
                  ),
                ]).animate().fadeIn(delay: 150.ms).slideY(begin: 0.05),

                const SizedBox(height: 24),

                if (challenge?.isCompleted == true)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.greenLight,
                      borderRadius: BorderRadius.circular(18),
                      border:
                          Border.all(color: AppColors.green.withOpacity(0.35)),
                    ),
                    child: Row(children: [
                      const Icon(Icons.check_circle_rounded,
                          color: AppColors.green, size: 28),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Challenge Complete!',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.green,
                                      fontSize: 16)),
                              SizedBox(height: 4),
                              Text('Come back tomorrow for a new challenge',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textMedium)),
                            ]),
                      ),
                    ]),
                  ).animate().fadeIn(delay: 200.ms)
                else
                  AppButton(
                    label: 'Start Challenge',
                    onTap: () => _launchGame(gameType),
                    color: color,
                    prefixIcon: const Icon(Icons.play_arrow_rounded,
                        color: Colors.white, size: 22),
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),

                const SizedBox(height: 24),

                Row(children: [
                  Expanded(
                    child: _InfoCard(
                      icon: '📅',
                      title: 'Today',
                      subtitle: _todayString(),
                      color: AppColors.primaryLight,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _InfoCard(
                      icon: '⚡',
                      title: 'Reward',
                      subtitle: '+${challenge?.targetScore ?? 50} XP',
                      color: AppColors.orangeLight,
                    ),
                  ),
                ]).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),
              ]),
            ),
    );
  }

  String _todayString() {
    final now = DateTime.now();
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${now.day} ${months[now.month - 1]} ${now.year}';
  }
}

class _FrameTile extends StatelessWidget {
  final Color color;
  final String icon;
  final String label;
  final String value;

  const _FrameTile({
    required this.color,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 10),
          Text(label,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark)),
          const SizedBox(height: 6),
          Text(value,
              style: const TextStyle(fontSize: 12, color: AppColors.textMedium)),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final Color color;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(icon, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 8),
        Text(title,
            style: const TextStyle(fontSize: 12, color: AppColors.textLight)),
        Text(subtitle,
            style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark)),
      ]),
    );
  }
}
