import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

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
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    "assets/background.jpg",
                    width: 500,
                    height: 250,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),        
        ),
      ),
    );
  }
}