import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:healthclick_app/screens/auth/Login.dart';
import 'package:healthclick_app/screens/layouts/AppBottom.dart';
import 'package:healthclick_app/screens/profile/ProfileEdit.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  int _currentIndex = 3;
  
    bool isDarkMode = false;

  void _onTap(int index) {
    setState(() {
      _currentIndex = index;
    });
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
              //?Start the main content
              const SizedBox(height:20),
              const Center(
                child: Text('Perfil',style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold,color: Colors.black),),
              ),
              const SizedBox(height: 30),
              Center(
                child: CircleAvatar(
                  radius: 70,
                  backgroundImage: currentUser?.photoURL != null
                      ? NetworkImage(currentUser!.photoURL!)
                      : const AssetImage("assets/dif.jpg") as ImageProvider,
                ),
              ),
              const SizedBox(height:20),
              Center(
                child: Text("${currentUser?.displayName ?? currentUser?.email?.split('@')[0] ?? 'Visitante'}",
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold,color: Colors.black),
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: Text("${currentUser?.email?? 'Visitante'}",style: TextStyle(fontSize: 18),),
              ),
              const SizedBox(height: 30),
              const Divider(
                thickness: 2,
                indent: 20,
                endIndent: 20,
              ),
              // const SizedBox(height: 2),
              GestureDetector(
                onTap: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ProfileEdit()),
                  );
                },
                child: const ListTile(
                  leading: Icon(Icons.person),
                  title: Text('Editar Perfil',style: TextStyle(fontSize: 18,color: Colors.black),),
                ),
              ),
              // const SizedBox(height: 2),
              const Divider(
                thickness: 2,
                indent: 20,
                endIndent: 20,
              ),
              // const SizedBox(height: 10),
              ListTile(
                leading: const Icon(Icons.dark_mode),
                title: const Text(
                  'Dark Mode',
                  style: TextStyle(fontSize: 18, color: Colors.black),
                ),
                trailing: Switch(
                  value: isDarkMode,
                  onChanged: (value) {},
                  activeColor: Colors.blue,
                ),
              ),
              // const SizedBox(height: 10),
               const Divider(
                thickness: 2,
                indent: 20,
                endIndent: 20,
              ),
              const SizedBox(height: 35),
              SizedBox(
                width: double.infinity, // ✅ Makes button full width
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Login()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: const Text(
                    'Logout',
                    style: TextStyle(fontSize: 17),
                  ),
                ),
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