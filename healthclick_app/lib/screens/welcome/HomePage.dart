import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:healthclick_app/models/CartProvider.dart';
import 'package:healthclick_app/screens/cart/Cart.dart';
import 'package:provider/provider.dart';
import 'package:healthclick_app/screens/layouts/AppBottom.dart';
import 'package:healthclick_app/screens/product/Product.dart';
import 'package:healthclick_app/screens/product/ProductDetails.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:healthclick_app/screens/product/ProductCategory.dart';
import 'package:healthclick_app/utils/app_size.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<String> imageList = [
    "assets/back2.jpg",
    "assets/back3.jpg",
    "assets/back2.jpg",
    "assets/back3.jpg",
  ];

  List<Map<String, dynamic>> categories = [];
  List<Map<String, dynamic>> products = [];

  Future<void> getCategories() async {
    try {
      var url = Uri.parse('https://cloudev.org/api/categories');
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        List<dynamic> data = jsonData['categories'];

        setState(() {
          categories = data.map((category) {
            return {
              "name": category['category_name'],
              "id": category['id']
            };
          }).toList();
        });
      }
    } catch (e) {
      print('Erro: $e');
      throw Exception('Falha ao carregar categorias');
    }
  }

  Future<void> getProducts() async {
    try {
      var url = Uri.parse('https://cloudev.org/api/products');
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        List<dynamic> data = jsonData['products'];

        setState(() {
          products = data.take(2).map((product) {
            return {
              "name": product['product_name'],
               "price":
                  double.tryParse(product['product_price'].toString()) ?? 0.0,
              "description": product['product_description'],
              "image": 'http://cloudev.org/storage/${product['product_file']}',
              "quantity": product['quantity'],
              "category": product['category'] != null
                  ? product['category']['category_name']
                  : 'Sem categoria',
            };
          }).toList();
        });
      } else {
        throw Exception('Falha ao carregar produtos: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro: $e');
      throw Exception('Falha ao carregar produtos');
    }
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
  void initState() {
    super.initState();
    getProducts();
    getCategories();
  }

  void _onTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360;
    final isMediumScreen = screenSize.width >= 360 && screenSize.width < 600;
    final isLargeScreen = screenSize.width >= 600;
    
    // Calculate responsive values
    final double horizontalPadding = isSmallScreen ? 8.0 : 16.0;
    final double carouselHeight = isSmallScreen ? 150.0 : (isMediumScreen ? 200.0 : 250.0);
    final int gridCrossAxisCount = isLargeScreen ? 3 : 2;
    final double childAspectRatio = isSmallScreen ? 0.50 : 0.55;
    
    User? currentUser = FirebaseAuth.instance.currentUser;
    final cart = Provider.of<CartProvider>(context);
    
    return Scaffold(
      body: CustomRefreshIndicator(
        onRefresh: () async {
          await getCategories();
          await getProducts();
          return;
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
                    height: AppSize.hp(10),
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
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: screenSize.height * 0.02),
                
                // User Greeting Section - Responsive
                ListTile(
                  leading: CircleAvatar(
                    radius: isSmallScreen ? 18 : 25,
                    backgroundImage: currentUser?.photoURL != null
                        ? NetworkImage(currentUser!.photoURL!)
                        : const AssetImage("assets/dif.jpg") as ImageProvider,
                  ),
                  title: Text(
                    "Olá ${currentUser?.displayName ?? currentUser?.email?.split('@')[0] ?? 'Visitante'}",
                    style: TextStyle(fontSize: isSmallScreen ? 13 : 15),
                  ),
                  subtitle: Text(
                    "O que você deseja?",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: isSmallScreen ? 15 : 17
                    ),
                  ),
                ),
                
                SizedBox(height: screenSize.height * 0.02),
                
                // Carousel - Responsive
                GFCarousel(
                  autoPlay: true,
                  autoPlayInterval: const Duration(seconds: 3),
                  items: imageList.map(
                    (url) {
                      return Container(
                        width: screenSize.width,
                        height: carouselHeight,
                        margin: EdgeInsets.all(isSmallScreen ? 4.0 : 8.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.asset(
                            url,
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  ).toList(),
                  onPageChanged: (index) {
                    setState(() {
                      // Handle page change if necessary
                    });
                  },
                ),
                
                SizedBox(height: screenSize.height * 0.025),

                // Categories Header - Responsive
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Categorias',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: isSmallScreen ? 15 : 17
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: screenSize.height * 0.015),

                // Category Cards Section - Responsive
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: categories.asMap().entries.map((entry) {
                      int index = entry.key;
                      Map<String, dynamic> category = entry.value;
                      String categoryName = category['name'] ?? 'Sem nome';
                      
                      return Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: GestureDetector(
                          onTap: () {
                            int categoryId = category['id'] ?? 0;
                            String categoryName = category['name'];

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ProductCategory(
                                  categoryId: categoryId,
                                  categoryName: categoryName,
                                ),
                              ),
                            );
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              constraints: BoxConstraints(
                                minWidth: isSmallScreen ? 80 : 100,
                                maxWidth: isSmallScreen ? 180 : 220,
                              ),
                              height: isSmallScreen ? 45 : 55,
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF5F6),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: const [
                                  BoxShadow(
                                    blurRadius: 10,
                                    spreadRadius: 1,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 6.0 : 8.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.category,
                                      color: Colors.black,
                                      size: isSmallScreen ? 16 : 24,
                                    ),
                                    SizedBox(width: isSmallScreen ? 4 : 8),
                                    Flexible(
                                      child: Text(
                                        categoryName,
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: isSmallScreen ? 12 : 14,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    SizedBox(width: isSmallScreen ? 4 : 8),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                
                SizedBox(height: screenSize.height * 0.025),

                // Products Section Header - Responsive
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Produtos',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: isSmallScreen ? 15 : 17
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Product()
                          ),
                        );
                      },
                      child: Text(
                        'Ver Todos',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: isSmallScreen ? 15 : 17
                        ),
                      ),
                    ),
                  ],
                ),

                // Product Grid - Responsive
                products.isEmpty
                    ? Center(
                        child: Padding(
                          padding: EdgeInsets.all(screenSize.height * 0.025),
                          child: const CircularProgressIndicator(color: Colors.green),
                        ),
                      )
                    : GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: gridCrossAxisCount,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: childAspectRatio,
                        ),
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          final product = products[index];

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ProductDetails(product: product)
                                ),
                              );
                            },
                            child: Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ListTile(
                                    dense: isSmallScreen,
                                    leading: Text(
                                      product['category'] ?? 'Categoria',
                                      style: TextStyle(fontSize: isSmallScreen ? 11 : 13),
                                    ),
                                  ),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      product['image'],
                                      width: double.infinity,
                                      height: isSmallScreen ? 120 : 150,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Icon(
                                          Icons.broken_image,
                                          size: isSmallScreen ? 100 : 120
                                        );
                                      },
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(isSmallScreen ? 6.0 : 8.0),
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
                                  Divider(
                                    thickness: 1,
                                    indent: isSmallScreen ? 8 : 10,
                                    endIndent: isSmallScreen ? 8 : 10
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isSmallScreen ? 6.0 : 8.0
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "${product['price']} MZN",
                                          style: TextStyle(
                                            fontSize: isSmallScreen ? 12 : 14,
                                            color: Colors.blue
                                          ),
                                        ),
                                        ElevatedButton(
                                          onPressed: () => _addToCart(product, context),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green,
                                            shape: const CircleBorder(),
                                            padding: EdgeInsets.all(isSmallScreen ? 6 : 8),
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