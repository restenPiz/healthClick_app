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
              //?Cards of products
              GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // Duas colunas
                  crossAxisSpacing: 8, // Espaço entre as colunas
                  mainAxisSpacing: 8, // Espaço entre as linhas
                  childAspectRatio:
                      1, // Ajuste o childAspectRatio para reduzir a altura
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
                        SizedBox(height: 20), // Menor espaço acima da imagem
                        ClipRRect(
                          borderRadius: BorderRadius.circular(
                              12), 
                          child: Image.asset(
                            products[index]['image']!,
                            width: 140, // Menor largura da imagem
                            height: 100, // Menor altura da imagem
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(
                            height: 6), // Menor espaço entre imagem e texto
                        Text(
                          products[index]['name']!,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize:
                                17, // Tamanho menor da fonte do nome do produto
                          ),
                          textAlign: TextAlign.center, // Texto centralizado
                        ),
                        SizedBox(
                            height:
                                8), // Menor espaço entre o nome do produto e o botão
                        ElevatedButton(
                          onPressed: () {
                            // Ação para o botão "Add to Cart"
                          },
                          child: const Text('Add to Cart'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  12), // Raio da borda do botão
                            ),
                            padding: EdgeInsets.symmetric(
                                vertical: 6,
                                horizontal: 12), // Menor padding do botão
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