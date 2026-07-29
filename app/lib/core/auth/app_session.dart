import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/app_user.dart';
import 'auth_service.dart';

enum SessionStatus { loading, signedOut, signedIn, blocked }

class AppSession extends ChangeNotifier {
  final AuthService service;
  StreamSubscription<User?>? _subscription;
  SessionStatus status = SessionStatus.loading;
  AppUser? user;
  String? error;

  AppSession({AuthService? service}) : service = service ?? AuthService();

  void start() {
    _subscription = service.authChanges.listen(_handleAuth);
  }

  Future<void> _handleAuth(User? firebaseUser) async {
    status = SessionStatus.loading;
    notifyListeners();
    if (firebaseUser == null) {
      user = null;
      status = SessionStatus.signedOut;
      notifyListeners();
      return;
    }
    try {
      final profile = await service.loadProfile(firebaseUser.uid);
      if (profile == null) {
        error = 'La cuenta existe en Authentication, pero no tiene perfil en users.';
        status = SessionStatus.blocked;
      } else if (!profile.isActive) {
        error = 'Esta cuenta se encuentra inactiva.';
        status = SessionStatus.blocked;
      } else {
        user = profile;
        status = SessionStatus.signedIn;
      }
    } catch (exception) {
      error = 'No se pudo cargar el perfil: $exception';
      status = SessionStatus.blocked;
    }
    notifyListeners();
  }

  Future<void> signIn(String email, String password) async {
    error = null;
    await service.signIn(email, password);
  }

  Future<void> signOut() async {
    user = null;
    await service.signOut();
  }

  Future<void> refreshProfile() async {
    final current = service.auth.currentUser;
    if (current != null) await _handleAuth(current);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
