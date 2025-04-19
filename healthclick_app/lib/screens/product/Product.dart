import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:healthclick_app/screens/layouts/AppBottom.dart';
import 'package:healthclick_app/screens/product/ProductDetails.dart';
import 'package:http/http.dart' as http;

class Product extends StatefulWidget {
  const Product({super.key});

  @override
  State<Product> createState() => _ProductState();
}

class _ProductState extends State<Product> {
  final String baseUrl = 'http://192.168.100.139:8000/api/products';
  List<Map<String, dynamic>> products = [];
  int _currentIndex = 1;

  Future<void> getProducts() async {
    try {
      var url = Uri.parse(baseUrl);
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        List<dynamic> data = jsonData['products'];

        setState(() {
          products = data.map((product) {
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
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
              const SizedBox(height: 30),
              const Text(
                'Todos Produtos',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
              ),
              const SizedBox(height: 20),
              TextField(
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
                ),
              ),
              const SizedBox(height: 20),
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
          // Ação ao abrir o carrinho
        },
      ),
    );
  }
}
