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
import 'package:cached_network_image/cached_network_image.dart'; // Importando CachedNetworkImage

class Pharmacy extends StatefulWidget {
  const Pharmacy({super.key});

  @override
  State<Pharmacy> createState() => _PharmacyState();
}

class _PharmacyState extends State<Pharmacy> {
  int _currentIndex = 2;
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';

  List<Map<String, dynamic>> pharmacies = [];
  final int _itemsPerPage = 5; // Número de farmácias carregadas por vez
  int _currentPage = 1;
  bool _hasMoreData = true;
  bool _isLoadingMore = false;

  final ScrollController _scrollController = ScrollController();

  Future<void> getPharmacies({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _currentPage = 1;
        _hasMoreData = true;
        pharmacies.clear();
        _hasError = false;
        _errorMessage = '';
      });
    }

    if (!_hasMoreData || _isLoadingMore) return;

    setState(() {
      refresh ? _isLoading = true : _isLoadingMore = true;
    });

    try {
      // Adicionando parâmetros de paginação à URL
      var url = Uri.parse(
          'http://cloudev.org/api/pharmacies?page=$_currentPage&per_page=$_itemsPerPage');
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        List<dynamic> data = jsonData['pharmacies'];

        // Verificar se tem mais dados para carregar
        _hasMoreData = data.length >= _itemsPerPage;

        if (data.isNotEmpty) {
          setState(() {
            List<Map<String, dynamic>> newPharmacies = data.map((pharmacy) {
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

            pharmacies.addAll(newPharmacies);
            _currentPage++;
          });
        }
      } else {
        setState(() {
          _hasError = true;
          _errorMessage = 'Falha ao carregar farmácias: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Erro na conexão: $e';
      });
      print('Erro: $e');
    } finally {
      setState(() {
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  void _onTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !_isLoadingMore &&
          _hasMoreData) {
        getPharmacies();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    getPharmacies(refresh: true);
    _setupScrollListener();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
          return getPharmacies(refresh: true);
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
                //*Improve better user experience with animated opacity
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
          child: Padding(
            padding: EdgeInsets.all(screenSize.width * 0.04),
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
                        ? CachedNetworkImageProvider(currentUser!.photoURL!)
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
                _buildPharmaciesList(isSmallScreen, isMediumScreen, screenSize),
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

  Widget _buildPharmaciesList(
      bool isSmallScreen, bool isMediumScreen, Size screenSize) {
    if (_isLoading && pharmacies.isEmpty) {
      return const Expanded(
        child: Center(
          child: CircularProgressIndicator(color: Colors.green),
        ),
      );
    }

    if (_hasError) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _errorMessage,
                style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                //*Method on pressed to get the pharmacies again
                onPressed: () => getPharmacies(refresh: true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text('Tentar novamente',
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }

    if (pharmacies.isEmpty) {
      return Expanded(
        child: Center(
          child: Text(
            'Nenhuma farmácia encontrada',
            style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
          ),
        ),
      );
    }

    // Definir o widget de lista apropriado com base no tamanho da tela
    Widget pharmaciesListWidget;
    if (isMediumScreen || !isSmallScreen) {
      // Grid view para telas médias e grandes
      pharmaciesListWidget = GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
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
      );
    } else {
      // Lista para telas pequenas
      pharmaciesListWidget = ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: pharmacies.length,
        itemBuilder: (context, index) {
          return PharmacyCard(
            pharmacy: pharmacies[index],
            isSmallScreen: isSmallScreen,
          );
        },
      );
    }

    return Expanded(
      child: ListView(
        controller: _scrollController,
        children: [
          pharmaciesListWidget,
          if (_isLoadingMore)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Center(
                child: CircularProgressIndicator(color: Colors.green),
              ),
            ),
          if (!_hasMoreData && pharmacies.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Center(
                child: Text(
                  'Você chegou ao fim da lista',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: isSmallScreen ? 12 : 14,
                  ),
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
        leading: pharmacy['image'] != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(isSmallScreen ? 20 : 25),
                child: CachedNetworkImage(
                  imageUrl: 'http://cloudev.org/storage/${pharmacy['image']}',
                  width: isSmallScreen ? 40 : 50,
                  height: isSmallScreen ? 40 : 50,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => CircleAvatar(
                    radius: isSmallScreen ? 20 : 25,
                    backgroundColor: Colors.grey[300],
                    child: Icon(Icons.local_pharmacy, color: Colors.grey[500]),
                  ),
                  errorWidget: (context, url, error) => CircleAvatar(
                    radius: isSmallScreen ? 20 : 25,
                    backgroundColor: Colors.grey[300],
                    child: const Icon(Icons.error, color: Colors.red),
                  ),
                ),
              )
            : CircleAvatar(
                radius: isSmallScreen ? 20 : 25,
                backgroundColor: Colors.grey[300],
                child: Icon(Icons.local_pharmacy, color: Colors.grey[500]),
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
