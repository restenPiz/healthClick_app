import 'dart:async';
import 'package:flutter/material.dart';
import 'package:healthclick_app/screens/auth/Login.dart';

class SessionTimeoutManager {
  static const int timeoutInMinutes = 4;
  DateTime? _pausedTime;
  Timer? _sessionTimer;
  final BuildContext context;
  final Function logout;

  SessionTimeoutManager({required this.context, required this.logout});

  void appToBackground() {
    _pausedTime = DateTime.now();
    _sessionTimer?.cancel();
    _sessionTimer = Timer(const Duration(minutes: timeoutInMinutes), () {
      performLogout();
    });
  }

  void appToForeground() {
    if (_pausedTime != null) {
      final now = DateTime.now();
      if (now.difference(_pausedTime!).inMinutes >= timeoutInMinutes) {
        performLogout();
      }
      _pausedTime = null;
    }
    _sessionTimer?.cancel();
    _sessionTimer = null;
  }

  void performLogout() {
    logout();
    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const Login()),
      (route) => false,
    );
  }

  void dispose() {
    _sessionTimer?.cancel();
    _sessionTimer = null;
  }
}
