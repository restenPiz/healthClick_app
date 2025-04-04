import 'package:flutter/material.dart';
import 'package:healthclick_app/screens/product/Product.dart';
import 'package:healthclick_app/screens/welcome/HomePage.dart';

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
  final List<Widget> _screens = [
    const HomePage(), // Página "Início"
    const Product(), // Página "Medicamentos"
  ];
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex:
          widget.currentIndex, // Usando o currentIndex passado como parâmetro
      onTap: (index) {
        widget.onTap(
            index); // Atualiza o índice atual e navega para a página correspondente
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  _screens[index]), // Redireciona para a página selecionada
        );
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
          icon: Icon(Icons.shopping_cart),
          label: 'Carrinho',
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
          label: 'Perfil',
        ),
      ],
    );
  }
}
