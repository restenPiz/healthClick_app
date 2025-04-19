import 'package:flutter/material.dart';
import 'package:healthclick_app/screens/welcome/OnBoarding.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Redireciona após 2 segundos
    Future.delayed(Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => OnBoarding()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ícone ou logo
            // Icon(Icons.health_and_safety, size: 80, color: Colors.green),
            Image.asset(
              "assets/Saude.png",
              width: 150,
              height: 150,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 20),
            CircularProgressIndicator(),
            SizedBox(height: 10),
            Text("Carregando...", style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
