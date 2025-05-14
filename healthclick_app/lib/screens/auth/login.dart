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
    clientId:
        '50654751468-08ooqne2n1fm05dn4l5199equ0ssgu0g.apps.googleusercontent.com',
  );

  // Variáveis para controlar o estado de loading dos botões
  bool _isLoggingIn = false;
  bool _isGoogleSigningIn = false;

  //*Start with the signGoogle method
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

      // Autenticar com Firebase
      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      final user = userCredential.user;

      if (user == null) throw Exception('Erro ao autenticar com Firebase');

      // Enviar para o backend
      final response = await http.post(
        Uri.parse(
            'http://192.168.100.139:8000/api/sync-firebase-uid'), // Ajusta essa URL
        body: {
          'firebase_uid': user.uid,
          'email': user.email ?? '',
          'name': user.displayName ?? 'Google User',
        },
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✅ Login com Google e sincronização feita')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('❌ Erro ao sincronizar UID: ${response.body}')),
        );
      }

      return user;
    } catch (e, stackTrace) {
      debugPrint('Erro ao fazer login com Google: $e');
      debugPrint('StackTrace: $stackTrace');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google login falhou: ${e.toString()}')),
      );
      return null;
    } finally {
      // Sempre desativa o indicador de loading quando terminar (sucesso ou erro)
      setState(() {
        _isGoogleSigningIn = false;
      });
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
    // Ativar o indicador de loading
    setState(() {
      _isLoggingIn = true;
    });

    try {
      final email = emailController.text.trim();
      final password = passwordController.text.trim();

      if (email.isEmpty || password.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please enter both email and password.")),
        );
        // Desativa o indicador de loading em caso de erro de validação
        setState(() {
          _isLoggingIn = false;
        });
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

      // Desativa o indicador de loading em caso de erro
      setState(() {
        _isLoggingIn = false;
      });
    } catch (e) {
      print('Erro inesperado: $e');
      // Desativa o indicador de loading em caso de erro
      setState(() {
        _isLoggingIn = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Inicializa a classe de tamanhos responsivos
    AppSize.init(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(AppSize.wp(4.0)), // Padding responsivo
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //? Image Section - Tamanho com base em porcentagem da largura da tela
                Center(
                  child: Image.asset(
                    "assets/Saude.png",
                    width: AppSize.wp(60), // 60% da largura da tela
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(height: AppSize.hp(2)), // Espaçamento responsivo

                //? Title and Input - Tamanho de texto responsivo
                Text(
                  'Sign in to your Account',
                  style: TextStyle(
                      fontSize: AppSize.sp(20), fontWeight: FontWeight.bold),
                ),
                SizedBox(height: AppSize.hp(1.5)),

                //? Input Field - Altura responsiva
                SizedBox(
                  height: AppSize.hp(7), // Altura do campo em % da tela
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
                      hintText: 'Enter your email',
                      prefixIcon: Icon(Icons.email),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: AppSize.hp(1.5),
                        horizontal: AppSize.wp(4),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: AppSize.hp(1.5)),

                //? Password Field - Altura responsiva
                SizedBox(
                  height: AppSize.hp(7), // Altura do campo em % da tela
                  child: TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: 'Enter your password',
                      prefixIcon: Icon(Icons.lock),
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
                      contentPadding: EdgeInsets.symmetric(
                        vertical: AppSize.hp(1.5),
                        horizontal: AppSize.wp(4),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: AppSize.hp(1.5)),

                //?Creating account section
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CreateAccount()),
                    );
                  },
                  child: Text(
                    "Create an account",
                    style: TextStyle(
                        fontSize: AppSize.sp(15),
                        fontWeight: FontWeight.bold,
                        color: Colors.red),
                  ),
                ),
                SizedBox(height: AppSize.hp(1.5)),

                //?Remember me and Forget password section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          height: AppSize.hp(4),
                          width: AppSize.wp(6),
                          child: Checkbox(
                            value: isChecked,
                            onChanged: (bool? newValue) {
                              setState(() {
                                isChecked = newValue!;
                              });
                            },
                          ),
                        ),
                        Text(
                          "Remember Me",
                          style: TextStyle(fontSize: AppSize.sp(14)),
                        ),
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
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: AppSize.sp(14),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSize.hp(2)),

                //?Login button section
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: AppSize.hp(6.5), // Altura do botão responsiva
                        child: ElevatedButton(
                          onPressed: _isLoggingIn
                              ? null
                              : _login, // Desativar durante loading
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding:
                                EdgeInsets.symmetric(vertical: AppSize.hp(1.5)),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(AppSize.wp(8)),
                            ),
                            // Quando o botão estiver desativado, ainda terá um visual semelhante
                            disabledBackgroundColor:
                                Colors.green.withOpacity(0.7),
                            disabledForegroundColor: Colors.white70,
                          ),
                          child: _isLoggingIn
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
                                      'Signing in...',
                                      style:
                                          TextStyle(fontSize: AppSize.sp(16)),
                                    ),
                                  ],
                                )
                              : Text(
                                  'Login',
                                  style: TextStyle(fontSize: AppSize.sp(17)),
                                ),
                        ),
                      ),
                      SizedBox(height: AppSize.hp(2)),
                      Text(
                        "Or Sign Up With",
                        style: TextStyle(fontSize: AppSize.sp(14)),
                      ),
                      SizedBox(height: AppSize.hp(2)),
                      SizedBox(
                        width: double.infinity,
                        height: AppSize.hp(6.5), // Altura do botão responsiva
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
                              borderRadius:
                                  BorderRadius.circular(AppSize.wp(8)),
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
                                    SizedBox(width: AppSize.wp(2)),
                                    Text(
                                      'Continue with Google',
                                      style: TextStyle(
                                          fontSize: AppSize.sp(17),
                                          fontWeight: FontWeight.bold),
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
      ),
    );
  }
}
