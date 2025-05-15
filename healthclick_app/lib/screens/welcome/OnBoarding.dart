import 'package:flutter/material.dart';
import 'package:healthclick_app/screens/welcome/HomePage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:healthclick_app/utils/app_size.dart'; // Importando a classe AppSize

class OnBoarding extends StatefulWidget {
  const OnBoarding({super.key});

  @override
  State<OnBoarding> createState() => _OnBoardingState();
}

class _OnBoardingState extends State<OnBoarding> {
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _fetchLocation();
  }

  //* Método que chama o getUserLocation e atualiza o estado
  void _fetchLocation() async {
    try {
      Position position = await getUserLocation();
      setState(() {
        _currentPosition = position;
      });

      debugPrint("Localização: ${position.latitude}, ${position.longitude}");
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao obter localização: $e')),
      );
    }
  }

  //* Método que captura a localização do usuário
  Future<Position> getUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Serviço de localização desativado');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Permissão negada');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Permissão negada permanentemente');
    }

    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  @override
  Widget build(BuildContext context) {
    // Inicializando a classe AppSize para tornar a interface responsiva
    AppSize.init(context);

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(AppSize.wp(4)), // Utilizando AppSize para margens responsivas
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppSize.wp(5)), // Responsividade nos arredondamentos
                  child: Image.asset(
                    "assets/back.png",
                    width: AppSize.wp(80), // Responsividade na largura
                    height: AppSize.hp(40), // Responsividade na altura
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height: AppSize.hp(2)), // Ajustando o espaçamento

              const Text(
                'Bem Vindo ao Aplicativo SaúdeClick',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: AppSize.hp(2)),

              const Text(
                'Este aplicativo foi desenvolvido com o objetivo de modernizar e facilitar o acesso a medicamentos em Moçambique e outros países em desenvolvimento. A plataforma conecta pacientes, farmácias e serviços de entrega, oferecendo uma solução integrada e eficiente para a aquisição de medicamentos.O aplicativo permite que os usuários pesquisem medicamentos, consultem farmácias próximas, realizem pedidos online e acompanhem o status da entrega em tempo real. Além disso, oferece recursos como pagamentos digitais seguros e histórico de compras. ',
                style: TextStyle(fontSize: 15),
                textAlign: TextAlign.justify,
              ),
              SizedBox(height: AppSize.hp(3)),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const HomePage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: AppSize.hp(2)), // Ajustando a altura do botão
                  ),
                  child: Text(
                    'Próximo',
                    style: TextStyle(fontSize: AppSize.sp(20)), // Responsividade no texto
                  ),
                ),
              ),
              // const SizedBox(height: 20),
              // if (_currentPosition != null)
              //   Text(
              //     'Sua localização:\nLatitude: ${_currentPosition!.latitude}, Longitude: ${_currentPosition!.longitude}',
              //     style: const TextStyle(fontSize: 14, color: Colors.grey),
              //   ),
            ],
          ),
        ),
      ),
    );
  }
}
