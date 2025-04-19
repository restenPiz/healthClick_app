import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:healthclick_app/screens/auth/Login.dart';

class ProfileEdit extends StatefulWidget {
  const ProfileEdit({super.key});

  @override
  State<ProfileEdit> createState() => _ProfileEditState();
}

class _ProfileEditState extends State<ProfileEdit> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Preencher os campos com os dados atuais do usuário
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      _nameController.text = currentUser.displayName ?? currentUser.email?.split('@')[0] ?? '';
      _emailController.text = currentUser.email ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  // Método para atualizar o perfil
  Future<void> _updateProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // Atualizar o nome de exibição
        if (_nameController.text.trim() != user.displayName) {
          await user.updateDisplayName(_nameController.text.trim());
        }

        // Atualizar o email
        if (_emailController.text.trim() != user.email) {
          await user.updateEmail(_emailController.text.trim());
        }

        // Recarregar o usuário para obter os dados atualizados
        await user.reload();

        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Perfil atualizado com sucesso!')));

        Navigator.pop(context);
      }
    } catch (e) {
      String errorMessage = 'Erro ao atualizar o perfil.';

      if (e is FirebaseAuthException) {
        if (e.code == 'email-already-in-use') {
          errorMessage = 'Este email já está em uso.';
        } else if (e.code == 'invalid-email') {
          errorMessage = 'Email inválido.';
        } else if (e.code == 'requires-recent-login') {
          errorMessage =
              'Esta operação é sensível. Por favor, faça login novamente antes de tentar novamente.';
          // Opcionalmente, redirecione para a tela de login aqui
        }
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(errorMessage)));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    User? currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              //?Main Content
              ListTile(
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pop(context); // Voltar para a tela anterior
                  },
                ),
                title: const Text(
                  "Editar Perfil",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20),
                ),
              ),
              const SizedBox(height: 30),
              Center(
                child: CircleAvatar(
                  radius: 70,
                  backgroundImage: currentUser?.photoURL != null
                      ? NetworkImage(currentUser!.photoURL!)
                      : const AssetImage("assets/dif.jpg") as ImageProvider,
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  "${currentUser?.displayName ?? currentUser?.email?.split('@')[0] ?? 'Visitante'}",
                  style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: Text(
                  '${currentUser?.email ?? 'Visitante'}',
                  style: const TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 30),
              const Divider(
                thickness: 2,
                indent: 20,
                endIndent: 20,
              ),
              const SizedBox(height: 25),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(color: Colors.blue),
                  ),
                  hintText: currentUser?.displayName ??
                      currentUser?.email?.split('@')[0] ?? 'Escreva o seu nome',
                  prefixIcon: const Icon(Icons.person_2),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(color: Colors.blue),
                  ),
                  hintText: currentUser?.email ?? 'Escreva o seu email',
                  prefixIcon: const Icon(Icons.email),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _updateProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Actualizar Dados',
                          style: TextStyle(fontSize: 17),
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
