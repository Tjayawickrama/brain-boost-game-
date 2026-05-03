import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants.dart';

/// Wrapper around SharedPreferences for typed read/write operations.
class StorageService {
  SharedPreferences? _prefs;

  /// Must be called before using any storage methods.
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  SharedPreferences get _p {
    assert(_prefs != null, 'StorageService not initialized. Call init() first.');
    return _prefs!;
  }

  // ── Auth ─────────────────────────────────────────────────────────────────
  bool get isLoggedIn => _p.getBool(AppConstants.keyIsLoggedIn) ?? false;
  Future<void> setLoggedIn(bool v) => _p.setBool(AppConstants.keyIsLoggedIn, v);

  String get userName => _p.getString(AppConstants.keyUserName) ?? 'Player';
  Future<void> setUserName(String v) => _p.setString(AppConstants.keyUserName, v);

  String get userEmail => _p.getString(AppConstants.keyUserEmail) ?? '';
  Future<void> setUserEmail(String v) => _p.setString(AppConstants.keyUserEmail, v);

  // ── Game stats ────────────────────────────────────────────────────────────
  int get totalScore => _p.getInt(AppConstants.keyTotalScore) ?? 0;
  Future<void> addScore(int points) =>
      _p.setInt(AppConstants.keyTotalScore, totalScore + points);

  int get level => _p.getInt(AppConstants.keyLevel) ?? 1;
  Future<void> setLevel(int v) => _p.setInt(AppConstants.keyLevel, v);

  int get gamesPlayed => _p.getInt(AppConstants.keyGamesPlayed) ?? 0;
  Future<void> incrementGamesPlayed() =>
      _p.setInt(AppConstants.keyGamesPlayed, gamesPlayed + 1);

  // ── Daily challenge ───────────────────────────────────────────────────────
  String get lastChallengeDate =>
      _p.getString(AppConstants.keyLastChallenge) ?? '';
  Future<void> setLastChallengeDate(String date) =>
      _p.setString(AppConstants.keyLastChallenge, date);

  // ── Dark mode ─────────────────────────────────────────────────────────────
  bool get isDarkMode => _p.getBool(AppConstants.keyDarkMode) ?? false;
  Future<void> setDarkMode(bool v) => _p.setBool(AppConstants.keyDarkMode, v);

  // ── Remember me ───────────────────────────────────────────────────────────
  bool get isRememberEnabled => _p.getBool(AppConstants.keyRememberEnabled) ?? false;
  String get rememberEmail => _p.getString(AppConstants.keyRememberEmail) ?? '';
  String get rememberPassword => _p.getString(AppConstants.keyRememberPassword) ?? '';
  
  Future<void> setRememberMe(bool enabled, String email, String password) async {
    await _p.setBool(AppConstants.keyRememberEnabled, enabled);
    if (enabled) {
      await _p.setString(AppConstants.keyRememberEmail, email);
      await _p.setString(AppConstants.keyRememberPassword, password);
    } else {
      await _p.remove(AppConstants.keyRememberEmail);
      await _p.remove(AppConstants.keyRememberPassword);
    }
  }

  // ── Wipe all data (logout) ────────────────────────────────────────────────
  Future<void> clear() => _p.clear();
}
