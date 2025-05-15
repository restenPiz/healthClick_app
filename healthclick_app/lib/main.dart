import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:healthclick_app/SessionTimeoutManager.dart';
import 'package:healthclick_app/ThemeProvider.dart';
import 'package:healthclick_app/screens/welcome/HomePage.dart';
import 'package:healthclick_app/screens/welcome/SplashLogin.dart';
import 'firebase_options.dart';
import 'package:healthclick_app/models/CartProvider.dart';
import 'package:healthclick_app/screens/auth/Login.dart';
import 'package:provider/provider.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

// Provedor de autenticação com gerenciamento de timeout de sessão
class AuthProvider with ChangeNotifier {
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

  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = true;
  User? _user;

  bool get isLoading => _isLoading;

  bool get isAuthenticated => _user != null;

  User? get user => _user;

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

  Future<void> _checkCurrentUser() async {
    _user = _auth.currentUser;
    _isLoading = false;
    notifyListeners();
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

// AuthWrapper modificado para lidar com o lifecycle do app
class AuthWrapper extends StatefulWidget {
  @override
  _AuthWrapperState createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> with WidgetsBindingObserver {
  SessionTimeoutManager? _sessionManager;

  @override
  void initState() {
    super.initState();
    // Registrar observer para detectar mudanças no estado do app
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Inicializar o gerenciador de sessão
    final authProvider = Provider.of<AuthProvider>(context);
    if (authProvider.isAuthenticated && _sessionManager == null) {
      _sessionManager = SessionTimeoutManager(
        context: context,
        logout: () => authProvider.signOut(),
      );
    }
  }

  @override
  void dispose() {
    // Remover observer e recursos
    WidgetsBinding.instance.removeObserver(this);
    _sessionManager?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    // Só gerenciar timeout se o usuário estiver autenticado
    if (authProvider.isAuthenticated) {
      if (state == AppLifecycleState.paused ||
          state == AppLifecycleState.inactive) {
        // App foi para background
        _sessionManager?.appToBackground();
      } else if (state == AppLifecycleState.resumed) {
        // App voltou para foreground
        _sessionManager?.appToForeground();
      }
    }
  }

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
