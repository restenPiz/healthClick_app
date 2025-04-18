// ignore_for_file: prefer_const_constructors

import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:healthclick_app/screens/layouts/AppBottom.dart';
import 'package:healthclick_app/screens/pharmacy/PharmacyDetails.dart';
import 'package:http/http.dart' as http;

class Pharmacy extends StatefulWidget {
  const Pharmacy({super.key});

  @override
  State<Pharmacy> createState() => _PharmacyState();
}

class _PharmacyState extends State<Pharmacy> {

   int _currentIndex = 2;

  //*Start method to fetch the datas
  
  List<Map<String, dynamic>> pharmacies = [];
  Future<void> getPharmacies() async {
    try {
      var url = Uri.parse('http://192.168.100.139:8000/api/pharmacies');
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        List<dynamic> data = jsonData['pharmacies'];

        setState(() {
          pharmacies = data.map((pharmacy) {
            return {
              "id": pharmacy['id'],
              "name": pharmacy['pharmacy_name'],
              "location": pharmacy['pharmacy_location'],
              "contact": pharmacy['pharmacy_contact'],
              "image":
                  pharmacy['pharmacy_file'], // Aqui está o arquivo da imagem
              "description": pharmacy['pharmacy_description'],
              "userEmail": pharmacy['user']['email'],  // Acessando o email do usuário
              "userName": pharmacy['user']['name'],  
            };
          }).toList();
        });
      }
    } catch (e) {
      print('Erro: $e');
      throw Exception('Falha ao carregar farmacias');
    }
  }

  void _onTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    getPharmacies();
  }

  @override
  Widget build(BuildContext context) {
    User? currentUser = FirebaseAuth.instance.currentUser;
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height:15),
              //?Main content starts here
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
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
              ),
              const SizedBox(height: 20),
              //?ListView of pharmacies
              const Text(
                "Farmácias Próximas",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ListView.builder(
                shrinkWrap:
                    true,
                physics:
                    NeverScrollableScrollPhysics(), 
                itemCount: pharmacies.length,
                itemBuilder: (context, index) {
                  final pharmacy = pharmacies[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        radius: 25,
                         backgroundImage: pharmacy['image'] != null
                            ? NetworkImage(
                                'http://192.168.100.139:8000/storage/${pharmacy['image']}')
                            : AssetImage('assets/images/default_pharmacy.png')
                                as ImageProvider,
                      ),
                      title: Text(
                        pharmacy['name']!,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('Proprietario: ${pharmacy['userName']!}'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                       Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const PharmacyDetails()),
                        );
                      },
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
          child: const Icon(
            Icons.shopping_cart,
            color: Colors.white,
          ),
          onPressed: () {}),
    );
  }
}
