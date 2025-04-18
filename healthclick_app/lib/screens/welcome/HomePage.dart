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
      var url = Uri.parse('http://192.168.100.139:8000/api/categories');
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        List<dynamic> data = jsonData['categories'];

        setState(() {
          categories = data.map((category) {
            return {
              "name": category['category_name'],
            };
          }).toList();
        });
      }
    }catch (e) {
      print('Erro: $e');
      throw Exception('Falha ao carregar categorias');
    }
  }

  final String baseUrl = 'http://192.168.100.139:8000/api/products';
  List<Map<String, dynamic>> products = [];

  Future<void> getProducts() async {
    try {
      var url = Uri.parse('http://192.168.100.139:8000/api/products');
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        List<dynamic> data = jsonData['products'];

        setState(() {
          products = data.take(2).map((product) {
            // Imprima o caminho para debug
            print(
                'Caminho da imagem: http://192.168.100.139:8000/storage/${product['product_file']}');

            return {
              "name": product['product_name'],
              "price": product['product_price'],
              "description": product['product_description'],
              "image":
                  'http://192.168.100.139:8000/storage/${product['product_file']}',
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
    return Scaffold(
      body: SingleChildScrollView(
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
              const SizedBox(height: 30),

              TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(30), // Aumenta o arredondamento
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(
                        color:
                            Colors.grey), // Cor da borda quando não está focado
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide:
                        const BorderSide(color: Colors.blue), // Cor da borda ao focar
                  ),
                  hintText: 'Pesquisar o Produto',
                  prefixIcon: const Icon(Icons.search),
                ),
              ),
              const SizedBox(height: 30),
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
              const SizedBox(height: 50),

              // Categories Section
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Categorias',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                ],
              ),
              const SizedBox(height: 20),

              // Category Cards Section
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: categories.isEmpty 
                      ? [Center(child: CircularProgressIndicator())]
                      : categories.asMap().entries.map((entry) {
                          int index = entry.key;
                          Map<String, dynamic> category = entry.value;
                          return Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                width: 140,
                                height: 55,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEFF5F6),
                                  borderRadius: BorderRadius.circular(20),
                                  // border: Border.all( width: 1.5),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black,
                                      blurRadius: 10,
                                      spreadRadius: 1,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ListTile(
                                  leading: const Icon(Icons.category,
                                      color: Colors.black),
                                  title: Text(
                                    category['name'] ?? 'Sem nome',
                                    style: const TextStyle(color: Colors.black),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                ),
              ),

              const SizedBox(height: 30),

              // Products Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Produtos',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
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
              const SizedBox(height: 20),

              // Product section
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                            builder: (_) => ProductDetails(product: product)),
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
                              errorBuilder: (context, error, stackTrace) {
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
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "${product['price']} MZN",
                                  style: const TextStyle(
                                      fontSize: 14, color: Colors.blue),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    // Adicionar ao carrinho
                                  },
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
      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentIndex,
        onTap: _onTap,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        child: const Icon(Icons.shopping_cart, color: Colors.white),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Cart()),
          );
        },
      ),
    );
  }
}