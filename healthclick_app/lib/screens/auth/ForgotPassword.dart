import 'package:flutter/material.dart';
import 'package:healthclick_app/screens/auth/Login.dart';

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
  @override
  Widget build(BuildContext context) {
    // Inicializando a classe AppSize para tornar a interface responsiva
    AppSize.init(context);

    return Scaffold(
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

              const Center(
                child: Text(
                  'Enter your email address to reset your password.',
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: AppSize.hp(3)),

              // Campo de texto para email
              SizedBox(
                height: AppSize.hp(7),
                child: TextField(
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
                  ),
                ),
              ),
              SizedBox(height: AppSize.hp(3)),

              // Botão de reset de senha
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: AppSize.hp(2)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSize.wp(8)),
                    ),
                  ),
                  child: Text(
                    'Reset Password',
                    style: TextStyle(fontSize: AppSize.sp(20)),
                  ),
                ),
              ),
              SizedBox(height: AppSize.hp(3)),

              // Link para redirecionar ao login
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Login()),
                  );
                },
                child: const Center(
                  child: Text(
                    'Remember Your Password? Sign In',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
