import 'dart:async';

import 'package:flutter/material.dart';
import 'package:healthclick_app/screens/auth/Login.dart';

/// Gerencia o timeout da sessão quando o aplicativo estiver em background
class SessionTimeoutManager {
  static const int timeoutInMinutes = 4;
  DateTime? _pausedTime;
  Timer? _sessionTimer;
  final BuildContext context;
  final Function logout;

  SessionTimeoutManager({required this.context, required this.logout});

  /// Chamado quando o app entrar em background
  void appToBackground() {
    _pausedTime = DateTime.now();
    // Inicia um timer para verificar o tempo quando o app voltar ao foreground
    _sessionTimer?.cancel();
    _sessionTimer = Timer(const Duration(minutes: timeoutInMinutes), () {
      // Este timer só será executado se o app ficar em background por mais tempo
      // que o permitido e não voltar ao foreground
      performLogout();
    });
  }

  /// Chamado quando o app voltar ao foreground
  void appToForeground() {
    if (_pausedTime != null) {
      final now = DateTime.now();
      final difference = now.difference(_pausedTime!);

      if (difference.inMinutes >= timeoutInMinutes) {
        performLogout();
      }
      _pausedTime = null;
    }

    // Cancela o timer pendente
    _sessionTimer?.cancel();
    _sessionTimer = null;
  }

  /// Executa o logout e navega para a tela de login
  void performLogout() {
    logout();
    // Navega para a tela de login
    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const Login()),
      (route) => false,
    );
  }

  /// Deve ser chamado quando a instância não for mais necessária
  void dispose() {
    _sessionTimer?.cancel();
    _sessionTimer = null;
  }
}
