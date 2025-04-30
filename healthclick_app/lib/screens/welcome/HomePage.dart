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


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<String> imageList = [
    // "assets/background.jpg",
    "assets/back2.jpg",
    "assets/back3.jpg",
    "assets/back2.jpg",
    "assets/back3.jpg",
  ];

  List<Map<String, dynamic>> categories = [];
  Future<void> getCategories() async {
    try {
      var url = Uri.parse('http://cloudev.org/api/categories');
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
    }catch (e) {
      print('Erro: $e');
      throw Exception('Falha ao carregar categorias');
    }
  }

  final String baseUrl = 'http://cloudev.org/api/products';
  List<Map<String, dynamic>> products = [];

  Future<void> getProducts() async {
    try {
      var url = Uri.parse('http://cloudev.org/api/products');
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        List<dynamic> data = jsonData['products'];

        setState(() {
          products = data.take(2).map((product) {
            // Imprima o caminho para debug
            print(
                'Caminho da imagem: http://cloudev.org/storage/${product['product_file']}');

            return {
              "name": product['product_name'],
              "price": product['product_price'],
              "description": product['product_description'],
              "image":
                  'http://cloudev.org/storage/${product['product_file']}',
              "quantity": product['quantity'],
              "category": product['category'] != null
                  ? product['category']['category_name']
                  : 'Sem categoria',
            };
          }).toList();
          // filteredProducts = List.from(products); 
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
      // Imprimir dados para depuração
      print('Dados do produto: $product');

      // Verificar e obter valores com segurança
      final String productId = product['id']?.toString() ??
          DateTime.now().millisecondsSinceEpoch.toString();
      final String name = product['name']?.toString() ?? 'Produto';
      final double price =
          product['price'] is num ? (product['price'] as num).toDouble() : 0.0;
      final String image = product['image']?.toString() ?? '';

      // Registrar valores para depuração
      print('ID usado: $productId');
      print('Nome usado: $name');
      print('Preço usado: $price');
      print('Imagem usada: $image');

      // Adicionar ao carrinho
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
      User? currentUser = FirebaseAuth.instance.currentUser;
    final cart = Provider.of<CartProvider>(context);
    return Scaffold(
      
      body: CustomRefreshIndicator(
        onRefresh: () async {
          // Aqui você deve chamar todos os métodos de atualização necessários
          // Por exemplo, se você tiver métodos para carregar categorias e produtos:
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
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                // User Greeting Section
                ListTile(
                  leading: CircleAvatar(
                    radius: 25,
                    backgroundImage: currentUser?.photoURL != null
                        ? NetworkImage(currentUser!.photoURL!)
                        : const AssetImage("assets/dif.jpg") as ImageProvider,
                  ),
                  title: Text(
                    "Olá ${currentUser?.displayName ?? currentUser?.email?.split('@')[0] ?? 'Visitante'}",
                    style: const TextStyle(fontSize: 15),
                  ),
                  subtitle: const Text(
                    "O que você deseja?",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                  ),
                ),
                const SizedBox(height: 15),
                GFCarousel(
                  autoPlay: true,
                  autoPlayInterval: const Duration(seconds: 3),
                  items: imageList.map(
                    (url) {
                      return Container(
                        width: 500,
                        height: 250,
                        margin: const EdgeInsets.all(8.0),
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
                const SizedBox(height: 20),

                // Categories Section
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Categorias',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 17)),
                  ],
                ),
                const SizedBox(height: 20),

                // Category Cards Section
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: categories.asMap().entries.map((entry) {
                      int index = entry.key;
                      Map<String, dynamic> category = entry.value;
                      // Calculando o tamanho aproximado do texto
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
                              // Usando IntrinsicWidth para que o container se ajuste ao conteúdo
                              width: null, // Remove a largura fixa
                              constraints: const BoxConstraints(
                                minWidth: 100, // Largura mínima para categorias com nomes curtos
                                maxWidth: 220, // Largura máxima para evitar cartões muito largos
                              ),
                              height: 55,
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
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min, // Importante para o tamanho se ajustar
                                  children: [
                                    const Icon(Icons.category, color: Colors.black),
                                    const SizedBox(width: 8), // Espaçamento entre o ícone e o texto
                                    Flexible(
                                      child: Text(
                                        categoryName,
                                        style: const TextStyle(color: Colors.black),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 8), // Espaçamento após o texto
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
                const SizedBox(height: 20),

                // Products Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Produtos',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 17)),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Product()),
                        );
                      },
                      child: const Text(
                        'Ver Todos',
                        style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                            fontSize: 17),
                      ),
                    ),
                  ],
                ),

                // Product section
                products.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: CircularProgressIndicator(color: Colors.green),
                        ),
                      )
                    : GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: 0.55,
                        ),
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          final product = products[index];

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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ListTile(
                                    leading: Text(
                                      product['category'] ?? 'Categoria',
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  ),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      product['image'],
                                      width: double.infinity,
                                      height: 150,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return const Icon(Icons.broken_image,
                                            size: 120);
                                      },
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      product['name'],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const Divider(
                                      thickness: 1, indent: 10, endIndent: 10),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "${product['price']} MZN",
                                          style: const TextStyle(
                                              fontSize: 14, color: Colors.blue),
                                        ),
                                        ElevatedButton(
                                          onPressed: () =>
                                              _addToCart(product, context),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green,
                                            shape: const CircleBorder(),
                                            padding: const EdgeInsets.all(8),
                                          ),
                                          child: const Icon(Icons.add,
                                              color: Colors.white),
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
