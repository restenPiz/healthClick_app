import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PharmacyDetails extends StatefulWidget {
    final Map<String, dynamic> pharmacy;
  const PharmacyDetails({super.key, required this.pharmacy});


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
  late GoogleMapController mapController; // Controlador do mapa
  late CameraPosition _initialCameraPosition;

  @override
  void initState() {
    super.initState();
    // Definindo a posição inicial do mapa (exemplo com coordenadas de Maputo, Moçambique)
    _initialCameraPosition = const CameraPosition(
      target: LatLng(-25.968, 32.589), // Defina as coordenadas da farmácia
      zoom: 14.0, // Nível de zoom
    );
  }

  @override
  Widget build(BuildContext context) {
    final pharmacy = widget.pharmacy; 
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //?Main Content
              const SizedBox(height: 10),
              ListTile(
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pop(context); // Voltar para a tela anterior
                  },
                ),
                
                title: const Text(
                  "Detalhes da Farmacia",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
              ),
              Center(
                child: Container(
                  // width: 500,
                  width: double.infinity,
                  height: 400,
                  margin: const EdgeInsets.all(8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      (pharmacy['image'] != null
                            ? 
                                'http://192.168.100.139:8000/storage/${pharmacy['image']}'
                            : AssetImage('assets/images/default_pharmacy.png')
                                as ImageProvider) as String,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Text(
                pharmacy['name'],
                style:  const TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              Text(
                pharmacy['description'],
                textAlign: TextAlign.justify,
              ),
              //?Start with the google Map
            ],
          ),
        ),
      ),
      bottomSheet: GFBottomSheet(
        controller: _controller,
        maxContentHeight: 800, // Ajuste o valor para caber o mapa
        stickyHeaderHeight: 100,
        stickyHeader: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.black45, blurRadius: 0)],
          ),
          child: GFListTile(
            avatar: GFAvatar(
              backgroundImage: pharmacy['image'] != null
                            ? NetworkImage(
                                'http://192.168.100.139:8000/storage/${pharmacy['image']}')
                            : AssetImage('assets/images/default_pharmacy.png')
                                as ImageProvider,
            ),
            titleText: pharmacy['name'],
            subTitleText: 'Localização da Farmácia',
          ),
        ),
        contentBody: Container(
          height: 300, // Tamanho do mapa no bottomSheet
          margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: GoogleMap(
            initialCameraPosition: _initialCameraPosition,
            onMapCreated: (GoogleMapController controller) {
              mapController = controller;
            },
            markers: {
              const Marker(
                markerId: MarkerId('farmaciaMarker'),
                position: LatLng(-25.968, 32.589), // Coordenadas da farmácia
                infoWindow: InfoWindow(
                  title: 'Farmácia Tuia',
                  snippet: 'Descrição da farmácia',
                ),
              ),
            },
            mapType: MapType.normal,
            zoomGesturesEnabled: true,
            zoomControlsEnabled: true,
            myLocationEnabled: true,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: GFColors.SUCCESS,
        child: _controller.isBottomSheetOpened
            ? const Icon(Icons.keyboard_arrow_down)
            : const Icon(Icons.keyboard_arrow_up),
        onPressed: () {
          _controller.isBottomSheetOpened
              ? _controller.hideBottomSheet()
              : _controller.showBottomSheet();
        },
      ),
    );
  }
}
