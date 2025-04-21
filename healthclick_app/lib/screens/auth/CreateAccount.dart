// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:healthclick_app/screens/auth/Login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:healthclick_app/screens/welcome/OnBoarding.dart';
import 'dart:convert'; // para jsonEncode
import 'package:http/http.dart' as http; // para http.post

class CreateAccount extends StatefulWidget {
  const CreateAccount({super.key});

  @override
  State<CreateAccount> createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  
  //*Creating a attributes
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  //*Metodo to allow the user to signInWithGoogle account
  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return; // Cancelado

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logged in with Google')),
      );

      // Navegar para home
      // Navigator.pushReplacement(...);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google login failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isChecked = false;
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
              // const SizedBox(height: 20),

              //? Title and Input
              const Text(
                'Create An Account',
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
                    borderSide: const BorderSide(
                        color:
                            Colors.grey), // Cor da borda quando não está focado
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide:
                        const BorderSide(color: Colors.blue), // Cor da borda ao focar
                  ),
                  hintText: 'Your Email Address',
                  prefixIcon: const Icon(Icons.email),
                ),
              ),
              const SizedBox(height: 10),
              //? Password Field
              TextField(
                controller: passwordController,
                obscureText: true, // Hide password input
                decoration: InputDecoration(
                 border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(30), // Aumenta o arredondamento
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(
                        color:
                            Colors.grey), // Cor da borda quando não está focado
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide:
                        const BorderSide(color: Colors.blue), // Cor da borda ao focar
                  ),
                  hintText: 'Your Password',
                  prefixIcon: const Icon(Icons.lock),
                ),
              ),
              const SizedBox(height: 10),
              //? Password Field
              TextField(
                controller: confirmPasswordController,
                obscureText: true, // Hide password input
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(30), // Aumenta o arredondamento
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(
                        color:
                            Colors.grey), // Cor da borda quando não está focado
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide:
                        const BorderSide(color: Colors.blue), // Cor da borda ao focar
                  ),
                  hintText: 'Your Password Confirmation',
                  prefixIcon: const Icon(Icons.lock),
                ),
              ),
              const SizedBox(height: 15),
              //?Creating account section
              Center(child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Login()),
                  );
                },
                child: const Text(
                  "Already An Have An Account? Login",
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.red),
                ),
              ),),
              const SizedBox(height: 15),
              //?Login button section
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: double.infinity, // ✅ Makes button full width
                      child: ElevatedButton(
                        onPressed: () async {
                          if (passwordController.text != confirmPasswordController.text) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Passwords do not match')),
                            );
                            return;
                          }

                          try {
                            final email = emailController.text.trim();
                            final password = passwordController.text.trim();

                            // Cria o usuário no Firebase
                            final credential = await FirebaseAuth.instance
                                .createUserWithEmailAndPassword(email: email, password: password);

                            final user = FirebaseAuth.instance.currentUser;

                            if (user != null) {
                              final uid = user.uid;

                              // 🔁 Envia o UID e o email para o backend Laravel
                              final response = await http.post(
                                Uri.parse('http://192.168.100.139:8000/api/sync-firebase-uid'),
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
                            }

                            // Mostra sucesso e navega para a próxima tela
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Account created successfully')),
                            );

                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const OnBoarding()),
                            );
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
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        child: const Text(
                          'Sign Up',
                          style: TextStyle(fontSize: 17),
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text("Or Sign Up With"),
                    const SizedBox(height: 5),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: signInWithGoogle,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              "assets/google.png",
                              width: 24,
                              height: 24,
                            ),
                            const SizedBox(width: 10),
                            const Text(
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