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
      'speed_tap': AppColors.orange,
    };
    final gameType = challenge?.gameType ?? 'memory';
    final color = gameColor[gameType] ?? AppColors.primary;

    return Scaffold(
      backgroundColor: const Color(0xFFF6FAFA),
      appBar: AppBar(
        title: const Text('Daily Challenge'),
        backgroundColor: Colors.white,
      ),
      body: profile.challengeLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(children: [
                // Hero card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color, Color.lerp(color, Colors.black, 0.25)!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.35),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      )
                    ],
                  ),
                  child: Column(children: [
                    Icon(gameIcon[gameType] ?? Icons.games,
                        color: Colors.white, size: 54),
                    const SizedBox(height: 16),
                    Text(
                      challenge?.title ?? 'Daily Challenge',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      challenge?.description ?? 'Complete today\'s challenge!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.8),
                          height: 1.5),
                    ),
                    const SizedBox(height: 20),
                    // Target score badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
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
                  ]),
                )
                    .animate()
                    .fadeIn(duration: 400.ms)
                    .scale(begin: const Offset(0.95, 0.95)),

                const SizedBox(height: 28),

                // Status
                if (challenge?.isCompleted == true)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.greenLight,
                      borderRadius: BorderRadius.circular(16),
                      border:
                          Border.all(color: AppColors.green.withOpacity(0.4)),
                    ),
                    child: Row(children: [
                      const Icon(Icons.check_circle_rounded,
                          color: AppColors.green, size: 28),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Challenge Complete!',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.green,
                                      fontSize: 16)),
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

                // Info cards row
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
