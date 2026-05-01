/// App-wide constants for Brain Boost.
class AppConstants {
  AppConstants._();

  // App info
  static const String appName = 'Brain Boost';
  static const String appTagline = 'Play · Think · Improve';

  // Dummy credentials for demo
  static const String demoEmail = 'test@brain.com';
  static const String demoPassword = 'password123';

  // SharedPreferences keys
  static const String keyIsLoggedIn = 'is_logged_in';
  static const String keyUserName = 'user_name';
  static const String keyUserEmail = 'user_email';
  static const String keyTotalScore = 'total_score';
  static const String keyLevel = 'user_level';
  static const String keyGamesPlayed = 'games_played';
  static const String keyLastChallenge = 'last_challenge_date';
  static const String keyDarkMode = 'dark_mode';

  // Game config
  static const int memoryGameTime = 60; // seconds
  static const int speedTapTime = 30;   // seconds
  static const int pointsPerMatch = 10;
  static const int pointsPerTap = 5;

  // Level thresholds
  static const List<int> levelThresholds = [0, 100, 300, 600, 1000, 1500, 2200, 3000];
  static const List<String> levelNames = [
    'Novice', 'Apprentice', 'Thinker', 'Scholar',
    'Expert', 'Master', 'Genius', 'Legend'
  ];
}
