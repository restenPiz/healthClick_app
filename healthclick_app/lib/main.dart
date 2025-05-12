import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:healthclick_app/ThemeProvider.dart';
import 'package:healthclick_app/screens/welcome/HomePage.dart';
import 'package:healthclick_app/screens/welcome/SplashLogin.dart';
import 'firebase_options.dart';
import 'package:healthclick_app/models/CartProvider.dart';
import 'package:healthclick_app/screens/auth/Login.dart';
import 'package:provider/provider.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

// Adicionar o provedor de autenticação
class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = true;
  User? _user;

  AuthProvider() {
    // Verificando se já existe um usuário autenticado ao iniciar o app
    _checkCurrentUser();
    // Ouvindo mudanças no estado de autenticação
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      _isLoading = false;
      notifyListeners();
    });
  }

  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
  User? get user => _user;

  Future<void> _checkCurrentUser() async {
    _user = _auth.currentUser;
    _isLoading = false;
    notifyListeners();
  }

  Future<User?> signIn(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();
      // Fazer login com email e senha
      UserCredential credential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return credential.user;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicialização do Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Inicialização completa do Stripe
  Stripe.publishableKey =
      'pk_test_51RMC3iQqtk7VgypaekoLTk2YDZaaFHifeaugbkKAeGvb3TXctB7Ovex9ZnnsTIYJuW2wmfIZa51OekpVnm6VEtnO00EsaxesXv';

  // Configurar aparência e opções do Stripe
  // await Stripe.instance.applySettings();

  // Executar o app com os providers
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.themeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: const ColorScheme.light(
          background: Colors.white,
          surface: Colors.white,
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
      ),
      // Substituir o home pelo AuthWrapper
      home: AuthWrapper(),
    );
  }
}

// Adicionar o AuthWrapper para verificar o estado de autenticação
class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    // Enquanto verifica o estado de autenticação, mostra a tela de splash
    if (authProvider.isLoading) {
      return const SplashLogin();
    }
    // Redireciona com base no estado de autenticação
    if (authProvider.isAuthenticated) {
      return const HomePage();
    } else {
      return const SplashLogin();
    }
  }
}
