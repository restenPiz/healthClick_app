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
              //?Cards Carousel
            ],
          ),        
        ),
      ),
    );
  }
}