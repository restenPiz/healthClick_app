// ignore_for_file: prefer_const_constructors

import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:healthclick_app/models/CartProvider.dart';
import 'package:healthclick_app/screens/cart/Cart.dart';
import 'package:healthclick_app/screens/layouts/AppBottom.dart';
import 'package:healthclick_app/screens/pharmacy/PharmacyDetails.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';

class Pharmacy extends StatefulWidget {
  const Pharmacy({super.key});

  @override
  State<Pharmacy> createState() => _PharmacyState();
}

class _PharmacyState extends State<Pharmacy> {
  int _currentIndex = 2;
  bool _isLoading =
      false; // Adicionando um estado para controlar o carregamento

  List<Map<String, dynamic>> pharmacies = [];

  Future<void> getPharmacies() async {
    setState(() {
      _isLoading = true; // Ativar indicador de carregamento
    });

    try {
      var url = Uri.parse('http://cloudev.org/api/pharmacies');
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        List<dynamic> data = jsonData['pharmacies'];

        setState(() {
          pharmacies = data.map((pharmacy) {
            return {
              "id": pharmacy['id'],
              "name": pharmacy['pharmacy_name'],
              "location": pharmacy['pharmacy_location'],
              "contact": pharmacy['pharmacy_contact'],
              "image": pharmacy['pharmacy_file'],
              "description": pharmacy['pharmacy_description'],
              "userEmail": pharmacy['user']['email'],
              "userName": pharmacy['user']['name'],
            };
          }).toList();
          _isLoading = false; // Desativar indicador de carregamento
        });
      } else {
        setState(() {
          _isLoading = false; // Desativar indicador mesmo em caso de erro
        });
        throw Exception('Falha ao carregar farmácias: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _isLoading = false; // Desativar indicador mesmo em caso de erro
      });
      print('Erro: $e');
      throw Exception('Falha ao carregar farmácias');
    }
  }

  void _onTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    getPharmacies();
  }

  @override
  Widget build(BuildContext context) {
    User? currentUser = FirebaseAuth.instance.currentUser;
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      body: CustomRefreshIndicator(
        // Configurando opções similares à página de produtos
        onRefresh: () async {
          return getPharmacies();
        },
        trigger: IndicatorTrigger.leadingEdge,
        builder: (
          BuildContext context,
          Widget child,
          IndicatorController controller,
        ) {
          return Stack(
            children: <Widget>[
              child,
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: AnimatedOpacity(
                  opacity: controller.value > 0.0 ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Container(
                    height: 80,
                    alignment: Alignment.center,
                    child: controller.state == IndicatorState.loading
                        ? const CircularProgressIndicator(color: Colors.green)
                        : const Icon(Icons.arrow_downward, color: Colors.green),
                  ),
                ),
              ),
            ],
          );
        },
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 25),
                ListTile(
                  leading: CircleAvatar(
                    radius: 25,
                    backgroundImage: currentUser?.photoURL != null
                        ? NetworkImage(currentUser!.photoURL!)
                        : const AssetImage("assets/dif.jpg") as ImageProvider,
                  ),
                  title: Text(
                    "Olá ${currentUser?.displayName ?? currentUser?.email?.split('@')[0] ?? 'Visitante'}",
                    style: const TextStyle(
                        fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Farmácias Próximas",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                _isLoading
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: CircularProgressIndicator(color: Colors.green),
                        ),
                      )
                    : pharmacies.isEmpty
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20.0),
                              child: Text(
                                'Nenhuma farmácia encontrada',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: pharmacies.length,
                            itemBuilder: (context, index) {
                              final pharmacy = pharmacies[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    radius: 25,
                                    backgroundImage: pharmacy['image'] != null
                                        ? NetworkImage(
                                            'http://cloudev.org/storage/${pharmacy['image']}')
                                        : AssetImage(
                                                'assets/images/default_pharmacy.png')
                                            as ImageProvider,
                                  ),
                                  title: Text(
                                    pharmacy['name']!,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Text(
                                      'Proprietário: ${pharmacy['userName']!}'),
                                  trailing: const Icon(Icons.chevron_right),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => PharmacyDetails(
                                              pharmacy: pharmacy)),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentIndex,
        onTap: _onTap,
      ),
      floatingActionButton: Stack(
        alignment: Alignment.topRight,
        children: [
          FloatingActionButton(
            backgroundColor: Colors.green,
            child: const Icon(Icons.shopping_cart, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const Cart()),
              );
            },
          ),
          if (cart.itemCount > 0)
            Positioned(
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(10),
                ),
                constraints: const BoxConstraints(
                  minWidth: 18,
                  minHeight: 18,
                ),
                child: Text(
                  '${cart.itemCount}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
