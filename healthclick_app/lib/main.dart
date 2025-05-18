import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:healthclick_app/SessionTimeoutManager.dart';
import 'package:healthclick_app/ThemeProvider.dart';
import 'package:healthclick_app/screens/welcome/HomePage.dart';
import 'package:healthclick_app/screens/welcome/SplashLogin.dart';
import 'firebase_options.dart';
import 'package:healthclick_app/models/CartProvider.dart';
import 'package:healthclick_app/screens/auth/Login.dart';
import 'package:provider/provider.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

// 🔐 Provedor de autenticação com gerenciamento de estado
class AuthProvider with ChangeNotifier {
  AuthProvider() {
    _checkCurrentUser();
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
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _user = credential.user;
      return _user;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn().signOut();
    _user = null;
    notifyListeners();
  }

  Future<void> _checkCurrentUser() async {
    try {
      User? current = _auth.currentUser;
      if (current != null) {
        await current.reload(); // 🛠 Garante que o estado é atualizado
        _user = _auth.currentUser;
      } else {
        _user = null;
      }
    } catch (_) {
      _user = null;
    }
    _isLoading = false;
    notifyListeners();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Opcional: deslogar sempre ao iniciar o app (para evitar sessão antiga no desenvolvimento)
  await FirebaseAuth.instance.signOut();
  await GoogleSignIn().signOut();

  // Inicializa Stripe
  Stripe.publishableKey =
      'pk_test_51RMC3iQqtk7VgypaekoLTk2YDZaaFHifeaugbkKAeGvb3TXctB7Ovex9ZnnsTIYJuW2wmfIZa51OekpVnm6VEtnO00EsaxesXv';

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
      home: const AuthWrapper(),
    );
  }
}

// 🔄 Tela intermediária que decide para onde ir com base na autenticação
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});
  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> with WidgetsBindingObserver {
  SessionTimeoutManager? _sessionManager;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
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
    WidgetsBinding.instance.removeObserver(this);
    _sessionManager?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.isAuthenticated) {
      if (state == AppLifecycleState.paused ||
          state == AppLifecycleState.inactive) {
        _sessionManager?.appToBackground();
      } else if (state == AppLifecycleState.resumed) {
        _sessionManager?.appToForeground();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (authProvider.isLoading) {
      return const SplashLogin(); // pode ser um loader ou splash
    }

    if (authProvider.isAuthenticated) {
      return const HomePageWrapper();
    } else {
      return const Login();
    }
  }
}

// 🏠 Wrapper que inicializa AppSize antes da HomePage
class HomePageWrapper extends StatelessWidget {
  const HomePageWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    AppSize.init(context);
    return const HomePage();
  }
}
