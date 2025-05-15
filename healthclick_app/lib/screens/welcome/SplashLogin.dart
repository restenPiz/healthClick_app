import 'dart:async';
import 'package:flutter/material.dart';
import 'package:healthclick_app/screens/auth/Login.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SplashLogin extends StatefulWidget {
  const SplashLogin({super.key});

  @override
  State<SplashLogin> createState() => _SplashLoginState();
}

class _SplashLoginState extends State<SplashLogin> {
  @override
  void initState() {
    super.initState();
    // Redireciona para a tela de login após 6 segundos
    Timer(const Duration(seconds: 6), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => const Login()), // sua tela de login
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Pega o tema atual (dark/light)

    return Scaffold(
      backgroundColor:
          theme.scaffoldBackgroundColor, // Adapta o fundo conforme o tema
      body: Center(
        child: Image.asset(
          'assets/Saude.png', // Seu logo
          width: 240,
          height: 240,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
