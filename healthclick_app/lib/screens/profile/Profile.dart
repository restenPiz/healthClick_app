// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:healthclick_app/ThemeProvider.dart';
// import 'package:healthclick_app/screens/layouts/AppBottom.dart';
// import 'package:healthclick_app/screens/profile/ProfileEdit.dart';
// import 'package:healthclick_app/screens/welcome/SplashLogin.dart';
// import 'package:provider/provider.dart';
// import 'package:google_sign_in/google_sign_in.dart';

// class Profile extends StatefulWidget {
//   const Profile({super.key});

//   @override
//   State<Profile> createState() => _ProfileState();
// }

// class _ProfileState extends State<Profile> {
//   int _currentIndex = 3;
  
//     bool isDarkMode = false;

//   void _onTap(int index) {
//     setState(() {
//       _currentIndex = index;
//     });
//   }
  
//   @override
//   Widget build(BuildContext context) {
//     final themeProvider = Provider.of<ThemeProvider>(context);
//     final isDarkMode = themeProvider.isDarkMode;
//      User? currentUser = FirebaseAuth.instance.currentUser;
//     return Scaffold(
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.start,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               //?Start the main content
//               const SizedBox(height: 80),
//               Center(
//                 child: CircleAvatar(
//                   radius: 70,
//                   backgroundImage: currentUser?.photoURL != null
//                       ? NetworkImage(currentUser!.photoURL!)
//                       : const AssetImage("assets/dif.jpg") as ImageProvider,
//                 ),
//               ),
//               const SizedBox(height:20),
//               Center(
//                 child: Text("${currentUser?.displayName ?? currentUser?.email?.split('@')[0] ?? 'Visitante'}",
//                   style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
//                 ),
//               ),
//               const SizedBox(height: 10),
//               Center(
//                 child: Text("${currentUser?.email?? 'Visitante'}",style: TextStyle(fontSize: 18),),
//               ),
//               const SizedBox(height: 30),
//               const Divider(
//                 thickness: 1,
//                 indent: 20,
//                 endIndent: 20,
//               ),
//               // const SizedBox(height: 2),
//               GestureDetector(
//                 onTap: (){
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (context) => const ProfileEdit()),
//                   );
//                 },
//                 child: const ListTile(
//                   leading: Icon(Icons.person),
//                   title: Text('Editar Perfil',style: TextStyle(fontSize: 18),),
//                 ),
//               ),
//               const Divider(
//                 thickness: 1,
//                 indent: 20,
//                 endIndent: 20,
//               ),
//               const ListTile(
//                 leading: Icon(Icons.help),
//                 title:Text('Ajuda'),
//               ),
//               // const SizedBox(height: 2),
//               const Divider(
//                 thickness: 1,
//                 indent: 20,
//                 endIndent: 20,
//               ),
//               // const SizedBox(height: 10),
//               ListTile(
//                 leading: const Icon(Icons.dark_mode),
//                 title: const Text(
//                   'Dark Mode',
//                   style: TextStyle(fontSize: 18),
//                 ),
//                 trailing: Switch(
//                   value: isDarkMode,
//                   onChanged: (value) => themeProvider.toggleTheme(value),
//                   activeColor: Colors.blue,
//                 ),
//               ),
//               // const SizedBox(height: 10),
//               const Divider(
//                 thickness: 1,
//                 indent: 20,
//                 endIndent: 20,
//               ),
//               const SizedBox(height: 35),
//               SizedBox(
//                 width: double.infinity, // ✅ Makes button full width
//                 child: ElevatedButton(
//                   onPressed: () async {
//                     //* Deslogar do Firebase
//                     await FirebaseAuth.instance.signOut();

//                     //* Deslogar do Google também (opcional mas recomendado)
//                     await GoogleSignIn().signOut();

//                     //* Navegar para tela de login (SplashLogin, por exemplo)
//                     Navigator.pushAndRemoveUntil(
//                       context,
//                       MaterialPageRoute(builder: (context) => const SplashLogin()),
//                       (route) => false, // Remove todas as rotas anteriores
//                     );
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.red,
//                     foregroundColor: Colors.white,
//                     padding: const EdgeInsets.symmetric(vertical: 15),
//                   ),
//                   child: const Text(
//                     'Logout',
//                     style: TextStyle(fontSize: 17),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//       bottomNavigationBar: AppBottomNav(
//         currentIndex: _currentIndex,
//         onTap: _onTap,
//       ),
//     );
//   }
// }
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:healthclick_app/ThemeProvider.dart';
import 'package:healthclick_app/screens/layouts/AppBottom.dart';
import 'package:healthclick_app/screens/profile/ProfileEdit.dart';
import 'package:healthclick_app/screens/welcome/SplashLogin.dart';
import 'package:provider/provider.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  int _currentIndex = 3;

  void _onTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get media query information for responsive design
    final mediaQuery = MediaQuery.of(context);
    final screenSize = mediaQuery.size;
    final textScaleFactor = mediaQuery.textScaleFactor;
    final isSmallScreen = screenSize.width < 600;

    // Responsive dimensions
    final avatarRadius = isSmallScreen ? screenSize.width * 0.15 : 70.0;
    final horizontalPadding = screenSize.width * 0.04;
    final verticalSpacing = screenSize.height * 0.02;

    // Responsive text sizes
    final nameTextSize = isSmallScreen ? 22.0 : 25.0;
    final emailTextSize = isSmallScreen ? 16.0 : 18.0;
    final itemTextSize = isSmallScreen ? 16.0 : 18.0;
    final buttonTextSize = isSmallScreen ? 16.0 : 17.0;

    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    User? currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: verticalSpacing,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //?Start the main content
                SizedBox(height: screenSize.height * 0.05),
                Center(
                  child: CircleAvatar(
                    radius: avatarRadius,
                    backgroundImage: currentUser?.photoURL != null
                        ? NetworkImage(currentUser!.photoURL!)
                        : const AssetImage("assets/dif.jpg") as ImageProvider,
                    onBackgroundImageError: (exception, stackTrace) {
                      // Error handling for image loading
                      debugPrint('Error loading profile image: $exception');
                    },
                  ),
                ),
                SizedBox(height: verticalSpacing),
                Center(
                  child: Text(
                    "${currentUser?.displayName ?? currentUser?.email?.split('@')[0] ?? 'Visitante'}",
                    style: TextStyle(
                      fontSize: nameTextSize,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
                SizedBox(height: verticalSpacing * 0.5),
                Center(
                  child: Text(
                    "${currentUser?.email ?? 'Visitante'}",
                    style: TextStyle(fontSize: emailTextSize),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
                SizedBox(height: verticalSpacing * 1.5),
                Divider(
                  thickness: 1,
                  indent: screenSize.width * 0.05,
                  endIndent: screenSize.width * 0.05,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ProfileEdit()),
                    );
                  },
                  child: ListTile(
                    leading: Icon(
                      Icons.person,
                      size: isSmallScreen ? 24 : 28,
                    ),
                    title: Text(
                      'Editar Perfil',
                      style: TextStyle(fontSize: itemTextSize),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: verticalSpacing * 0.3,
                    ),
                  ),
                ),
                Divider(
                  thickness: 1,
                  indent: screenSize.width * 0.05,
                  endIndent: screenSize.width * 0.05,
                ),
                ListTile(
                  leading: Icon(
                    Icons.help,
                    size: isSmallScreen ? 24 : 28,
                  ),
                  title: Text(
                    'Ajuda',
                    style: TextStyle(fontSize: itemTextSize),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: verticalSpacing * 0.3,
                  ),
                ),
                Divider(
                  thickness: 1,
                  indent: screenSize.width * 0.05,
                  endIndent: screenSize.width * 0.05,
                ),
                ListTile(
                  leading: Icon(
                    Icons.dark_mode,
                    size: isSmallScreen ? 24 : 28,
                  ),
                  title: Text(
                    'Dark Mode',
                    style: TextStyle(fontSize: itemTextSize),
                  ),
                  trailing: Switch(
                    value: isDarkMode,
                    onChanged: (value) => themeProvider.toggleTheme(value),
                    activeColor: Colors.blue,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: verticalSpacing * 0.3,
                  ),
                ),
                Divider(
                  thickness: 1,
                  indent: screenSize.width * 0.05,
                  endIndent: screenSize.width * 0.05,
                ),
                SizedBox(height: verticalSpacing * 1.5),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        //* Deslogar do Firebase
                        await FirebaseAuth.instance.signOut();

                        //* Deslogar do Google também (opcional mas recomendado)
                        await GoogleSignIn().signOut();

                        //* Navegar para tela de login (SplashLogin, por exemplo)
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SplashLogin()),
                          (route) => false, 
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          vertical: isSmallScreen ? 12 : 15,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: Text(
                        'Logout',
                        style: TextStyle(fontSize: buttonTextSize),
                      ),
                    ),
                  ),
                ),
                // Add extra space at bottom to prevent content being hidden by bottom nav
                SizedBox(height: screenSize.height * 0.08),
              ],
            ),
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
