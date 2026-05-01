import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/profile_provider.dart';
import '../models/leaderboard_model.dart';
import '../theme/app_colors.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});
  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().fetchLeaderboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>();
    final board = profile.leaderboard;

    return Scaffold(
      backgroundColor: const Color(0xFFF6FAFA),
      appBar: AppBar(title: const Text('Leaderboard'), backgroundColor: Colors.white),
      body: profile.isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(slivers: [
              if (board.length >= 3)
                SliverToBoxAdapter(
                  child: _Podium(first: board[0], second: board[1], third: board[2])
                      .animate().fadeIn(duration: 500.ms),
                ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 80),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) {
                      final e = board[i + 3];
                      return _LeaderRow(entry: e)
                          .animate().fadeIn(delay: (i * 50).ms).slideX(begin: 0.05);
                    },
                    childCount: (board.length - 3).clamp(0, 100),
                  ),
                ),
              ),
            ]),
    );
  }
}

class _Podium extends StatelessWidget {
  final LeaderboardEntry first, second, third;
  const _Podium({required this.first, required this.second, required this.third});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: AppColors.primaryGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Column(children: [
        const Text('🏆  Top Players',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(height: 28),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _Pillar(entry: second, h: 80, medal: '🥈', rank: 2),
            const SizedBox(width: 10),
            _Pillar(entry: first, h: 110, medal: '🥇', rank: 1),
            const SizedBox(width: 10),
            _Pillar(entry: third, h: 60, medal: '🥉', rank: 3),
          ],
        ),
      ]),
    );
  }
}

class _Pillar extends StatelessWidget {
  final LeaderboardEntry entry;
  final double h;
  final String medal;
  final int rank;
  const _Pillar({required this.entry, required this.h, required this.medal, required this.rank});

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Text(medal, style: const TextStyle(fontSize: 24)),
      const SizedBox(height: 4),
      Container(
        width: 52, height: 52,
        decoration: BoxDecoration(
          color: Colors.white, shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.6), width: 2),
        ),
        child: Center(
          child: Text(entry.name.substring(0, 1).toUpperCase(),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.primaryDark)),
        ),
      ),
      const SizedBox(height: 6),
      Text(entry.name.split(' ').first,
          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
      Text('${entry.totalScore} pts',
          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 11)),
      const SizedBox(height: 6),
      Container(
        width: 80, height: h,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
        ),
        child: Center(
          child: Text('#$rank',
              style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 20, fontWeight: FontWeight.w800)),
        ),
      ),
    ]);
  }
}

class _LeaderRow extends StatelessWidget {
  final LeaderboardEntry entry;
  const _LeaderRow({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: entry.isCurrentUser ? AppColors.primaryLight : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: entry.isCurrentUser ? Border.all(color: AppColors.primary, width: 1.5) : null,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
      ),
      child: Row(children: [
        SizedBox(
          width: 36,
          child: Text('#${entry.rank}',
              style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w700,
                  color: entry.isCurrentUser ? AppColors.primary : AppColors.textLight)),
        ),
        Container(
          width: 40, height: 40,
          decoration: const BoxDecoration(color: AppColors.primaryLight, shape: BoxShape.circle),
          child: Center(
            child: Text(entry.name.substring(0, 1).toUpperCase(),
                style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary, fontSize: 16)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(entry.isCurrentUser ? '${entry.name} (You)' : entry.name,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: entry.isCurrentUser ? FontWeight.w700 : FontWeight.w500,
                  color: AppColors.textDark)),
        ),
        Text('${entry.totalScore}',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.primary)),
        const Text(' pts', style: TextStyle(fontSize: 11, color: AppColors.textLight)),
      ]),
    );
  }
}
