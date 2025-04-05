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
    {"image": "assets/back3.jpg", "name": "Produto 2"},
    {"image": "assets/back3.jpg", "name": "Produto 3"},
  ];

  final List<Widget> _screens = [
    const Center(child: Text("Início")),
    const Center(child: Text("Carrinho")),
    const Center(child: Text("Medicamentos")),
    const Center(child: Text("Farmácias")),
    const Center(child: Text("Perfil")),
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
                    // Use this if you want to handle page changes
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
                                style: const TextStyle(color: Colors.black)),
                          ),
                        ),
                      ),
                    );
                  }),
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
                        MaterialPageRoute(builder: (context) => const Product()),
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
              //?Product section
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
                            height: 6), // Menor espaço entre imagem e texto
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
                          leading: const Text('100MZN',style: TextStyle(fontSize: 14,color: Colors.blue),),
                          trailing: ElevatedButton(
                          onPressed: () {
                          },
                          child: const Icon(Icons.add),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  100), 
                            ),
                            padding: const EdgeInsets.symmetric(
                                vertical: 6,
                                horizontal: 12),
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
