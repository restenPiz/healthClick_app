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

  // Variáveis para controlar o estado de loading dos botões
  bool _isSigningUp = false;
  bool _isGoogleSigningIn = false;

  Future<User?> _signInWithGoogle() async {
    // Ativa o indicador de loading
    setState(() {
      _isGoogleSigningIn = true;
    });

    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        // Login cancelado, desativa o indicador
        setState(() {
          _isGoogleSigningIn = false;
        });
        return null;
      }

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
        Uri.parse('https://cloudev.org/api/sync-firebase-uid'),
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
    } finally {
      // Sempre desativa o indicador de loading quando terminar (sucesso ou erro)
      setState(() {
        _isGoogleSigningIn = false;
      });
    }
  }

  // Função para criar conta com email e senha
  Future<void> _signUp() async {
    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    // Ativa o indicador de loading
    setState(() {
      _isSigningUp = true;
    });

    try {
      final email = emailController.text.trim();
      final password = passwordController.text.trim();

      if (email.isEmpty || password.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Please enter both email and password.")),
        );
        setState(() {
          _isSigningUp = false;
        });
        return;
      }

      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      final user = credential.user;

      if (user != null) {
        final response = await http.post(
          Uri.parse('https://cloudev.org/api/sync-firebase-uid'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'firebase_uid': user.uid,
            'email': user.email ?? '',
            'name': user.displayName ?? 'Usuário Firebase',
          }),
        );

        if (response.statusCode == 200) {
          print('✅ UID sincronizado com sucesso.');
        } else {
          print('❌ Erro ao sincronizar UID: ${response.body}');
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account created successfully')),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const OnBoarding()),
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
    } finally {
      // Sempre desativa o indicador de loading quando terminar (sucesso ou erro)
      setState(() {
        _isSigningUp = false;
      });
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
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSize.wp(8)),
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSize.wp(8)),
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                    hintText: 'Your Email Address',
                    prefixIcon: const Icon(Icons.email),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: AppSize.hp(1.5),
                      horizontal: AppSize.wp(4),
                    ),
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
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSize.wp(8)),
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSize.wp(8)),
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                    hintText: 'Your Password',
                    prefixIcon: const Icon(Icons.lock),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: AppSize.hp(1.5),
                      horizontal: AppSize.wp(4),
                    ),
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
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSize.wp(8)),
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSize.wp(8)),
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                    hintText: 'Your Password Confirmation',
                    prefixIcon: const Icon(Icons.lock),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: AppSize.hp(1.5),
                      horizontal: AppSize.wp(4),
                    ),
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
                        onPressed: _isSigningUp ? null : _signUp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding:
                              EdgeInsets.symmetric(vertical: AppSize.hp(1.5)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppSize.wp(8)),
                          ),
                          // Quando o botão estiver desativado, ainda terá um visual semelhante
                          disabledBackgroundColor:
                              Colors.green.withOpacity(0.7),
                          disabledForegroundColor: Colors.white70,
                        ),
                        child: _isSigningUp
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: AppSize.wp(5),
                                    height: AppSize.wp(5),
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.0,
                                    ),
                                  ),
                                  SizedBox(width: AppSize.wp(3)),
                                  Text(
                                    'Creating account...',
                                    style: TextStyle(fontSize: AppSize.sp(16)),
                                  ),
                                ],
                              )
                            : Text(
                                'Sign Up',
                                style: TextStyle(fontSize: AppSize.sp(17)),
                              ),
                      ),
                    ),
                    SizedBox(height: AppSize.hp(1)),
                    Text(
                      "Or Sign Up With",
                      style: TextStyle(fontSize: AppSize.sp(14)),
                    ),
                    SizedBox(height: AppSize.hp(1)),
                    SizedBox(
                      width: double.infinity,
                      height: AppSize.hp(6.5),
                      child: ElevatedButton(
                        onPressed: _isGoogleSigningIn
                            ? null
                            : () async {
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
                          padding:
                              EdgeInsets.symmetric(vertical: AppSize.hp(1.5)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppSize.wp(8)),
                          ),
                          // Quando o botão estiver desativado, ainda terá um visual semelhante
                          disabledBackgroundColor:
                              Colors.white.withOpacity(0.9),
                          disabledForegroundColor: Colors.black38,
                        ),
                        child: _isGoogleSigningIn
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: AppSize.wp(5),
                                    height: AppSize.wp(5),
                                    child: CircularProgressIndicator(
                                      color: Colors.blue,
                                      strokeWidth: 2.0,
                                    ),
                                  ),
                                  SizedBox(width: AppSize.wp(3)),
                                  Text(
                                    'Signing in with Google...',
                                    style: TextStyle(
                                        fontSize: AppSize.sp(16),
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              )
                            : Row(
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
