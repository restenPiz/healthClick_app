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
    Timer(Duration(seconds: 6), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => Login()), // sua tela de login
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // cor de fundo opcional
      body: Center(
        child: Image.asset(
          'assets/Saude.png', // seu logo
          width: 240,
          height: 240,
          fit: BoxFit.cover,
        ),
        // child: Text(
        //   'Splash funcionando...',
        //   style: TextStyle(fontSize: 20),
        // ),
      ),
    );
  }
}