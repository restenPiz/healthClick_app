import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    final screenSize = MediaQuery.of(context).size;
    final bool isSmallScreen = screenSize.width < 600;

    final double avatarRadius = isSmallScreen ? 25 : 30;
    final double padding = screenSize.width * 0.04;
    final double titleFontSize = isSmallScreen ? 18 : 22;
    final double textFontSize = isSmallScreen ? 14 : 16;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: padding, vertical: padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Perfil
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
                  "Perguntas Frequentes",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ),
              const SizedBox(height: 24),

              ListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: const [
                  ExpansionTile(
                    title: Text("Como faço login?"),
                    children: [
                      Padding(
                        padding: EdgeInsets.all(12),
                        child: Text(
                            "Você pode fazer login com seu e-mail ou usar sua conta do Google. Vá para a tela inicial e clique em 'Entrar'."),
                      ),
                    ],
                  ),
                  ExpansionTile(
                    title: Text("Como adiciono produtos ao carrinho?"),
                    children: [
                      Padding(
                        padding: EdgeInsets.all(12),
                        child: Text(
                            "Navegue até um produto e clique no botão de adicionar '+' para incluí-lo no carrinho."),
                      ),
                    ],
                  ),
                  ExpansionTile(
                    title: Text("Como posso alterar meu perfil?"),
                    children: [
                      Padding(
                        padding: EdgeInsets.all(12),
                        child: Text(
                            "Vá até a aba de Perfil e clique em 'Editar Perfil' para atualizar seus dados."),
                      ),
                    ],
                  ),
                  ExpansionTile(
                    title: Text("Como altero para o modo escuro?"),
                    children: [
                      Padding(
                        padding: EdgeInsets.all(12),
                        child: Text(
                            "Na tela de perfil, ative o botão 'Dark Mode' para mudar o tema da aplicação."),
                      ),
                    ],
                  ),
                  ExpansionTile(
                    title: Text("Como entro em contato com o suporte?"),
                    children: [
                      Padding(
                        padding: EdgeInsets.all(12),
                        child: Text(
                            "Você pode entrar em contato conosco pelo WhatsApp (+258 867336817) ou e-mail (mauropeniel7@gmail.com)."),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Center(
                child: Text(
                  'Se ainda tiver dúvidas, entre em contato com nosso suporte.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: textFontSize),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
