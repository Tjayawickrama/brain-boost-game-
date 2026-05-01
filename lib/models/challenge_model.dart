/// Model for the daily brain challenge.
class ChallengeModel {
  final String id;
  final String title;
  final String description;
  final String gameType; // 'memory' | 'puzzle' | 'speed_tap'
  final int targetScore;
  final bool isCompleted;
  final DateTime date;

  const ChallengeModel({
    required this.id,
    required this.title,
    required this.description,
    required this.gameType,
    required this.targetScore,
    this.isCompleted = false,
    required this.date,
  });

  factory ChallengeModel.fromJson(Map<String, dynamic> json) => ChallengeModel(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        gameType: json['gameType'] as String,
        targetScore: (json['targetScore'] as num).toInt(),
        isCompleted: json['isCompleted'] as bool? ?? false,
        date: DateTime.parse(json['date'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'gameType': gameType,
        'targetScore': targetScore,
        'isCompleted': isCompleted,
        'date': date.toIso8601String(),
      };

  ChallengeModel copyWith({bool? isCompleted}) => ChallengeModel(
        id: id,
        title: title,
        description: description,
        gameType: gameType,
        targetScore: targetScore,
        isCompleted: isCompleted ?? this.isCompleted,
        date: date,
      );
}
