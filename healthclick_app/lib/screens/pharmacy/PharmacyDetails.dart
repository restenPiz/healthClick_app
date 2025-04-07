import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:healthclick_app/screens/layouts/AppBottom.dart';

class PharmacyDetails extends StatefulWidget {
  const PharmacyDetails({super.key});

  @override
  State<PharmacyDetails> createState() => _PharmacyDetailsState();
}

class _PharmacyDetailsState extends State<PharmacyDetails> {
   int _currentIndex = 0;

  void _onTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  final GFBottomSheetController _controller = GFBottomSheetController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //?Main Content 
              const ListTile(
                leading: CircleAvatar(
                  radius: 25,
                  backgroundImage: AssetImage("assets/dif.jpg"),
                ),
                title: Text(
                  "Olá Mauro Peniel",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                ),
                trailing: Icon(Icons.shopping_cart),
              ),
              const SizedBox(height: 30),
              Center(
                child: Container(
                  width: 500,
                  height: 400,
                  margin: const EdgeInsets.all(8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      'assets/back3.jpg',
                      fit: BoxFit.cover,
                    ),
                  ),
                ), 
              ),
              const SizedBox(height:30),
              const Text('Farmacia Tuia',style: TextStyle(color: Colors.black, fontSize: 20,fontWeight:FontWeight.bold),),
              const SizedBox(height:15),
              const Text(
                  'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industrys standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.',
                  textAlign: TextAlign.justify),
              //?Start with the google Map
            ],
          ),
        ),
      ),
      // bottomNavigationBar: AppBottomNav(
      //   currentIndex: _currentIndex,
      //   onTap: _onTap,
      // ),
      bottomSheet: GFBottomSheet(
        controller: _controller,
        maxContentHeight: 150,
        stickyHeaderHeight: 100,
        stickyHeader: Container(
          decoration: const BoxDecoration(color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black45, blurRadius: 0)]
          ),
          child: const GFListTile(
            avatar: GFAvatar(
              backgroundImage: AssetImage('assets image here'),
            ),
            titleText: 'GetWidget',
            subTitleText: 'Open source UI library',
          ),
        ),
        contentBody: Container(
          height: 200,
          margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: ListView(
            shrinkWrap: true,
            physics: const ScrollPhysics(),
            children: const [
              Center(
                  child: Text(
                    'Getwidget reduces your overall app development time to minimum 30% because of its pre-build clean UI widget that you can use in flutter app development. We have spent more than 1000+ hours to build this library to make flutter developer’s life easy.',
                    style: TextStyle(
                        fontSize: 15, wordSpacing: 0.3, letterSpacing: 0.2),
                  ))
            ],
          ),
        ),
        stickyFooter: Container(
          color: GFColors.SUCCESS,
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                'Get in touch',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              Text(
                'info@getwidget.dev',
                style: TextStyle(fontSize: 15, color: Colors.white),
              ),
            ],
          ),
        ),
        stickyFooterHeight: 50,
      ),
      floatingActionButton: FloatingActionButton(
          backgroundColor: GFColors.SUCCESS,
          child: _controller.isBottomSheetOpened ? const Icon(Icons.keyboard_arrow_down):const Icon(Icons.keyboard_arrow_up),
          onPressed: () {
            _controller.isBottomSheetOpened
                ? _controller.hideBottomSheet()
                : _controller.showBottomSheet();
          }
          ),
    );
  }
}