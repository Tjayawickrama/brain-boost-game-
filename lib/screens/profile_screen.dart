import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/auth_provider.dart';
import '../providers/profile_provider.dart';
import '../theme/app_colors.dart';
import '../core/constants.dart';
import '../widgets/progress_ring.dart';
import '../widgets/achievement_badge.dart';
import '../widgets/stat_bar_chart.dart';
import '../widgets/app_button.dart';
import 'auth/login_screen.dart';

/// Profile screen: avatar, level, stats chart, achievements, settings.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().fetchProfile();
    });
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
    final thresholds = AppConstants.levelThresholds;
    final lIdx = (level - 1).clamp(0, thresholds.length - 2);
    final xpProgress =
        ((total - thresholds[lIdx]) / (thresholds[lIdx + 1] - thresholds[lIdx]))
            .clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // ── Teal header with avatar ─────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: AppColors.primaryGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
              ),
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 16,
                bottom: 32,
                left: 24,
                right: 24,
              ),
              child: Column(children: [
                // Top row: title + settings
                Row(children: [
                  const Text('Profile',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.white)),
                  const Spacer(),
                  IconButton(
                    icon: Icon(
                      profile.isDarkMode
                          ? Icons.light_mode_rounded
                          : Icons.dark_mode_rounded,
                      color: Colors.white,
                    ),
                    onPressed: () => profile.toggleDarkMode(),
                  ),
                ]),
                const SizedBox(height: 20),
                // Avatar
                Stack(children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: profile.profileImage != null
                        ? ClipOval(
                            child: Image.file(
                              profile.profileImage!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Center(
                            child: Text(
                              (user?.name ?? 'P').substring(0, 1).toUpperCase(),
                              style: const TextStyle(
                                  fontSize: 38,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white),
                            ),
                          ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () => profile.pickProfileImage(),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.starGold,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(Icons.camera_alt_rounded,
                            color: Colors.white, size: 16),
                      ),
                    ),
                  ),
                ]),
                const SizedBox(height: 12),
                Text(user?.name ?? 'Player',
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
                const SizedBox(height: 2),
                Text(user?.email ?? '',
                    style: TextStyle(
                        fontSize: 13, color: Colors.white.withOpacity(0.7))),
                const SizedBox(height: 16),
                // Level badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('⚡ $levelName  ·  Level $level',
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white)),
                ),
              ]),
            ).animate().fadeIn(duration: 500.ms),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ── XP Progress card ──────────────────────────────────────
                _SectionCard(
                  child: Row(children: [
                    ProgressRing(
                      value: xpProgress,
                      size: 80,
                      strokeWidth: 9,
                      child: Text(
                        '${(xpProgress * 100).toInt()}%',
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Level Progress',
                                style: TextStyle(
                                    fontSize: 13, color: AppColors.textLight)),
                            Text(levelName,
                                style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textDark)),
                            const SizedBox(height: 6),
                            Text(
                              '$total / ${thresholds[(lIdx + 1).clamp(0, thresholds.length - 1)]} XP',
                              style: const TextStyle(
                                  fontSize: 12, color: AppColors.textMedium),
                            ),
                          ]),
                    ),
                  ]),
                ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),

                const SizedBox(height: 16),

                // ── Stats row ─────────────────────────────────────────────
                Row(children: [
                  Expanded(child: _MiniStat('Games', '${user?.gamesPlayed ?? 0}', '🎮')),
                  const SizedBox(width: 12),
                  Expanded(child: _MiniStat('Score', '$total', '⭐')),
                  const SizedBox(width: 12),
                  Expanded(child: _MiniStat('Streak', '${user?.streak ?? 0}d', '🔥')),
                ]).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),

                const SizedBox(height: 20),

                // ── Weekly chart ──────────────────────────────────────────
                _SectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Weekly Performance',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark)),
                      const SizedBox(height: 4),
                      const Text('Your scores this week',
                          style: TextStyle(
                              fontSize: 12, color: AppColors.textLight)),
                      const SizedBox(height: 16),
                      profile.isLoading
                          ? const SizedBox(
                              height: 120,
                              child: Center(child: CircularProgressIndicator()))
                          : SizedBox(
                              height: 120,
                              child: StatBarChart(data: profile.weeklyScores),
                            ),
                    ],
                  ),
                ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),

                const SizedBox(height: 20),

                // ── Achievements ──────────────────────────────────────────
                _SectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Achievements',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark)),
                      const SizedBox(height: 4),
                      const Text('Unlock badges by playing games',
                          style: TextStyle(
                              fontSize: 12, color: AppColors.textLight)),
                      const SizedBox(height: 20),
                      profile.achievements.isEmpty
                          ? const Center(
                              child: CircularProgressIndicator(strokeWidth: 2))
                          : GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                mainAxisSpacing: 16,
                                crossAxisSpacing: 16,
                                childAspectRatio: 0.85,
                              ),
                              itemCount: profile.achievements.length,
                              itemBuilder: (_, i) {
                                final a = profile.achievements[i];
                                return AchievementBadge(
                                  icon: a['icon'] as String,
                                  label: a['title'] as String,
                                  unlocked: a['unlocked'] as bool,
                                );
                              },
                            ),
                    ],
                  ),
                ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),

                const SizedBox(height: 20),

                // ── Logout ─────────────────────────────────────────────────
                AppButton(
                  label: 'Sign Out',
                  isOutlined: true,
                  color: Colors.red.shade400,
                  prefixIcon: Icon(Icons.logout_rounded,
                      color: Colors.red.shade400, size: 18),
                  onTap: () async {
                    await auth.logout();
                    if (context.mounted) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (_) => false,
                      );
                    }
                  },
                ).animate().fadeIn(delay: 500.ms),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final Widget child;
  const _SectionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: child,
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final String icon;
  const _MiniStat(this.label, this.value, this.icon);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12)
        ],
      ),
      child: Column(children: [
        Text(icon, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textDark)),
        Text(label,
            style: const TextStyle(fontSize: 10, color: AppColors.textLight)),
      ]),
    );
  }
}
