import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  String _userId = '';
  String _username = '';
  String _email = '';
  String _name = '';
  String _phone = '';
  String _bio = '';
  String _avatarUrl = '';
  int _totalVerified = 0;
  double _accuracyScore = 0.0;
  String _communityRank = 'Beginner';

  // Getters
  bool get isAuthenticated => _isAuthenticated;
  String get userId => _userId;
  String get username => _username;
  String get email => _email;
  String get name => _name;
  String get phone => _phone;
  String get bio => _bio;
  String get avatarUrl => _avatarUrl;
  int get totalVerified => _totalVerified;
  double get accuracyScore => _accuracyScore;
  String get communityRank => _communityRank;

  /// Login with email/username and password.
  /// Returns null on success, or an error string on failure.
  Future<String?> login(String emailOrUsername, String password) async {
    final result = await ApiService.login(
      emailOrUsername: emailOrUsername,
      password: password,
    );

    if (result['status'] == 'success') {
      _setUserFromMap(result['user']);
      _isAuthenticated = true;
      notifyListeners();
      return null;
    }
    return result['message'] ?? 'Login failed';
  }

  /// Register with email, username, and password.
  /// Returns null on success, or an error string on failure.
  Future<String?> register(
    String email,
    String username,
    String password,
  ) async {
    final result = await ApiService.register(
      email: email,
      username: username,
      password: password,
    );

    if (result['status'] == 'success') {
      _setUserFromMap(result['user']);
      _isAuthenticated = true;
      notifyListeners();
      return null;
    }
    return result['message'] ?? 'Registration failed';
  }

  /// Logout - clears all user data.
  void logout() {
    _isAuthenticated = false;
    _userId = '';
    _username = '';
    _email = '';
    _name = '';
    _phone = '';
    _bio = '';
    _avatarUrl = '';
    _totalVerified = 0;
    _accuracyScore = 0.0;
    _communityRank = 'Beginner';
    notifyListeners();
  }

  /// Update profile fields via API.
  Future<String?> updateProfile({
    String? name,
    String? email,
    String? phone,
    String? bio,
    String? avatarUrl,
  }) async {
    if (_userId.isEmpty) return 'Not logged in';

    final result = await ApiService.updateProfile(
      userId: _userId,
      name: name,
      email: email,
      phone: phone,
      bio: bio,
      avatarUrl: avatarUrl,
    );

    if (result['status'] == 'success') {
      _setUserFromMap(result['user']);
      notifyListeners();
      return null;
    }
    return result['message'] ?? 'Update failed';
  }

  /// Re-fetch profile from API.
  Future<void> refreshProfile() async {
    if (_userId.isEmpty) return;

    final result = await ApiService.getProfile(_userId);
    if (result['status'] == 'success') {
      _setUserFromMap(result['user']);
      notifyListeners();
    }
  }

  void _setUserFromMap(Map<String, dynamic> user) {
    _userId = (user['id'] ?? '').toString();
    _email = user['email'] ?? '';
    _username = user['username'] ?? '';
    _name = user['name'] ?? '';
    _phone = user['phone'] ?? '';
    _bio = user['bio'] ?? '';
    _avatarUrl = user['avatar_url'] ?? '';
    _totalVerified = user['total_verified'] ?? 0;
    _accuracyScore = (user['accuracy_score'] ?? 0.0).toDouble();
    _communityRank = user['community_rank'] ?? 'Beginner';
  }
}
