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

    // Get screen dimensions
    final Size screenSize = MediaQuery.of(context).size;
    final bool isSmallScreen = screenSize.width < 600;
    final bool isMediumScreen =
        screenSize.width >= 600 && screenSize.width < 900;

    return Scaffold(
      body: CustomRefreshIndicator(
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
                    height: screenSize.height * 0.08,
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
        child: SafeArea(
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding:
                  EdgeInsets.all(screenSize.width * 0.04), // Responsive padding
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: screenSize.height * 0.01),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      radius: isSmallScreen ? 20 : 25,
                      backgroundImage: currentUser?.photoURL != null
                          ? NetworkImage(currentUser!.photoURL!)
                          : const AssetImage("assets/dif.jpg") as ImageProvider,
                    ),
                    title: Text(
                      "Olá ${currentUser?.displayName ?? currentUser?.email?.split('@')[0] ?? 'Visitante'}",
                      style: TextStyle(
                          fontSize: isSmallScreen ? 15 : 17,
                          fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(height: screenSize.height * 0.02),
                  Text(
                    "Farmácias Próximas",
                    style: TextStyle(
                        fontSize: isSmallScreen ? 16 : 18,
                        fontWeight: FontWeight.bold),
                  ),
                  _isLoading
                      ? Center(
                          child: Padding(
                            padding: EdgeInsets.all(screenSize.width * 0.05),
                            child:
                                CircularProgressIndicator(color: Colors.green),
                          ),
                        )
                      : pharmacies.isEmpty
                          ? Center(
                              child: Padding(
                                padding:
                                    EdgeInsets.all(screenSize.width * 0.05),
                                child: Text(
                                  'Nenhuma farmácia encontrada',
                                  style: TextStyle(
                                      fontSize: isSmallScreen ? 14 : 16),
                                ),
                              ),
                            )
                          : isMediumScreen || !isSmallScreen
                              // Grid view for medium and large screens
                              ? GridView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: isMediumScreen ? 2 : 3,
                                    childAspectRatio: 3.5,
                                    crossAxisSpacing: 8,
                                    mainAxisSpacing: 8,
                                  ),
                                  itemCount: pharmacies.length,
                                  itemBuilder: (context, index) {
                                    return PharmacyCard(
                                      pharmacy: pharmacies[index],
                                      isSmallScreen: isSmallScreen,
                                    );
                                  },
                                )
                              // List view for small screens (original layout)
                              : ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: pharmacies.length,
                                  itemBuilder: (context, index) {
                                    return PharmacyCard(
                                      pharmacy: pharmacies[index],
                                      isSmallScreen: isSmallScreen,
                                    );
                                  },
                                ),
                ],
              ),
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
            child: Icon(
              Icons.shopping_cart,
              color: Colors.white,
              size: isSmallScreen ? 22 : 24,
            ),
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
                padding: EdgeInsets.all(screenSize.width * 0.005),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(10),
                ),
                constraints: BoxConstraints(
                  minWidth: isSmallScreen ? 16 : 18,
                  minHeight: isSmallScreen ? 16 : 18,
                ),
                child: Text(
                  '${cart.itemCount}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isSmallScreen ? 10 : 12,
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

class PharmacyCard extends StatelessWidget {
  final Map<String, dynamic> pharmacy;
  final bool isSmallScreen;

  const PharmacyCard({
    super.key,
    required this.pharmacy,
    required this.isSmallScreen,
  });

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return Card(
      margin: EdgeInsets.symmetric(vertical: screenSize.height * 0.01),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 12),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
          horizontal: screenSize.width * 0.03,
          vertical: screenSize.height * 0.005,
        ),
        leading: CircleAvatar(
          radius: isSmallScreen ? 20 : 25,
          backgroundImage: pharmacy['image'] != null
              ? NetworkImage('http://cloudev.org/storage/${pharmacy['image']}')
              : AssetImage('assets/images/default_pharmacy.png')
                  as ImageProvider,
        ),
        title: Text(
          pharmacy['name']!,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isSmallScreen ? 14 : 16,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          'Proprietário/a: ${pharmacy['userName']!}',
          style: TextStyle(
            fontSize: isSmallScreen ? 12 : 14,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Icon(
          Icons.chevron_right,
          size: isSmallScreen ? 22 : 24,
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => PharmacyDetails(pharmacy: pharmacy)),
          );
        },
      ),
    );
  }
}
