// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:healthclick_app/screens/auth/Login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:healthclick_app/screens/welcome/OnBoarding.dart';
import 'dart:convert'; // para jsonEncode
import 'package:http/http.dart' as http; // para http.post

// Classe utilitária para gerenciar dimensões responsivas
class AppSize {
  static late MediaQueryData _mediaQueryData;
  static late double screenWidth;
  static late double screenHeight;
  static late double blockSizeHorizontal;
  static late double blockSizeVertical;
  static late double _safeAreaHorizontal;
  static late double _safeAreaVertical;
  static late double safeBlockHorizontal;
  static late double safeBlockVertical;
  static late double textScaleFactor;

  static void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    textScaleFactor = _mediaQueryData.textScaleFactor;

    blockSizeHorizontal = screenWidth / 100;
    blockSizeVertical = screenHeight / 100;

    _safeAreaHorizontal =
        _mediaQueryData.padding.left + _mediaQueryData.padding.right;
    _safeAreaVertical =
        _mediaQueryData.padding.top + _mediaQueryData.padding.bottom;
    safeBlockHorizontal = (screenWidth - _safeAreaHorizontal) / 100;
    safeBlockVertical = (screenHeight - _safeAreaVertical) / 100;
  }

  // Para elementos que devem ser proporcionais ao tamanho da tela
  static double hp(double percentage) => blockSizeVertical * percentage;
  static double wp(double percentage) => blockSizeHorizontal * percentage;

  // Para textos responsivos
  static double sp(double size) => size * textScaleFactor;
}

class CreateAccount extends StatefulWidget {
  const CreateAccount({super.key});

  @override
  State<CreateAccount> createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  Future<User?> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      final user = userCredential.user;

      if (user == null) throw Exception('Erro ao autenticar com Firebase');

      final response = await http.post(
        Uri.parse('http://192.168.100.139:8000/api/sync-firebase-uid'),
        body: {
          'firebase_uid': user.uid,
          'email': user.email ?? '',
          'name': user.displayName ?? 'Google User',
        },
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('✅ Login com Google e sincronização feita')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('❌ Erro ao sincronizar UID: ${response.body}')),
        );
      }

      return user;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google login falhou: $e')),
      );
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    AppSize.init(context);

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(AppSize.wp(4)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Image.asset(
                  "assets/Saude.png",
                  width: AppSize.wp(60),
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: AppSize.hp(2)),
              Text(
                'Create An Account',
                style: TextStyle(
                  fontSize: AppSize.sp(20),
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: AppSize.hp(1.5)),
              SizedBox(
                height: AppSize.hp(7),
                child: TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSize.wp(8)),
                    ),
                    hintText: 'Your Email Address',
                    prefixIcon: const Icon(Icons.email),
                  ),
                ),
              ),
              SizedBox(height: AppSize.hp(1.5)),
              SizedBox(
                height: AppSize.hp(7),
                child: TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSize.wp(8)),
                    ),
                    hintText: 'Your Password',
                    prefixIcon: const Icon(Icons.lock),
                  ),
                ),
              ),
              SizedBox(height: AppSize.hp(1.5)),
              SizedBox(
                height: AppSize.hp(7),
                child: TextField(
                  controller: confirmPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSize.wp(8)),
                    ),
                    hintText: 'Your Password Confirmation',
                    prefixIcon: const Icon(Icons.lock),
                  ),
                ),
              ),
              SizedBox(height: AppSize.hp(2)),
              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const Login()),
                    );
                  },
                  child: Text(
                    "Already Have An Account? Login",
                    style: TextStyle(
                      fontSize: AppSize.sp(15),
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ),
              ),
              SizedBox(height: AppSize.hp(2)),
              Center(
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: AppSize.hp(6.5),
                      child: ElevatedButton(
                        onPressed: () async {
                          if (passwordController.text !=
                              confirmPasswordController.text) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Passwords do not match')),
                            );
                            return;
                          }

                          try {
                            final email = emailController.text.trim();
                            final password = passwordController.text.trim();

                            final credential = await FirebaseAuth.instance
                                .createUserWithEmailAndPassword(
                                    email: email, password: password);

                            final user = credential.user;

                            if (user != null) {
                              final response = await http.post(
                                Uri.parse(
                                    'https://cloudev.org/api/sync-firebase-uid'),
                                headers: {'Content-Type': 'application/json'},
                                body: jsonEncode({
                                  'firebase_uid': user.uid,
                                  'email': user.email ?? '',
                                  'name':
                                      user.displayName ?? 'Usuário Firebase',
                                }),
                              );

                              if (response.statusCode == 200) {
                                print('✅ UID sincronizado com sucesso.');
                              } else {
                                print(
                                    '❌ Erro ao sincronizar UID: ${response.body}');
                              }

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('Account created successfully')),
                              );

                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const OnBoarding()),
                              );
                            }
                          } catch (e) {
                            String errorMessage = 'An error occurred';
                            if (e is FirebaseAuthException) {
                              switch (e.code) {
                                case 'email-already-in-use':
                                  errorMessage = 'Este email já está em uso.';
                                  break;
                                case 'invalid-email':
                                  errorMessage = 'Email inválido.';
                                  break;
                                case 'weak-password':
                                  errorMessage = 'A senha é muito fraca.';
                                  break;
                                default:
                                  errorMessage = 'Erro: ${e.message}';
                              }
                            } else {
                              errorMessage = e.toString();
                            }

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(errorMessage)),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding:
                              EdgeInsets.symmetric(vertical: AppSize.hp(1.5)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppSize.wp(8)),
                          ),
                        ),
                        child: Text(
                          'Sign Up',
                          style: TextStyle(fontSize: AppSize.sp(17)),
                        ),
                      ),
                    ),
                    SizedBox(height: AppSize.hp(1)),
                    const Text("Or Sign Up With"),
                    SizedBox(height: AppSize.hp(1)),
                    SizedBox(
                      width: double.infinity,
                      height: AppSize.hp(6.5),
                      child: ElevatedButton(
                        onPressed: _signInWithGoogle,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          padding:
                              EdgeInsets.symmetric(vertical: AppSize.hp(1.5)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppSize.wp(8)),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              "assets/google.png",
                              width: AppSize.wp(6),
                              height: AppSize.wp(6),
                            ),
                            SizedBox(width: AppSize.wp(3)),
                            Text(
                              'Continue with Google',
                              style: TextStyle(
                                fontSize: AppSize.sp(17),
                                fontWeight: FontWeight.bold,
                              ),
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
