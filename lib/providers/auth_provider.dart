import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/mock_api_service.dart';
import '../services/storage_service.dart';

/// Authentication state: login, register, logout, persist session.
class AuthProvider extends ChangeNotifier {
  final MockApiService _api;
  final StorageService _storage;

  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isLoggedIn = false;

  AuthProvider(this._api, this._storage) {
    _loadFromStorage();
  }

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _isLoggedIn;

  void _loadFromStorage() {
    _isLoggedIn = _storage.isLoggedIn;
    if (_isLoggedIn) {
      // Re-create user from local cache
      _user = UserModel(
        id: 'user_001',
        name: _storage.userName,
        email: _storage.userEmail,
        totalScore: _storage.totalScore,
        level: _storage.level,
        gamesPlayed: _storage.gamesPlayed,
      );
    }
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final fbUser = userCredential.user!;
      _user = UserModel(
        id: fbUser.uid,
        name: fbUser.displayName ?? 'Player',
        email: fbUser.email ?? '',
        totalScore: _storage.totalScore,
        level: _storage.level,
        gamesPlayed: _storage.gamesPlayed,
      );
      _isLoggedIn = true;
      // Persist session
      await _storage.setLoggedIn(true);
      await _storage.setUserName(_user!.name);
      await _storage.setUserEmail(_user!.email);
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message ?? 'An error occurred';
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register(String name, String email, String password) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final fbUser = userCredential.user!;
      await fbUser.updateDisplayName(name);
      
      _user = UserModel(
        id: fbUser.uid,
        name: name,
        email: email,
        totalScore: _storage.totalScore,
        level: _storage.level,
        gamesPlayed: _storage.gamesPlayed,
      );
      _isLoggedIn = true;
      await _storage.setLoggedIn(true);
      await _storage.setUserName(name);
      await _storage.setUserEmail(email);
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message ?? 'An error occurred';
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    await _storage.setLoggedIn(false);
    _isLoggedIn = false;
    _user = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }

  /// Update local user score after a game.
  Future<void> addScore(int points) async {
    await _storage.addScore(points);
    await _storage.incrementGamesPlayed();
    // Recalculate level
    final newTotal = _storage.totalScore;
    int newLevel = 1;
    const thresholds = [0, 100, 300, 600, 1000, 1500, 2200, 3000];
    for (int i = thresholds.length - 1; i >= 0; i--) {
      if (newTotal >= thresholds[i]) {
        newLevel = i + 1;
        break;
      }
    }
    await _storage.setLevel(newLevel);
    _user = _user?.copyWith(
      totalScore: newTotal,
      level: newLevel,
      gamesPlayed: _storage.gamesPlayed,
    );
    notifyListeners();
  }
}
