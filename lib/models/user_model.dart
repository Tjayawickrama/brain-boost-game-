/// User model for Brain Boost app.
class UserModel {
  final String id;
  final String name;
  final String email;
  final int totalScore;
  final int level;
  final int gamesPlayed;
  final int streak;
  final String avatarUrl;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.totalScore = 0,
    this.level = 1,
    this.gamesPlayed = 0,
    this.streak = 0,
    this.avatarUrl = '',
  });

  /// Creates a UserModel from a JSON map.
  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as String,
        name: json['name'] as String,
        email: json['email'] as String,
        totalScore: (json['totalScore'] as num?)?.toInt() ?? 0,
        level: (json['level'] as num?)?.toInt() ?? 1,
        gamesPlayed: (json['gamesPlayed'] as num?)?.toInt() ?? 0,
        streak: (json['streak'] as num?)?.toInt() ?? 0,
        avatarUrl: json['avatarUrl'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'totalScore': totalScore,
        'level': level,
        'gamesPlayed': gamesPlayed,
        'streak': streak,
        'avatarUrl': avatarUrl,
      };

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    int? totalScore,
    int? level,
    int? gamesPlayed,
    int? streak,
    String? avatarUrl,
  }) =>
      UserModel(
        id: id ?? this.id,
        name: name ?? this.name,
        email: email ?? this.email,
        totalScore: totalScore ?? this.totalScore,
        level: level ?? this.level,
        gamesPlayed: gamesPlayed ?? this.gamesPlayed,
        streak: streak ?? this.streak,
        avatarUrl: avatarUrl ?? this.avatarUrl,
      );
}
