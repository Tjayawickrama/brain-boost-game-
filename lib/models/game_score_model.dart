/// Model representing a single game session score.
class GameScoreModel {
  final String gameId;
  final String gameName;
  final int score;
  final int accuracy; // 0-100
  final int durationSeconds;
  final DateTime playedAt;

  const GameScoreModel({
    required this.gameId,
    required this.gameName,
    required this.score,
    required this.accuracy,
    required this.durationSeconds,
    required this.playedAt,
  });

  factory GameScoreModel.fromJson(Map<String, dynamic> json) => GameScoreModel(
        gameId: json['gameId'] as String,
        gameName: json['gameName'] as String,
        score: (json['score'] as num).toInt(),
        accuracy: (json['accuracy'] as num).toInt(),
        durationSeconds: (json['durationSeconds'] as num).toInt(),
        playedAt: DateTime.parse(json['playedAt'] as String),
      );

  Map<String, dynamic> toJson() => {
        'gameId': gameId,
        'gameName': gameName,
        'score': score,
        'accuracy': accuracy,
        'durationSeconds': durationSeconds,
        'playedAt': playedAt.toIso8601String(),
      };

  /// Calculate star rating: 3=perfect, 2=good, 1=ok
  int get stars {
    if (accuracy >= 90) return 3;
    if (accuracy >= 60) return 2;
    return 1;
  }
}
