// import 'package:flutter/material.dart';
// import 'package:healthclick_app/models/CartProvider.dart';
// import 'package:healthclick_app/screens/auth/Login.dart';
// import 'package:provider/provider.dart';


// void main() {
//   runApp(
//     ChangeNotifierProvider(
//       create: (_) => CartProvider(),
//       child: const MyApp(),
//     ),
//   );
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'SaudeClick',
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
//         useMaterial3: true,
//       ),
//       home: const Login(),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // importa o arquivo que você gerou
import 'package:healthclick_app/models/CartProvider.dart';
import 'package:healthclick_app/screens/auth/Login.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => CartProvider(),
      child: const Login(),
    ),
  );
}
