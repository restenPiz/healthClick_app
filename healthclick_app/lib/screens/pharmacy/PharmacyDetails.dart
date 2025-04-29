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
  final GFBottomSheetController _controller = GFBottomSheetController();
  late GoogleMapController mapController;
  late CameraPosition _initialCameraPosition;
  late LatLng pharmacyLocation;

  @override
  void initState() {
    super.initState();

    try {
      // Extrair as coordenadas da string de localização da farmácia
      List<String> coordinates = widget.pharmacy['location'].split(',');
      double lat = double.parse(coordinates[0]);
      double lng = double.parse(coordinates[1]);

      // Definir a localização da farmácia
      pharmacyLocation = LatLng(lat, lng);
    } catch (e) {
      // Fallback se houver erro ao processar as coordenadas
      pharmacyLocation = const LatLng(-25.968, 32.589); // Coordenadas padrão
      print('Erro ao processar coordenadas: $e');
    }

    // Usar a localização da farmácia como posição inicial do mapa
    _initialCameraPosition = CameraPosition(
      target: pharmacyLocation,
      zoom: 15.0,
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
              const SizedBox(height: 10),
              ListTile(
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                title: const Text(
                  "Detalhes da Farmacia",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              ),
              Center(
                child: Container(
                  width: double.infinity,
                  height: 400,
                  margin: const EdgeInsets.all(8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: pharmacy['image'] != null
                        ? Image.network(
                            'http://cloudev.org/storage/${pharmacy['image']}',
                            fit: BoxFit.cover,
                          )
                        : Image.asset(
                            'assets/images/default_pharmacy.png',
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Text(
                pharmacy['name'],
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              Text(
                pharmacy['description'],
                textAlign: TextAlign.justify,
              ),
            ],
          ),
        ),
      ),
      bottomSheet: GFBottomSheet(
        controller: _controller,
        maxContentHeight: 600,
        stickyHeaderHeight: 100,
        stickyHeader: Container(
          decoration: const BoxDecoration(
            color: Colors.grey,
          //  boxShadow: [BoxShadow(color: Colors.black45, blurRadius: 20)],
          ),
          child: GFListTile(
            avatar: GFAvatar(
              backgroundImage: pharmacy['image'] != null
                  ? NetworkImage(
                      'http://cloudev.org/storage/${pharmacy['image']}')
                  : const AssetImage('assets/images/default_pharmacy.png')
                      as ImageProvider,
            ),
            titleText: pharmacy['name'],
            subTitleText: 'Localização da Farmácia',
          ),
        ),
        contentBody: Container(
          height: 300,
          margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: GoogleMap(
            initialCameraPosition: _initialCameraPosition,
            onMapCreated: (GoogleMapController controller) {
              mapController = controller;
            },
            markers: {
              Marker(
                markerId: const MarkerId('farmaciaMarker'),
                position: pharmacyLocation,
                infoWindow: InfoWindow(
                  title: pharmacy['name'],
                  snippet: 'Contato: ${pharmacy['contact']}',
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
