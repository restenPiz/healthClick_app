import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:healthclick_app/screens/layouts/AppBottom.dart';
import 'package:healthclick_app/screens/product/Product.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<String> imageList = [
    "assets/background.jpg",
    "assets/back1.jpg",
    "assets/back2.jpg",
    "assets/back3.jpg",
  ];

  final List<Map<String, String>> products = [
    {"image": "assets/back1.jpg", "name": "Produto 1"},
    {"image": "assets/back1.jpg", "name": "Produto 2"},
    {"image": "assets/back1.jpg", "name": "Produto 3"},
  ];

  final List<Widget> _screens = [
    Center(child: Text("Início")),
    Center(child: Text("Carrinho")),
    Center(child: Text("Medicamentos")),
    Center(child: Text("Farmácias")),
    Center(child: Text("Perfil")),
  ];

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
              // User Greeting Section
              const ListTile(
                leading: CircleAvatar(
                  radius: 25,
                  backgroundImage: AssetImage("assets/dif.jpg"),
                ),
                title: Text(
                  "Olá Mauro Peniel",
                  style: TextStyle(fontSize: 15),
                ),
                subtitle: Text(
                  "O que você deseja?",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                ),
                trailing: Icon(Icons.alarm),
              ),
              const SizedBox(height: 30),

              // Search Section
              const TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Pesquisar o Produto',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
              const SizedBox(height: 30),

              // Image Carousel
              GFCarousel(
                autoPlay: true,
                autoPlayInterval: Duration(seconds: 3),
                items: imageList.map(
                  (url) {
                    return Container(
                      width: 500,
                      height: 250,
                      margin: EdgeInsets.all(8.0),
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
                    // Use this if you want to handle page changes
                  });
                },
              ),
              const SizedBox(height: 50),

              // Categories Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Categorias',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                ],
              ),
              const SizedBox(height: 20),

              // Category Cards Section
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(3, (index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          width: 170,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.green, width: 1.5),
                            boxShadow: const [
                              BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 6,
                                  offset: Offset(0, 3)),
                            ],
                          ),
                          child: ListTile(
                            leading:
                                const Icon(Icons.alarm, color: Colors.black),
                            title: Text('Categoria ${index + 1}',
                                style: TextStyle(color: Colors.black)),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),

              SizedBox(height: 30),

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
                        MaterialPageRoute(builder: (context) => Product()),
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

              // Product Grid
              GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.75,
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
                        SizedBox(height: 10),
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
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            // Implement the action for "Add to Cart" button
                          },
                          child: const Text('Adicionar ao Carrinho'),
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
      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentIndex,
        onTap: _onTap,
      ),
    );
  }
}
