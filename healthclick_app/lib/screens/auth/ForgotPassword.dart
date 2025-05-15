import 'package:flutter/material.dart';
import 'package:healthclick_app/screens/auth/Login.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  // Controller para o campo de email
  final TextEditingController emailController = TextEditingController();

  // Variável para controlar o estado de loading do botão
  bool _isResetting = false;

  // Instância do Firebase Auth
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Método para enviar o email de reset de senha
  Future<void> _resetPassword() async {
    final email = emailController.text.trim();

    // Validação básica de email
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email address')),
      );
      return;
    }

    // Validação de formato de email usando regex básico
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email address')),
      );
      return;
    }

    // Ativar indicador de loading
    setState(() {
      _isResetting = true;
    });

    try {
      // Enviar email de redefinição de senha
      await _auth.sendPasswordResetEmail(email: email);

      // Mostrar mensagem de sucesso
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Password reset email sent to $email'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 5),
        ),
      );

      // Opcional: Navegar de volta para a tela de login após um breve atraso
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Login()),
        );
      });
    } on FirebaseAuthException catch (e) {
      // Tratamento de erros específicos do Firebase Auth
      String errorMessage;

      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No user found with this email address.';
          break;
        case 'invalid-email':
          errorMessage = 'The email address is invalid.';
          break;
        case 'too-many-requests':
          errorMessage = 'Too many requests. Please try again later.';
          break;
        default:
          errorMessage = 'An error occurred. Please try again later.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      // Tratamento de outros erros
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      // Desativar indicador de loading, independentemente do resultado
      setState(() {
        _isResetting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Inicializando a classe AppSize para tornar a interface responsiva
    AppSize.init(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(AppSize.wp(4)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
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
                'Forgot Password',
                style: TextStyle(
                  fontSize: AppSize.sp(24),
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: AppSize.hp(1)),

              Text(
                'Enter your email address below, and we\'ll send you instructions to reset your password.',
                style: TextStyle(
                  fontSize: AppSize.sp(14),
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: AppSize.hp(3)),

              // Campo de texto para email
              SizedBox(
                height: AppSize.hp(7),
                child: TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSize.wp(8)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSize.wp(8)),
                      borderSide: const BorderSide(
                        color: Colors.grey,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSize.wp(8)),
                      borderSide: const BorderSide(color: Colors.blue),
                    ),
                    hintText: 'Enter your email',
                    prefixIcon: const Icon(Icons.email),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: AppSize.hp(1.5),
                      horizontal: AppSize.wp(4),
                    ),
                  ),
                ),
              ),
              SizedBox(height: AppSize.hp(3)),

              // Botão de reset de senha
              SizedBox(
                width: double.infinity,
                height: AppSize.hp(6.5),
                child: ElevatedButton(
                  onPressed: _isResetting ? null : _resetPassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: AppSize.hp(1.5)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSize.wp(8)),
                    ),
                    // Quando o botão estiver desativado, ainda terá um visual semelhante
                    disabledBackgroundColor: Colors.green.withOpacity(0.7),
                    disabledForegroundColor: Colors.white70,
                  ),
                  child: _isResetting
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: AppSize.wp(5),
                              height: AppSize.wp(5),
                              child: const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.0,
                              ),
                            ),
                            SizedBox(width: AppSize.wp(3)),
                            Text(
                              'Sending email...',
                              style: TextStyle(fontSize: AppSize.sp(16)),
                            ),
                          ],
                        )
                      : Text(
                          'Reset Password',
                          style: TextStyle(fontSize: AppSize.sp(17)),
                        ),
                ),
              ),
              SizedBox(height: AppSize.hp(3)),

              // Link para redirecionar ao login
              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const Login()),
                    );
                  },
                  child: Text(
                    'Remember Your Password? Sign In',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: AppSize.sp(15),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Limpar o controller quando o widget for destruído
    emailController.dispose();
    super.dispose();
  }
}
