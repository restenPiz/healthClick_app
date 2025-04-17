import 'package:flutter/material.dart';
import 'package:healthclick_app/screens/welcome/HomePage.dart';
import 'package:geolocator/geolocator.dart';

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
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    "assets/back.png",
                    width: 500,
                    height: 400,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Bem Vindo ao Aplicativo SaúdeClick',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Este é um aplicativo criado para atender à demanda por medicamentos em Moçambique e outros países. O aplicativo visa automatizar os processos de compra e entrega de medicamentos a pacientes ou beneficiários.',
                style: TextStyle(fontSize: 15),
                textAlign: TextAlign.justify,
              ),
              const SizedBox(height: 20),
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
                    padding: const EdgeInsets.symmetric(vertical: 20),
                  ),
                  child: const Text(
                    'Próximo',
                    style: TextStyle(fontSize: 20),
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
