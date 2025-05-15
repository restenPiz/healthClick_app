import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:healthclick_app/models/CartProvider.dart';
import 'package:healthclick_app/screens/cart/Cart.dart';
import 'package:healthclick_app/screens/layouts/AppBottom.dart';
import 'package:healthclick_app/screens/product/ProductDetails.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class ProductCategory extends StatefulWidget {
  const ProductCategory({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  final int categoryId;
  final String categoryName;

  @override
  State<ProductCategory> createState() => _ProductCategoryState();
}

class _ProductCategoryState extends State<ProductCategory> {
  List<Map<String, dynamic>> filteredProducts = [];
  List<Map<String, dynamic>> products = [];
  int _currentIndex = 1;
  late String baseUrl;
  bool _isLoading = true;

  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    baseUrl = 'http://cloudev.org/api/products/category/${widget.categoryId}';
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

  Future<void> getProducts() async {
    setState(() => _isLoading = true);
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
              "image": 'http://cloudev.org/storage/${product['product_file']}',
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
        throw Exception('Falha ao carregar produtos: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro: $e');
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar produtos: $e')),
      );
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

  void _onTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _addToCart(Map<String, dynamic> product, BuildContext context) {
    try {
      final String productId = product['id']?.toString() ??
          DateTime.now().millisecondsSinceEpoch.toString();
      final String name = product['name'] ?? 'Produto';
      final double price =
          product['price'] is num ? (product['price'] as num).toDouble() : 0.0;
      final String image = product['image'] ?? '';

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
    User? currentUser = FirebaseAuth.instance.currentUser;
    final cart = Provider.of<CartProvider>(context);
    final Size screenSize = MediaQuery.of(context).size;

    final bool isSmallScreen = screenSize.width < 600;
    final bool isMediumScreen =
        screenSize.width >= 600 && screenSize.width < 900;

    int crossAxisCount = isSmallScreen
        ? 2
        : isMediumScreen
            ? 3
            : 4;
    double childAspectRatio = isSmallScreen
        ? 0.55
        : isMediumScreen
            ? 0.65
            : 0.7;

    return Scaffold(
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(screenSize.width * 0.04),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: screenSize.height * 0.01),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          radius: isSmallScreen ? 20 : 25,
                          backgroundImage: currentUser?.photoURL != null
                              ? NetworkImage(currentUser!.photoURL!)
                              : const AssetImage("assets/dif.jpg")
                                  as ImageProvider,
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
                        'Todos Produtos',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: isSmallScreen ? 15 : 17),
                      ),
                      SizedBox(height: screenSize.height * 0.015),
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
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    searchController.clear();
                                    _filterProducts('');
                                  },
                                )
                              : null,
                          contentPadding: EdgeInsets.symmetric(
                              vertical: isSmallScreen ? 10 : 15,
                              horizontal: isSmallScreen ? 15 : 20),
                        ),
                        onChanged: _filterProducts,
                      ),
                      SizedBox(height: screenSize.height * 0.015),
                      filteredProducts.isEmpty
                          ? Center(
                              child: Padding(
                                padding:
                                    EdgeInsets.all(screenSize.width * 0.05),
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
                                crossAxisCount: crossAxisCount,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                                childAspectRatio: childAspectRatio,
                              ),
                              itemCount: filteredProducts.length,
                              itemBuilder: (context, index) {
                                final product = filteredProducts[index];
                                return ProductCard(
                                  product: product,
                                  context: context,
                                  onAddToCart: () =>
                                      _addToCart(product, context),
                                  isSmallScreen: isSmallScreen,
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

// ================== COMPONENTE DE CARD EXTRAÍDO ==================

class ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final BuildContext context;
  final Function onAddToCart;
  final bool isSmallScreen;

  const ProductCard({
    super.key,
    required this.product,
    required this.context,
    required this.onAddToCart,
    required this.isSmallScreen,
  });

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ProductDetails(product: product)),
        );
      },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenSize.width * 0.01,
                vertical: screenSize.height * 0.005,
              ),
              child: Text(
                product['category'] ?? 'Categoria',
                style: TextStyle(fontSize: isSmallScreen ? 11 : 13),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              flex: 5,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  product['image'],
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(Icons.broken_image,
                        size: isSmallScreen ? 80 : 120);
                  },
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(screenSize.width * 0.02),
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
            Divider(thickness: 1, indent: 10, endIndent: 10),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenSize.width * 0.02,
                vertical: screenSize.height * 0.005,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${product['price']} MZN",
                    style: TextStyle(
                        fontSize: isSmallScreen ? 12 : 14, color: Colors.blue),
                  ),
                  ElevatedButton(
                    onPressed: () => onAddToCart(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: const CircleBorder(),
                      padding: EdgeInsets.all(isSmallScreen ? 6 : 8),
                    ),
                    child: Icon(
                      Icons.add,
                      color: Colors.white,
                      size: isSmallScreen ? 16 : 20,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
