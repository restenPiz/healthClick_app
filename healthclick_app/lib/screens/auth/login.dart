// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:healthclick_app/screens/auth/CreateAccount.dart';
import 'package:healthclick_app/screens/auth/ForgotPassword.dart';
import 'package:healthclick_app/screens/welcome/OnBoarding.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:healthclick_app/screens/welcome/SplashScreen.dart';
import 'dart:convert'; // para jsonEncode
import 'package:http/http.dart' as http; // para http.post

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {

  //*Defining the attributes for make the google authentication
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  //*Defining the input names 
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isChecked = false;

  final GoogleSignIn googleSignIn = GoogleSignIn(
    clientId: '50654751468-08ooqne2n1fm05dn4l5199equ0ssgu0g.apps.googleusercontent.com',
  );

  //*Start with the signGoogle method
  Future<User?> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      return userCredential.user;
    } catch (e) {
      print("Erro ao fazer login com Google: $e");
      return null;
    }
  }

  Future<User?> _signInAnonymously() async {
    try {
      final UserCredential userCredential = await _auth.signInAnonymously();
      return userCredential.user;
    } catch (e) {
      print("Erro ao fazer login anonimamente: $e");
      return null;
    }
  }

  //*Start with the methods to manage the responses and redirects of login
  Future<void> _login() async {
  try {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter both email and password.")),
      );
      return;
    }

    // Autentica com Firebase
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Obtem o usuário autenticado
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final uid = user.uid;

      // 🔁 Envia o UID e o e-mail para o backend Laravel
      final response = await http.post(
        Uri.parse('http://192.168.100.139:8000/api/sync-firebase-uid'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'firebase_uid': uid,
          'email': email,
        }),
      );

      if (response.statusCode == 200) {
        print('✅ UID sincronizado com sucesso.');
      } else {
        print('❌ Erro ao sincronizar UID: ${response.body}');
      }
    }

    // Navega para próxima tela
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => SplashScreen()),
    );
  } on FirebaseAuthException catch (e) {
    String message = 'Login failed.';

    if (e.code == 'user-not-found') {
      message = 'User not found.';
    } else if (e.code == 'wrong-password') {
      message = 'Incorrect password.';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  } catch (e) {
    print('Erro inesperado: $e');
  }
}


  @override
  Widget build(BuildContext context) {
    bool isChecked = false; // Checkbox state
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start, // Align text properly
            children: [
              //? Image Section
              Center(
                child: Image.asset(
                  "assets/Saude.png",
                  width: 300,
                  fit: BoxFit.cover,
                ),
              ),
              // const SizedBox(height: 5),

              //? Title and Input
              const Text(
                'Sign in to your Account',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              //? Input Field
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(30), // Aumenta o arredondamento
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(
                        color:
                            Colors.grey), // Cor da borda quando não está focado
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide:
                        BorderSide(color: Colors.blue), // Cor da borda ao focar
                  ),
                  hintText: 'Enter your email',
                  prefixIcon: Icon(Icons.email),
                ),
              ),
              const SizedBox(height: 10),

              //? Password Field
              TextField(
                controller: passwordController,
                obscureText: true, // Esconde o texto (ideal para senhas)
                decoration: InputDecoration(
                  hintText: 'Enter your password',
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30), // Aumenta o arredondamento
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(color: Colors.grey), // Cor da borda quando não está focado
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(color: Colors.blue), // Cor da borda ao focar
                  ),
                ),
              ),
              const SizedBox(height: 10),
              //?Creating account section
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            CreateAccount()), 
                  );
                },
                child: Text(
                  "Create an account",
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.red),
                ),
              ),
              const SizedBox(height: 10),
              //?Remember me and Forget password section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: isChecked,
                        onChanged: (bool? newValue) {
                          setState(() {
                            isChecked = newValue!;
                          });
                        },
                      ),
                      Text("Remember Me"),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ForgotPassword()),
                      );
                    },
                    child: Text(
                      "Forgot Password?",
                      style: TextStyle(
                        color: Colors.blue, // Makes it look like a link
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              //?Login button section
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: double.infinity, // ✅ Makes button full width
                      child: ElevatedButton(
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 15),
                        ),
                        child: const Text('Login',style: TextStyle(fontSize: 17),),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text("Or Sign Up With"),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          User? user = await _signInWithGoogle();
                          if (user != null) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const OnBoarding()),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          padding: EdgeInsets.symmetric(vertical: 15),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              "assets/google.png",
                              width: 24, 
                              height: 24,
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Continue with Google',
                              style: TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
