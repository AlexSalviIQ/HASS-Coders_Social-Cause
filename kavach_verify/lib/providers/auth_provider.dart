import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  String _username = '';
  String _email = '';

  bool get isAuthenticated => _isAuthenticated;
  String get username => _username;
  String get email => _email;

  // Hardcoded demo account
  static const String demoEmail = 'demo@kavach.com';
  static const String demoUsername = 'demo';
  static const String demoPassword = 'demo123';

  // Registered accounts (in-memory)
  final Map<String, _Account> _accounts = {
    demoEmail: _Account(
      email: demoEmail,
      username: demoUsername,
      password: demoPassword,
    ),
    demoUsername: _Account(
      email: demoEmail,
      username: demoUsername,
      password: demoPassword,
    ),
  };

  /// Login with email/username and password.
  /// Returns null on success, error string on failure.
  String? login(String emailOrUsername, String password) {
    final key = emailOrUsername.trim().toLowerCase();
    final account = _accounts[key];
    if (account == null) {
      return 'Account not found';
    }
    if (account.password != password) {
      return 'Incorrect password';
    }
    _isAuthenticated = true;
    _username = account.username;
    _email = account.email;
    notifyListeners();
    return null;
  }

  /// Register a new account.
  /// Returns null on success, error string on failure.
  String? register(String email, String username, String password) {
    final emailKey = email.trim().toLowerCase();
    final usernameKey = username.trim().toLowerCase();

    if (_accounts.containsKey(emailKey)) {
      return 'Email already registered';
    }
    if (_accounts.containsKey(usernameKey)) {
      return 'Username already taken';
    }

    final account = _Account(
      email: emailKey,
      username: usernameKey,
      password: password,
    );
    _accounts[emailKey] = account;
    _accounts[usernameKey] = account;

    // Auto-login after registration
    _isAuthenticated = true;
    _username = account.username;
    _email = account.email;
    notifyListeners();
    return null;
  }

  void logout() {
    _isAuthenticated = false;
    _username = '';
    _email = '';
    notifyListeners();
  }
}

class _Account {
  final String email;
  final String username;
  final String password;
  const _Account({
    required this.email,
    required this.username,
    required this.password,
  });
}
