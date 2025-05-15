import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:healthclick_app/models/CartProvider.dart';
import 'package:healthclick_app/screens/cart/Cart.dart';
import 'package:healthclick_app/screens/layouts/AppBottom.dart';
import 'package:healthclick_app/screens/product/ProductDetails.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';

class Product extends StatefulWidget {
  const Product({super.key});

  @override
  State<Product> createState() => _ProductState();
}

class _ProductState extends State<Product> {
  final String baseUrl = 'https://cloudev.org/api/products';
  List<Map<String, dynamic>> products = [];
  List<Map<String, dynamic>> filteredProducts = [];
  int _currentIndex = 1;
  TextEditingController searchController = TextEditingController();
  bool _isLoading = false;

  Future<void> getProducts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      var url = Uri.parse(baseUrl);
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        List<dynamic> data = jsonData['products'];

        setState(() {
          products = data.map((product) {
            return {
              "id": product['id'],
              "name": product['product_name'],
              "price":
                  double.tryParse(product['product_price'].toString()) ?? 0.0,
              "description": product['product_description'],
              "image": 'https://cloudev.org/storage/${product['product_file']}',
              "quantity": product['quantity'],
              "category": product['category'] != null
                  ? product['category']['category_name']
                  : 'Sem categoria',
            };
          }).toList();
          filteredProducts = List.from(products);
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        throw Exception('Falha ao carregar produtos: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Erro: $e');
      throw Exception('Falha ao carregar produtos');
    }
  }

  void _filterProducts(String searchText) {
    setState(() {
      if (searchText.isEmpty) {
        filteredProducts = List.from(products);
      } else {
        filteredProducts = products.where((product) {
          final productName = product['name'].toString().toLowerCase();
          final categoryName = product['category'].toString().toLowerCase();
          final searchLower = searchText.toLowerCase();

          return productName.contains(searchLower) ||
              categoryName.contains(searchLower);
        }).toList();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    getProducts();

    searchController.addListener(() {
      _filterProducts(searchController.text);
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _onTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _addToCart(Map<String, dynamic> product, BuildContext context) {
    try {
      final String productId = product['id']?.toString() ??
          DateTime.now().millisecondsSinceEpoch.toString();
      final String name = product['name']?.toString() ?? 'Produto';
      final double price =
          product['price'] is num ? (product['price'] as num).toDouble() : 0.0;
      final String image = product['image']?.toString() ?? '';

      final cart = Provider.of<CartProvider>(context, listen: false);
      cart.addItem(productId, name, price, image);

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Produto adicionado ao carrinho!'),
          duration: const Duration(seconds: 2),
          action: SnackBarAction(
            label: 'DESFAZER',
            onPressed: () {
              cart.removeSingleItem(productId);
            },
          ),
        ),
      );
    } catch (e) {
      print('Erro ao adicionar ao carrinho: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao adicionar ao carrinho: $e'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions for responsive layout
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360;
    final isMediumScreen = screenSize.width >= 360 && screenSize.width < 600;
    final isLargeScreen = screenSize.width >= 600;

    // Calculate responsive values
    final double horizontalPadding = isSmallScreen ? 8.0 : 16.0;
    final int gridCrossAxisCount = isLargeScreen ? 3 : 2;
    final double childAspectRatio =
        isSmallScreen ? 0.50 : (isLargeScreen ? 0.65 : 0.55);
    final double verticalSpacing = isSmallScreen ? 10.0 : 20.0;
    final double titleFontSize = isSmallScreen ? 15.0 : 17.0;

    User? currentUser = FirebaseAuth.instance.currentUser;
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      body: CustomRefreshIndicator(
        onRefresh: () async {
          return getProducts();
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
                    height: isSmallScreen ? 60 : 80,
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
          child: Padding(
            padding: EdgeInsets.all(horizontalPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: screenSize.height * 0.02),

                // User greeting - Responsive
                ListTile(
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
                  ),
                ),

                SizedBox(height: screenSize.height * 0.025),

                // Title - Responsive
                Text(
                  'Todos Produtos',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: titleFontSize),
                ),

                SizedBox(height: verticalSpacing),

                // Search field - Responsive
                TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: const BorderSide(color: Colors.blue),
                    ),
                    hintText: 'Pesquisar o Produto',
                    hintStyle: TextStyle(fontSize: isSmallScreen ? 13 : 14),
                    prefixIcon: Icon(
                      Icons.search,
                      size: isSmallScreen ? 20 : 24,
                    ),
                    suffixIcon: searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              Icons.clear,
                              size: isSmallScreen ? 20 : 24,
                            ),
                            onPressed: () {
                              searchController.clear();
                              _filterProducts('');
                            },
                          )
                        : null,
                    contentPadding: EdgeInsets.symmetric(
                      vertical: isSmallScreen ? 8.0 : 16.0,
                      horizontal: isSmallScreen ? 12.0 : 16.0,
                    ),
                  ),
                  style: TextStyle(
                    fontSize: isSmallScreen ? 14 : 16,
                  ),
                  onChanged: _filterProducts,
                ),

                SizedBox(height: verticalSpacing),

                // Product grid or loading/empty indicator - Responsive
                _isLoading
                    ? Center(
                        child: Padding(
                          padding: EdgeInsets.all(screenSize.height * 0.02),
                          child: const CircularProgressIndicator(
                              color: Colors.green),
                        ),
                      )
                    : filteredProducts.isEmpty
                        ? Center(
                            child: Padding(
                              padding: EdgeInsets.all(screenSize.height * 0.02),
                              child: Text(
                                'Nenhum produto encontrado',
                                style: TextStyle(
                                    fontSize: isSmallScreen ? 14 : 16),
                              ),
                            ),
                          )
                        : GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: gridCrossAxisCount,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                              childAspectRatio: childAspectRatio,
                            ),
                            itemCount: filteredProducts.length,
                            itemBuilder: (context, index) {
                              final product = filteredProducts[index];

                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            ProductDetails(product: product)),
                                  );
                                },
                                child: Card(
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Category tile - Responsive
                                      ListTile(
                                        dense: isSmallScreen,
                                        leading: Text(
                                          product['category'] ?? 'Categoria',
                                          style: TextStyle(
                                              fontSize:
                                                  isSmallScreen ? 11 : 13),
                                        ),
                                      ),

                                      // Product image - Responsive
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.network(
                                          product['image'],
                                          width: double.infinity,
                                          height: isSmallScreen
                                              ? 120
                                              : (isLargeScreen ? 180 : 150),
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return Icon(Icons.broken_image,
                                                size:
                                                    isSmallScreen ? 100 : 120);
                                          },
                                        ),
                                      ),

                                      // Product name - Responsive
                                      Padding(
                                        padding: EdgeInsets.all(
                                            isSmallScreen ? 6.0 : 8.0),
                                        child: Text(
                                          product['name'],
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: isSmallScreen ? 13 : 15,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),

                                      // Divider - Responsive
                                      Divider(
                                          thickness: 1,
                                          indent: isSmallScreen ? 8 : 10,
                                          endIndent: isSmallScreen ? 8 : 10),

                                      // Price and add button - Responsive
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal:
                                                isSmallScreen ? 6.0 : 8.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "${product['price']} MZN",
                                              style: TextStyle(
                                                  fontSize:
                                                      isSmallScreen ? 12 : 14,
                                                  color: Colors.blue),
                                            ),
                                            ElevatedButton(
                                              onPressed: () =>
                                                  _addToCart(product, context),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.green,
                                                shape: const CircleBorder(),
                                                padding: EdgeInsets.all(
                                                    isSmallScreen ? 6 : 8),
                                              ),
                                              child: Icon(
                                                Icons.add,
                                                color: Colors.white,
                                                size: isSmallScreen ? 18 : 24,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
              ],
            ),
          ),
        ),
      ),

      // Bottom navigation - Kept as is since AppBottomNav should handle responsiveness internally
      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentIndex,
        onTap: _onTap,
      ),

      // Shopping cart fab - Responsive
      floatingActionButton: Stack(
        alignment: Alignment.topRight,
        children: [
          FloatingActionButton(
            backgroundColor: Colors.green,
            child: Icon(
              Icons.shopping_cart,
              color: Colors.white,
              size: isSmallScreen ? 20 : 24,
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
                padding: const EdgeInsets.all(2),
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
