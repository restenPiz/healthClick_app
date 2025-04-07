import 'package:flutter/material.dart';
import 'package:healthclick_app/screens/pharmacy/Pharmacy.dart';
import 'package:healthclick_app/screens/product/Product.dart';
import 'package:healthclick_app/screens/welcome/HomePage.dart';
import 'package:healthclick_app/screens/profile/Profile.dart'; // Importe a tela de perfil

class AppBottomNav extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  _AppBottomNavState createState() => _AppBottomNavState();
}

class _AppBottomNavState extends State<AppBottomNav> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomePage(),
    const Product(),
    const Pharmacy(),
    const Profile(), // Adicionando a tela de perfil
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens, // As páginas que você deseja exibir
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex, // Acompanhar o índice da página atual
        onTap: (index) {
          setState(() {
            _currentIndex =
                index; // Atualiza o índice para navegar entre as páginas
          });
        },
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.medical_services),
            label: 'Medicamentos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_hospital),
            label: 'Farmácias',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil', // Novo item
          ),
        ],
      ),
    );
  }
}

