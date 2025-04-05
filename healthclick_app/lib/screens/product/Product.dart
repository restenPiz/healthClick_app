// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:healthclick_app/screens/layouts/AppBottom.dart';

class Product extends StatefulWidget {
  const Product({super.key});

  @override
  State<Product> createState() => _ProductState();
}

class _ProductState extends State<Product> {
  
final List<Map<String, String>> products = [
    {
      "image": "assets/back1.jpg",
      "name": "Produto 1",
    },
    {
      "image": "assets/back1.jpg",
      "name": "Produto 2",
    },
    {
      "image": "assets/back1.jpg",
      "name": "Produto 3",
    },
    {
      "image": "assets/back1.jpg",
      "name": "Produto 1",
    },
    {
      "image": "assets/back1.jpg",
      "name": "Produto 2",
    },
    {
      "image": "assets/back1.jpg",
      "name": "Produto 3",
    },
    // Adicione mais produtos conforme necessário
  ];

    int _currentIndex = 0;

  void _onTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ListTile(
                leading: CircleAvatar(
                  radius: 25, // Adjust size
                  backgroundImage: AssetImage("assets/dif.jpg"),
                ),
                title: Text(
                  "Ola Mauro Peniel",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                ),
                trailing: Icon(Icons.alarm),
              ),
              const SizedBox(height: 30,),
              const Text('Todos Productos',
                  style: TextStyle( fontWeight: FontWeight.bold, fontSize: 17)
              ),
              const SizedBox(
                height: 20,
              ),
              const TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Pesquisar o Produto',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
              const SizedBox(height: 20),
              //?Cards of products
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // Duas colunas
                  crossAxisSpacing: 8, // Espaço entre as colunas
                  mainAxisSpacing: 8, // Espaço entre as linhas
                  childAspectRatio:
                      0.75, // Ajuste o childAspectRatio para reduzir a altura
                ),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 2, // Menor elevação para o cartão
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(12), // Menor raio para borda
                    ),
                    child: Column(
                      children: [
                        const ListTile(
                          leading: Text(
                            'Categoria',
                            style: TextStyle(fontSize: 13),
                          ),
                        ),
                        // const SizedBox(height: 20), // Menor espaço acima da imagem
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            products[index]['image']!,
                            width: 189, // Menor largura da imagem
                            height: 120, // Menor altura da imagem
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(
                            height: 6), // https://web.facebook.com/share/p/1FqAvEhNqi/
                        ListTile(
                          leading: Text(
                            products[index]['name']!,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize:
                                  15, // Tamanho menor da fonte do nome do produto
                            ),
                            textAlign: TextAlign.center, // Texto centralizado
                          ),
                        ),
                        // const SizedBox(
                        //     height:
                        //         8),
                        const Divider(
                          thickness: 2,
                          indent: 20,
                          endIndent: 20,
                        ),
                        ListTile(
                          leading: const Text(
                            '100MZN',
                            style: TextStyle(fontSize: 14, color: Colors.blue),
                          ),
                          trailing: ElevatedButton(
                            onPressed: () {},
                            child: const Icon(Icons.add),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 6, horizontal: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],),
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentIndex,
        onTap: _onTap,
      ),
    );
  }
}