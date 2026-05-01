/// Model for a single leaderboard entry.
class LeaderboardEntry {
  final int rank;
  final String userId;
  final String name;
  final int totalScore;
  final int level;
  final String avatarUrl;
  final bool isCurrentUser;

  const LeaderboardEntry({
    required this.rank,
    required this.userId,
    required this.name,
    required this.totalScore,
    required this.level,
    this.avatarUrl = '',
    this.isCurrentUser = false,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) =>
      LeaderboardEntry(
        rank: (json['rank'] as num).toInt(),
        userId: json['userId'] as String,
        name: json['name'] as String,
        totalScore: (json['totalScore'] as num).toInt(),
        level: (json['level'] as num).toInt(),
        avatarUrl: json['avatarUrl'] as String? ?? '',
        isCurrentUser: json['isCurrentUser'] as bool? ?? false,
      );
}
