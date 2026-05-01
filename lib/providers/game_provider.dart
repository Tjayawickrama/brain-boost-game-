import 'package:flutter/material.dart';
import '../models/game_score_model.dart';
import '../services/mock_api_service.dart';
import '../services/storage_service.dart';

enum GameState { idle, playing, won, lost }

/// Manages game session state: score, timer, win/lose detection.
class GameProvider extends ChangeNotifier {
  final MockApiService _api;
  final StorageService _storage;

  GameState _gameState = GameState.idle;
  int _score = 0;
  int _accuracy = 100;
  bool _isSaving = false;
  GameScoreModel? _lastScore;

  GameProvider(this._api, this._storage);

  GameState get gameState => _gameState;
  int get score => _score;
  int get accuracy => _accuracy;
  bool get isSaving => _isSaving;
  GameScoreModel? get lastScore => _lastScore;

  void startGame() {
    _gameState = GameState.playing;
    _score = 0;
    _accuracy = 100;
    _lastScore = null;
    notifyListeners();
  }

  void addPoints(int pts) {
    _score += pts;
    notifyListeners();
  }

  void setAccuracy(int acc) {
    _accuracy = acc;
    notifyListeners();
  }

  Future<void> endGame({
    required bool won,
    required String gameId,
    required String gameName,
    required int durationSeconds,
  }) async {
    _gameState = won ? GameState.won : GameState.lost;
    _lastScore = GameScoreModel(
      gameId: gameId,
      gameName: gameName,
      score: _score,
      accuracy: _accuracy,
      durationSeconds: durationSeconds,
      playedAt: DateTime.now(),
    );
    notifyListeners();

    // Save to mock API and local storage
    _isSaving = true;
    notifyListeners();
    try {
      await _api.saveGameScore(gameId, _score, _accuracy);
    } catch (_) {
      // Fail silently for offline scenario
    }
    _isSaving = false;
    notifyListeners();
  }

  void resetGame() {
    _gameState = GameState.idle;
    _score = 0;
    _accuracy = 100;
    notifyListeners();
  }
}
