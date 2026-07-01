import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/leaderboard_model.dart';
import '../models/challenge_model.dart';
import '../services/mock_api_service.dart';
import '../services/storage_service.dart';

/// Manages profile data, leaderboard, and daily challenge.
class ProfileProvider extends ChangeNotifier {
  final MockApiService _api;
  final StorageService _storage;

  bool _isLoading = false;
  List<Map<String, dynamic>> _weeklyScores = [];
  List<Map<String, dynamic>> _achievements = [];
  List<LeaderboardEntry> _leaderboard = [];
  ChallengeModel? _dailyChallenge;
  bool _challengeLoading = false;
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  ProfileProvider(this._api, this._storage);

  bool get isLoading => _isLoading;
  List<Map<String, dynamic>> get weeklyScores => _weeklyScores;
  List<Map<String, dynamic>> get achievements => _achievements;
  List<LeaderboardEntry> get leaderboard => _leaderboard;
  ChallengeModel? get dailyChallenge => _dailyChallenge;
  bool get challengeLoading => _challengeLoading;
  File? get profileImage => _profileImage;
  bool get isDarkMode => _storage.isDarkMode;

  /// Pick image from gallery or camera
  Future<void> pickProfileImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      if (image != null) {
        _profileImage = File(image.path);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  Future<void> fetchProfile() async {
    if (_weeklyScores.isNotEmpty) return;
    _isLoading = true;
    notifyListeners();
    try {
      final data = await _api.getUserProfile('user_001');
      _weeklyScores = List<Map<String, dynamic>>.from(
          data['weeklyScores'] as List);
      _achievements = List<Map<String, dynamic>>.from(
          data['achievements'] as List);
    } catch (_) {
      // Use empty state on failure
    }
    _isLoading = false;
    notifyListeners();
  }

  /// Fetch leaderboard.
  Future<void> fetchLeaderboard() async {
    _isLoading = true;
    notifyListeners();
    try {
      _leaderboard = await _api.getLeaderboard('user_001');
    } catch (_) {}
    _isLoading = false;
    notifyListeners();
  }

  /// Fetch or return cached daily challenge.
  Future<void> fetchDailyChallenge() async {
    if (_dailyChallenge != null) return;
    _challengeLoading = true;
    notifyListeners();
    try {
      _dailyChallenge = await _api.getDailyChallenge();
    } catch (_) {}
    _challengeLoading = false;
    notifyListeners();
  }

  /// Mark today's challenge as completed.
  void completeChallenge() {
    if (_dailyChallenge != null) {
      _dailyChallenge = _dailyChallenge!.copyWith(isCompleted: true);
      _storage.setLastChallengeDate(
          DateTime.now().toIso8601String().substring(0, 10));
      notifyListeners();
    }
  }

  Future<void> toggleDarkMode() async {
    await _storage.setDarkMode(!isDarkMode);
    notifyListeners();
  }

  /// Add points to today's score in the chart.
  void addScoreToToday(int score) {
    if (_weeklyScores.isEmpty) return;
    final today = DateTime.now().weekday;
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final todayStr = days[today - 1];
    for (var i = 0; i < _weeklyScores.length; i++) {
      if (_weeklyScores[i]['day'] == todayStr) {
        _weeklyScores[i]['score'] = (_weeklyScores[i]['score'] as int) + score;
        notifyListeners();
        break;
      }
    }
  }
}
