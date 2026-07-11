import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/app_user.dart';
import 'auth_service.dart';
import 'user_profile_service.dart';

enum SessionStatus { loading, unauthenticated, authenticated }

class AppSession extends ChangeNotifier {
  final AuthService _authService;
  final UserProfileService _profileService;

  AppSession({AuthService? authService, UserProfileService? profileService})
    : _authService = authService ?? AuthService(),
      _profileService = profileService ?? UserProfileService();

  StreamSubscription<User?>? _subscription;
  SessionStatus _status = SessionStatus.loading;
  AppUser? _user;
  String? _errorMessage;
  int _authRevision = 0;

  SessionStatus get status => _status;
  AppUser? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == SessionStatus.authenticated;

  void start() {
    _subscription ??= _authService.authStateChanges.listen(_handleAuthUser);
  }

  Future<void> signIn({required String email, required String password}) async {
    _errorMessage = null;
    notifyListeners();
    await _authService.signIn(email: email, password: password);
  }

  Future<void> signOut() async {
    _errorMessage = null;
    await _authService.signOut();
  }

  void clearError() {
    if (_errorMessage == null) return;
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> _handleAuthUser(User? firebaseUser) async {
    final revision = ++_authRevision;

    if (firebaseUser == null) {
      _user = null;
      _status = SessionStatus.unauthenticated;
      notifyListeners();
      return;
    }

    _status = SessionStatus.loading;
    notifyListeners();

    try {
      final profile = await _profileService.getUserProfile(firebaseUser.uid);
      if (revision != _authRevision) return;

      if (profile == null) {
        _errorMessage =
            'La cuenta no tiene un perfil users/{uid} en Firestore.';
        await _authService.signOut();
        return;
      }
      if (!profile.isActive) {
        _errorMessage = 'Esta cuenta está inactiva.';
        await _authService.signOut();
        return;
      }

      _user = profile;
      _status = SessionStatus.authenticated;
      notifyListeners();
    } catch (_) {
      if (revision != _authRevision) return;
      _errorMessage = 'No se pudo cargar el perfil desde Firestore.';
      await _authService.signOut();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
