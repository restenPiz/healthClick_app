// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

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

int _currentIndex = 0;

  final List<Widget> _screens = [
    Center(child: Text("Início")),
    Center(child: Text("Carrinho")),
    Center(child: Text("Medicamentos")),
    Center(child: Text("Farmácias")),
    Center(child: Text("Perfil")),
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
                subtitle: Text("O que voce deseja ?",
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
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children: [
                Row(children: [
                  const Text('Categorias',style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),),
                ],),
              ],),
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
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: 170,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: Colors.green, width: 1.5), // Borda verde
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 6,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ListTile(
                          leading: const Icon(Icons.alarm, color: Colors.black),
                          title: const Text('Categoria 1',
                              style: TextStyle(color: Colors.black)),
                        ),
                      ),
                    ),
                    SizedBox(width: 10,),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: 170,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: Colors.green, width: 1.5), // Borda verde
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 6,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ListTile(
                          leading: const Icon(Icons.alarm, color: Colors.black),
                          title: const Text('Categoria 1',
                              style: TextStyle(color: Colors.black)),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: 170,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: Colors.green, width: 1.5), // Borda verde
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 6,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ListTile(
                          leading: const Icon(Icons.alarm, color: Colors.black),
                          title: const Text('Categoria 1',
                              style: TextStyle(color: Colors.black)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height:30),
              //?Card of Products
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Productos',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 17),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Text(
                        'Ver Todos',
                        style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                            fontSize: 17),
                      ),
                    ],
                  ),
                ],
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
                        SizedBox(height: 10,),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.asset(
                            products[index]['image']!,
                            width: 190,
                            height: 150,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          products[index]['name']!,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        ElevatedButton(
                          onPressed: () {
                            // Ação do botão "Add to Cart"
                          },
                          // ignore: sort_child_properties_last
                          child: const Text('Add to Cart'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),        
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.medical_services),
            label: 'Medicamentos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_hospital),
            label: 'Farmácias',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}