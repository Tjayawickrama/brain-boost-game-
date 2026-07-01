import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/auth_provider.dart';
import '../providers/profile_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/app_card.dart';
import '../widgets/game_tile.dart';
import '../core/constants.dart';
import 'games/memory_game_screen.dart';
import 'games/puzzle_game_screen.dart';
import 'games/speed_tap_screen.dart';
import 'daily_challenge_screen.dart';
import 'leaderboard_screen.dart';

/// Main home screen following the Figma design.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch daily challenge on load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().fetchDailyChallenge();
    });
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final profile = context.watch<ProfileProvider>();
    final user = auth.user;
    final total = user?.totalScore ?? 0;
    final level = user?.level ?? 1;
    final levelName = AppConstants.levelNames[
        (level - 1).clamp(0, AppConstants.levelNames.length - 1)];

    // XP progress within current level
    final thresholds = AppConstants.levelThresholds;
    final levelIdx = (level - 1).clamp(0, thresholds.length - 2);
    final levelMin = thresholds[levelIdx];
    final levelMax = thresholds[(levelIdx + 1).clamp(0, thresholds.length - 1)];
    final xpProgress =
        ((total - levelMin) / (levelMax - levelMin)).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // ── App bar ──────────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 0,
            floating: true,
            pinned: false,
            backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
            elevation: 0,
            automaticallyImplyLeading: false,
            flexibleSpace: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20)
                  .copyWith(top: MediaQuery.of(context).padding.top + 8),
              child: Row(children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('${_greeting()},',
                          style: const TextStyle(
                              fontSize: 13, color: AppColors.textLight)),
                      Text(user?.name ?? 'Player',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark,
                          )),
                    ],
                  ),
                ),
                // Notifications bell
                IconButton(
                  icon: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Icon(Icons.notifications_outlined,
                          color: AppColors.textDark, size: 26),
                      Positioned(
                        right: -2, top: -2,
                        child: Container(
                          width: 8, height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.orange,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                  onPressed: () {},
                ),
              ]),
            ),
            toolbarHeight: 70,
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ── Welcome / XP card ─────────────────────────────────────
                _WelcomeCard(
                  name: user?.name ?? 'Player',
                  levelName: levelName,
                  level: level,
                  totalScore: total,
                  xpProgress: xpProgress,
                  streak: user?.streak ?? 0,
                ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1),

                const SizedBox(height: 24),

                // ── Daily challenge card ──────────────────────────────────
                _DailyChallengeCard(
                  challenge: profile.dailyChallenge,
                  isLoading: profile.challengeLoading,
                ).animate().fadeIn(duration: 400.ms, delay: 100.ms).slideY(begin: 0.1),

                const SizedBox(height: 24),

                // ── Games section ────────────────────────────────────────
                const _SectionHeader(title: 'Games', subtitle: 'Pick a challenge'),
                const SizedBox(height: 14),

                GameTile(
                  title: 'Memory Match',
                  subtitle: 'Train your visual memory',
                  icon: Icons.grid_view_rounded,
                  color: AppColors.primary,
                  badge: 'POPULAR',
                  onTap: () => Navigator.push(context,
                      _slideRoute(const MemoryGameScreen())),
                ).animate().fadeIn(duration: 400.ms, delay: 200.ms).slideX(begin: 0.1),

                const SizedBox(height: 12),

                GameTile(
                  title: 'Sliding Puzzle',
                  subtitle: 'Solve puzzles under pressure',
                  icon: Icons.extension_rounded,
                  color: AppColors.purple,
                  onTap: () => Navigator.push(context,
                      _slideRoute(const PuzzleGameScreen())),
                ).animate().fadeIn(duration: 400.ms, delay: 300.ms).slideX(begin: 0.1),

                const SizedBox(height: 12),

                GameTile(
                  title: 'Speed Tap',
                  subtitle: 'Test your reaction time',
                  icon: Icons.touch_app_rounded,
                  color: AppColors.orange,
                  badge: 'NEW',
                  onTap: () => Navigator.push(context,
                      _slideRoute(const SpeedTapScreen())),
                ).animate().fadeIn(duration: 400.ms, delay: 400.ms).slideX(begin: 0.1),

                const SizedBox(height: 24),

                // ── Stats row ─────────────────────────────────────────────
                _StatsRow(
                  gamesPlayed: user?.gamesPlayed ?? 0,
                  totalScore: total,
                  level: level,
                ).animate().fadeIn(duration: 400.ms, delay: 500.ms).slideY(begin: 0.1),

                const SizedBox(height: 24),

                // ── Leaderboard teaser ───────────────────────────────────
                AppCard(
                  gradientColors: AppColors.darkGradient,
                  onTap: () => Navigator.push(context,
                      _slideRoute(const LeaderboardScreen())),
                  child: Row(children: [
                    const Icon(Icons.emoji_events_rounded,
                        color: Colors.amber, size: 36),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Leaderboard',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              )),
                          SizedBox(height: 2),
                          Text('See how you rank globally',
                              style: TextStyle(
                                  fontSize: 12, color: Colors.white70)),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded,
                        color: Colors.white54, size: 16),
                  ]),
                ).animate().fadeIn(duration: 400.ms, delay: 600.ms).slideY(begin: 0.1),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  PageRoute _slideRoute(Widget page) => PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionDuration: const Duration(milliseconds: 350),
        transitionsBuilder: (_, anim, __, child) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
          child: child,
        ),
      );
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _WelcomeCard extends StatelessWidget {
  final String name;
  final String levelName;
  final int level;
  final int totalScore;
  final double xpProgress;
  final int streak;

  const _WelcomeCard({
    required this.name,
    required this.levelName,
    required this.level,
    required this.totalScore,
    required this.xpProgress,
    required this.streak,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      gradientColors: AppColors.primaryGradient,
      padding: const EdgeInsets.all(22),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('⚡ $levelName  Lv.$level',
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
              ),
            ]),
            const SizedBox(height: 12),
            Text('$totalScore XP',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                )),
            const SizedBox(height: 4),
            Text('Total score', style: TextStyle(
                color: Colors.white.withOpacity(0.75), fontSize: 12)),
            const SizedBox(height: 16),
            // XP progress bar
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('XP Progress',
                    style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withOpacity(0.8),
                        fontWeight: FontWeight.w500)),
                Text('${(xpProgress * 100).toInt()}%',
                    style: const TextStyle(
                        fontSize: 11,
                        color: Colors.white,
                        fontWeight: FontWeight.w700)),
              ]),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: xpProgress,
                  backgroundColor: Colors.white.withOpacity(0.25),
                  color: Colors.white,
                  minHeight: 7,
                ),
              ),
            ]),
          ]),
        ),
        const SizedBox(width: 16),
        Column(children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Text('🔥', style: TextStyle(fontSize: 22)),
              Text('$streak', style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
            ]),
          ),
          const SizedBox(height: 4),
          const Text('streak', style: TextStyle(fontSize: 10, color: Colors.white70)),
        ]),
      ]),
    );
  }
}

class _DailyChallengeCard extends StatelessWidget {
  final dynamic challenge;
  final bool isLoading;

  const _DailyChallengeCard({this.challenge, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      color: AppColors.orangeLight,
      padding: const EdgeInsets.all(20),
      child: Row(children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: AppColors.orange.withOpacity(0.15),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.emoji_events_outlined,
              color: AppColors.orange, size: 28),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: isLoading
              ? const Text('Loading today\'s challenge...',
                  style: TextStyle(color: AppColors.textLight, fontSize: 13))
              : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(challenge?.title ?? 'Daily Challenge',
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark)),
                  const SizedBox(height: 2),
                  Text(challenge?.description ?? 'Complete today\'s brain workout!',
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textMedium)),
                ]),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const DailyChallengeScreen()),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.orange,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: AppColors.orange.withOpacity(0.35),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: const Text('Play',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13)),
          ),
        ),
      ]),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title,
            style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark)),
        Text(subtitle,
            style: const TextStyle(fontSize: 12, color: AppColors.textLight)),
      ]),
    ]);
  }
}

class _StatsRow extends StatelessWidget {
  final int gamesPlayed;
  final int totalScore;
  final int level;

  const _StatsRow({
    required this.gamesPlayed,
    required this.totalScore,
    required this.level,
  });

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(child: _StatItem(label: 'Games', value: '$gamesPlayed', icon: '🎮')),
      const SizedBox(width: 12),
      Expanded(child: _StatItem(label: 'Score', value: '$totalScore', icon: '⭐')),
      const SizedBox(width: 12),
      Expanded(child: _StatItem(label: 'Level', value: '$level', icon: '🏆')),
    ]);
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final String icon;

  const _StatItem({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(children: [
        Text(icon, style: const TextStyle(fontSize: 22)),
        const SizedBox(height: 6),
        Text(value,
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark)),
        Text(label,
            style: const TextStyle(fontSize: 11, color: AppColors.textLight)),
      ]),
    );
  }
}
