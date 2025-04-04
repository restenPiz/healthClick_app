// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();

}

final List<String> imageList = [
  "assets/background.jpg",
  "assets/back1.jpg",
  "assets/back2.jpg",
  "assets/back3.jpg",
];

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
  // Adicione mais produtos conforme necessário
];

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ListTile(
                leading: CircleAvatar(
                  radius: 25, // Adjust size
                  backgroundImage: AssetImage(
                      "assets/dif.jpg"), 
                ),
                title: Text(
                  "Ola Mauro Peniel",
                  style: TextStyle(fontSize: 15), 
                ),
                subtitle: Text("O que vce deseja ?",
                  style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17),
                ),
                trailing:
                    Icon(Icons.alarm),
              ),
              const SizedBox(height: 30,),
              const TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Pesquisar o Producto',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              //?Image Section
               GFCarousel(
                autoPlay: true, // Enable auto play
                autoPlayInterval:
                    Duration(seconds: 3), // Interval for auto play
                items: imageList.map(
                  (url) {
                    return Container(
                      width: 500, // Set width of image
                      height: 250, // Set height of image
                      margin: EdgeInsets.all(8.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                          url, // Use Image.asset for local images
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ).toList(),
                onPageChanged: (index) {
                  setState(() {
                    index;
                  });
                },
              ),
              const SizedBox(height: 50,),
              const Text('Categorias',style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),),
              const SizedBox(
                height: 20,
              ),
              //?Cards Carousel
              SingleChildScrollView(
                scrollDirection:
                    Axis.horizontal, // Habilita o scroll horizontal
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20), // Aplique o arredondamento aqui
                      child: Container(
                        width: 170,
                        height: 50,
                        color: Colors.green, // Cor de fundo
                        child: ListTile(
                          leading: const Icon(Icons.alarm,color: Colors.white,),
                          title: const Text('Categoria 1',style: TextStyle(color: Colors.white),),
                        ),
                      ),
                    ),
                    SizedBox(width: 10,),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(
                          20), // Aplique o arredondamento aqui
                      child: Container(
                        width: 170,
                        height: 50,
                        color: Colors.green, // Cor de fundo
                        child: ListTile(
                          leading: const Icon(
                            Icons.alarm,
                            color: Colors.white,
                          ),
                          title: const Text(
                            'Categoria 1',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(
                          20), // Aplique o arredondamento aqui
                      child: Container(
                        width: 170,
                        height: 50,
                        color: Colors.green, // Cor de fundo
                        child: ListTile(
                          leading: const Icon(
                            Icons.alarm,
                            color: Colors.white,
                          ),
                          title: const Text(
                            'Categoria 1',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height:30),
              //?Card of Products
              const Text(
                'Produtos',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
              ),
              const SizedBox(height: 20),
              // Product Cards Grid
              GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // 2 columns for product cards
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.75, // Adjust aspect ratio as needed
                ),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.asset(
                            products[index]['image']!,
                            width: 150,
                            height: 150,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          products[index]['name']!,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Spacer(),
                        ElevatedButton(
                          onPressed: () {
                            // Ação do botão "Add to Cart"
                          },
                          child: Text('Add to Cart'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                        SizedBox(height: 20,),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),        
        ),
      ),
    );
  }
}