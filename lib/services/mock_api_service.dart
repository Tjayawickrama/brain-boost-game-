import 'dart:math';
import '../models/user_model.dart';
import '../models/challenge_model.dart';
import '../models/leaderboard_model.dart';
import '../core/constants.dart';

/// Mock API service that simulates network calls with realistic delays.
/// In production, replace these with real Dio HTTP calls.
class MockApiService {
  final _rand = Random();

  Future<void> _delay([int ms = 600]) =>
      Future.delayed(Duration(milliseconds: ms));

  // ── Auth ─────────────────────────────────────────────────────────────────

  /// Simulates user login. Returns user data or throws on bad credentials.
  Future<Map<String, dynamic>> loginUser(String email, String password) async {
    await _delay();
    if (email.trim().toLowerCase() == AppConstants.demoEmail &&
        password == AppConstants.demoPassword) {
      return {
        'token': 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
        'user': _mockUser(email: email).toJson(),
      };
    }
    // Also accept any registered user pattern
    if (email.contains('@') && password.length >= 6) {
      return {
        'token': 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
        'user': _mockUser(email: email, name: email.split('@').first).toJson(),
      };
    }
    throw Exception('Invalid email or password.');
  }

  /// Simulates user registration.
  Future<Map<String, dynamic>> registerUser(
      String name, String email, String password) async {
    await _delay(800);
    if (email.contains('@') && password.length >= 6) {
      return {
        'token': 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
        'user': _mockUser(name: name, email: email).toJson(),
      };
    }
    throw Exception('Registration failed. Please check your details.');
  }

  // ── Profile ───────────────────────────────────────────────────────────────

  /// Returns full user profile data.
  Future<Map<String, dynamic>> getUserProfile(String userId) async {
    await _delay(400);
    return {
      'user': _mockUser().toJson(),
      'weeklyScores': _generateWeeklyScores(),
      'achievements': _generateAchievements(),
    };
  }

  // ── Daily challenge ───────────────────────────────────────────────────────

  /// Returns today's challenge (seeded by date so it's stable all day).
  Future<ChallengeModel> getDailyChallenge() async {
    await _delay(300);
    final today = DateTime.now();
    final seed = today.year * 10000 + today.month * 100 + today.day;
    final rng = Random(seed);
    final types = ['memory', 'puzzle', 'speed_tap'];
    final titles = [
      'Memory Master Challenge',
      'Puzzle Sprint Challenge',
      'Speed Demon Challenge',
    ];
    final descs = [
      'Match all pairs in under 45 seconds!',
      'Solve the sliding puzzle with fewer than 30 moves!',
      'Tap 20 circles in 30 seconds!',
    ];
    final targets = [80, 70, 100];
    final idx = rng.nextInt(3);

    return ChallengeModel(
      id: 'daily_${today.toIso8601String().substring(0, 10)}',
      title: titles[idx],
      description: descs[idx],
      gameType: types[idx],
      targetScore: targets[idx],
      date: today,
    );
  }

  // ── Score saving ──────────────────────────────────────────────────────────

  /// Saves game score and returns updated total.
  Future<Map<String, dynamic>> saveGameScore(
      String gameId, int score, int accuracy) async {
    await _delay(400);
    return {
      'success': true,
      'pointsEarned': score,
      'message': score > 50 ? 'Amazing performance!' : 'Keep practicing!',
    };
  }

  // ── Leaderboard ───────────────────────────────────────────────────────────

  /// Returns top 10 leaderboard entries.
  Future<List<LeaderboardEntry>> getLeaderboard(String currentUserId) async {
    await _delay(500);
    final names = [
      'Alex Chen', 'Maya Patel', 'Jordan Kim', 'Sam Rivera',
      'Taylor Wong', 'Chris Lee', 'Priya Sharma', 'Diego Ruiz',
      'Emma Davis', 'You',
    ];
    final scores = [3240, 2980, 2750, 2600, 2420, 2100, 1980, 1750, 1520, 1350];

    return List.generate(10, (i) => LeaderboardEntry(
          rank: i + 1,
          userId: i == 9 ? currentUserId : 'user_$i',
          name: names[i],
          totalScore: scores[i],
          level: (scores[i] / 300).floor() + 1,
          isCurrentUser: i == 9,
        ));
  }

  // ── Statistics ────────────────────────────────────────────────────────────

  /// Returns weekly stats data.
  Future<Map<String, dynamic>> getStatistics(String userId) async {
    await _delay(400);
    return {
      'weeklyScores': _generateWeeklyScores(),
      'totalGames': 47,
      'averageAccuracy': 72,
      'bestStreak': 7,
      'favoriteGame': 'Memory Match',
    };
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  UserModel _mockUser({String? name, String? email}) => UserModel(
        id: 'user_001',
        name: name ?? 'Brain Master',
        email: email ?? AppConstants.demoEmail,
        totalScore: 1350,
        level: 5,
        gamesPlayed: 47,
        streak: 3,
      );

  List<Map<String, dynamic>> _generateWeeklyScores() {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return List.generate(7, (i) => {
          'day': days[i],
          'score': 20 + _rand.nextInt(80),
        });
  }

  List<Map<String, dynamic>> _generateAchievements() => [
        {'id': 'first_win', 'title': 'First Win', 'icon': '🏆', 'unlocked': true},
        {'id': 'ten_games', 'title': '10 Games', 'icon': '🎮', 'unlocked': true},
        {'id': 'speed_demon', 'title': 'Speed Demon', 'icon': '⚡', 'unlocked': true},
        {'id': 'perfect_score', 'title': 'Perfect Score', 'icon': '⭐', 'unlocked': false},
        {'id': 'fifty_games', 'title': '50 Games', 'icon': '🎯', 'unlocked': false},
        {'id': 'puzzle_master', 'title': 'Puzzle Master', 'icon': '🧩', 'unlocked': false},
      ];
}
