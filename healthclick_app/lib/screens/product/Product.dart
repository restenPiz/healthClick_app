// // ignore_for_file: prefer_const_constructors

// import 'package:flutter/material.dart';
// import 'package:getwidget/getwidget.dart';
// import 'package:healthclick_app/screens/layouts/AppBottom.dart';
// import 'package:healthclick_app/screens/product/ProductDetails.dart';
// import 'package:healthclick_app/services/echo_service.dart'; 

// class Product extends StatefulWidget {
//   const Product({super.key});

//   @override
//   State<Product> createState() => _ProductState();
// }

// class _ProductState extends State<Product> {
  
// final List<Map<String, String>> products = [
//     {
//       "image": "assets/back1.jpg",
//       "name": "Produto 1",
//     },
//     {
//       "image": "assets/back1.jpg",
//       "name": "Produto 2",
//     },
//     {
//       "image": "assets/back1.jpg",
//       "name": "Produto 3",
//     },
//     {
//       "image": "assets/back1.jpg",
//       "name": "Produto 1",
//     },
//     {
//       "image": "assets/back1.jpg",
//       "name": "Produto 2",
//     },
//     {
//       "image": "assets/back1.jpg",
//       "name": "Produto 3",
//     },
//     // Adicione mais produtos conforme necessário
//   ];
//   void listenToProductUpdates() {
//     echo.channel('products').listen('product.updated', (event) {
//       print('📦 Produto atualizado: $event');

//       setState(() {
//         // Aqui você pode atualizar a lista de produtos com os dados recebidos.
//         // Exemplo básico: adiciona o produto recebido
//         products.insert(0, {
//           "image": "assets/back1.jpg", // você pode adaptar para vir da API
//           "name": event['product']['name'],
//         });
//       });
//     });
//   }

//   int _currentIndex = 1;

//   void _onTap(int index) {
//     setState(() {
//       _currentIndex = index;
//     });
//   }

//    @override
//   void initState() {
//     super.initState();
//     setupEcho(); // Conecta ao WebSocket Laravel
//     listenToProductUpdates(); // Escuta eventos de atualização dos produtos
//   }
  
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SingleChildScrollView(
//         child: Padding(padding: EdgeInsets.all(16.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const ListTile(
//                 leading: CircleAvatar(
//                   radius: 25, // Adjust size
//                   backgroundImage: AssetImage("assets/dif.jpg"),
//                 ),
//                 title: Text(
//                   "Ola Mauro Peniel",
//                   style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
//                 ),
//               ),
//               const SizedBox(height: 30,),
//               const Text('Todos Productos',
//                   style: TextStyle( fontWeight: FontWeight.bold, fontSize: 17)
//               ),
//               const SizedBox(
//                 height: 20,
//               ),
//               TextField(
//                 decoration: InputDecoration(
//                   border: OutlineInputBorder(
//                     borderRadius:
//                         BorderRadius.circular(30), // Aumenta o arredondamento
//                   ),
//                   enabledBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(30),
//                     borderSide: BorderSide(
//                         color:
//                             Colors.grey), // Cor da borda quando não está focado
//                   ),
//                   focusedBorder:OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(30),
//                     borderSide:
//                         BorderSide(color: Colors.blue), // Cor da borda ao focar
//                   ),
//                   hintText: 'Pesquisar o Produto',
//                   prefixIcon: const Icon(Icons.search),
//                 ),
//               ),
//               const SizedBox(height: 20),
//               //?Cards of products
//               GridView.builder(
//                 shrinkWrap: true,
//                 physics: const NeverScrollableScrollPhysics(),
//                 gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: 2, // Duas colunas
//                   crossAxisSpacing: 8, // Espaço entre as colunas
//                   mainAxisSpacing: 8, // Espaço entre as linhas
//                   childAspectRatio:
//                       0.75, // Ajuste o childAspectRatio para reduzir a altura
//                 ),
//                 itemCount: products.length,
//                 itemBuilder: (context, index) {
//                   return GestureDetector(
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                             builder: (context) => const ProductDetails()),
//                       );
//                     },
//                     child: Card(
//                       elevation: 2, // Menor elevação para o cartão
//                       shape: RoundedRectangleBorder(
//                         borderRadius:
//                             BorderRadius.circular(12), // Menor raio para borda
//                       ),
//                       child: Column(
//                         children: [
//                           const ListTile(
//                             leading: Text(
//                               'Categoria',
//                               style: TextStyle(fontSize: 13),
//                             ),
//                           ),
//                           ClipRRect(
//                             borderRadius: BorderRadius.circular(12),
//                             child: Image.asset(
//                               products[index]['image']!,
//                               width: 189, // Menor largura da imagem
//                               height: 120, // Menor altura da imagem
//                               fit: BoxFit.cover,
//                             ),
//                           ),
//                           const SizedBox(
//                             height: 6, // Menor espaço entre imagem e texto
//                           ),
//                           ListTile(
//                             leading: Text(
//                               products[index]['name']!,
//                               style: const TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 fontSize:
//                                     15, // Tamanho menor da fonte do nome do produto
//                               ),
//                               textAlign: TextAlign.center, // Texto centralizado
//                             ),
//                           ),
//                           const Divider(
//                             thickness: 2,
//                             indent: 20,
//                             endIndent: 20,
//                           ),
//                           ListTile(
//                             leading: const Text('100MZN',
//                                 style: TextStyle(
//                                     fontSize: 14, color: Colors.blue)),
//                             trailing: ElevatedButton(
//                               onPressed: () {
//                                 // Ação do botão
//                               },
//                               child: const Icon(Icons.add),
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: Colors.green,
//                                 foregroundColor: Colors.white,
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(100),
//                                 ),
//                                 padding: const EdgeInsets.symmetric(
//                                     vertical: 6, horizontal: 12),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//               ),
//           ],),
//         ),
//       ),
//       bottomNavigationBar: AppBottomNav(
//         currentIndex: _currentIndex,
//         onTap: _onTap,
//       ),
//       floatingActionButton: FloatingActionButton(
//           backgroundColor: Colors.green,
//           child: const Icon(
//             Icons.shopping_cart,
//             color: Colors.white,
//           ),
//           onPressed: () {}),
//     );
//   }
// }
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:healthclick_app/screens/layouts/AppBottom.dart';
import 'package:healthclick_app/screens/product/ProductDetails.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class Product extends StatefulWidget {
  const Product({super.key});

  @override
  State<Product> createState() => _ProductState();
}

class _ProductState extends State<Product> {
  final String baseUrl ='http://192.168.100.139:8000/api/products'; 
  List<Map<String, dynamic>> products = [];
  int _currentIndex = 1;

  Future<void> getProducts() async {
    try {
      var url = Uri.parse('http://192.168.100.139:8000/api/products');
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var jsonData =
            json.decode(response.body); 
        List<dynamic> data = jsonData['products'];

        setState(() {
          products = data.map((product) {
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
    getProducts(); // Carregar produtos ao iniciar a tela
  }

  void _onTap(int index) {
    setState(() {
      _currentIndex = index;
    });
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
              const SizedBox(height:20),
              const ListTile(
                leading: CircleAvatar(
                  radius: 25,
                  backgroundImage: AssetImage("assets/dif.jpg"),
                ),
                title: Text(
                  "Ola Mauro Peniel",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                ),
              ),
              const SizedBox(height: 30),
              const Text('Todos Produtos',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
              const SizedBox(
                height: 20,
              ),
              TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
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
              //? Cards of products
              products.isNotEmpty
                  ? GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, // Duas colunas
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 0.48, // 0.75 Ajuste do childAspectRatio
                      ),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                          },
                          child: Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                const ListTile(
                                  leading: Text(
                                    'Categoria', // Você pode ajustar para mostrar a categoria real
                                    style: TextStyle(fontSize: 13),
                                  ),
                                ),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                      products[index]['image']!,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Text('Erro ao carregar imagem');
                                      },
                                    ),
                                ),
                                const SizedBox(
                                  height: 6,
                                ),
                                ListTile(
                                  leading: Text(
                                    products[index]['name']!,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                const Divider(
                                  thickness: 2,
                                  indent: 20,
                                  endIndent: 20,
                                ),
                                ListTile(
                                  leading: Text(
                                    '${products[index]['price']} MZN',
                                    style: const TextStyle(
                                        fontSize: 14, color: Colors.blue),
                                  ),
                                  trailing: ElevatedButton(
                                    onPressed: () {
                                      // Ação do botão, por exemplo, adicionar ao carrinho
                                    },
                                    child: const Icon(Icons.add),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(100),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 6, horizontal: 12),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    )
                  : const Center(
                      child:
                          CircularProgressIndicator()), // Loader se não houver produtos
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
        child: const Icon(
          Icons.shopping_cart,
          color: Colors.white,
        ),
        onPressed: () {
          // Ação do botão, como abrir o carrinho
        },
      ),
    );
  }
}
