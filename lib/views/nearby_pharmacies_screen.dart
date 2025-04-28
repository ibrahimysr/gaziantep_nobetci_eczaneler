import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:gaziantep_nobetci_eczane/components/app_bar.dart'; 
import 'package:gaziantep_nobetci_eczane/model/pharmacy_model.dart'; 
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart'; 

class NearbyPharmaciesPage extends StatefulWidget {
  final List<Result> pharmacies;
  final LatLng userLocation;    

  const NearbyPharmaciesPage({
    super.key,
    required this.pharmacies,
    required this.userLocation,
  });

  @override
  State<NearbyPharmaciesPage> createState() => _NearbyPharmaciesPageState();
}

class _NearbyPharmaciesPageState extends State<NearbyPharmaciesPage> {
  bool _showListView = true;
  final MapController _mapController = MapController();
  
  double _selectedDistance = 5.0; 
  final List<double> _distanceOptions = [5, 10, 15, 20, 25, 30,35, 40, 50]; 
  List<Result> _filteredPharmacies = []; 
  
  @override
  void initState() {
    super.initState();
    _filterPharmaciesByDistance();
  }
  
  void _filterPharmaciesByDistance() {
    _filteredPharmacies = widget.pharmacies.where((pharmacy) {
      if (pharmacy.loc == null || pharmacy.loc!.isEmpty) return false;
      
      try {
        final coordinates = pharmacy.loc!.split(',');
        if (coordinates.length != 2) return false;
        
        final latStr = coordinates[0].trim();
        final lngStr = coordinates[1].trim();
        if (latStr.isEmpty || lngStr.isEmpty) return false;
        
        final lat = double.tryParse(latStr);
        final lng = double.tryParse(lngStr);
        if (lat == null || lng == null || 
            lat < -90 || lat > 90 || 
            lng < -180 || lng > 180) return false;
        
        double distanceInMeters = Geolocator.distanceBetween(
          widget.userLocation.latitude, 
          widget.userLocation.longitude, 
          lat, 
          lng
        );
        
        return distanceInMeters / 1000 <= _selectedDistance;
      } catch (e) {
        print('Mesafe hesaplama hatası: $e');
        return false;
      }
    }).toList();
    
    _filteredPharmacies.sort((a, b) {
      double distanceA = _calculateDistance(a);
      double distanceB = _calculateDistance(b);
      return distanceA.compareTo(distanceB);
    });
  }
  
  double _calculateDistance(Result pharmacy) {
    if (pharmacy.loc == null || pharmacy.loc!.isEmpty) return double.infinity;
    
    try {
      final coordinates = pharmacy.loc!.split(',');
      if (coordinates.length != 2) return double.infinity;
      
      final latStr = coordinates[0].trim();
      final lngStr = coordinates[1].trim();
      if (latStr.isEmpty || lngStr.isEmpty) return double.infinity;
      
      final lat = double.tryParse(latStr);
      final lng = double.tryParse(lngStr);
      if (lat == null || lng == null || 
          lat < -90 || lat > 90 || 
          lng < -180 || lng > 180) return double.infinity;
      
      return Geolocator.distanceBetween(
        widget.userLocation.latitude, 
        widget.userLocation.longitude, 
        lat, 
        lng
      );
    } catch (e) {
      return double.infinity;
    }
  }

  String _formatDistance(double distanceInMeters) {
    if (distanceInMeters < 10) { // Çok yakınsa
       return "< 10 m";
    } else if (distanceInMeters < 1000) {
      return "${distanceInMeters.toStringAsFixed(0)} m";
    } else {
      return "${(distanceInMeters / 1000).toStringAsFixed(1)} km";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Yakınımdaki Eczaneler"),
      backgroundColor: const Color(0xFFF6F6F6),
      body: Column(
        children: [
          _buildDistanceSlider(), 
          _buildSegmentedControl(context),
          Expanded(
              child: _showListView ? _buildListView() : _buildMapView()),
        ],
      ),
    );
  }
  
  Widget _buildDistanceSlider() {
    return Container(
      margin: const EdgeInsets.fromLTRB(30, 20, 30, 0),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Mesafe: ${_selectedDistance.toInt()} km",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                "${_filteredPharmacies.length} eczane bulundu",
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: Colors.red,
              inactiveTrackColor: Colors.red.withOpacity(0.2),
              thumbColor: Colors.red,
              overlayColor: Colors.red.withOpacity(0.2),
              tickMarkShape: const RoundSliderTickMarkShape(tickMarkRadius: 3),
              activeTickMarkColor: Colors.white,
              inactiveTickMarkColor: Colors.red.withOpacity(0.5),
            ),
            child: Slider(
              value: _selectedDistance,
              min: _distanceOptions.first,
              max: _distanceOptions.last,
              divisions: _distanceOptions.length - 1,
              label: "${_selectedDistance.toInt()} km",
              onChanged: (value) {
                setState(() {
                  _selectedDistance = value;
                  _filterPharmaciesByDistance();
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: _distanceOptions.map((option) {
                return Text(
                  option.toInt().toString(),
                  style: TextStyle(
                    fontSize: 12,
                    color: _selectedDistance == option 
                        ? Colors.red 
                        : Colors.grey,
                    fontWeight: _selectedDistance == option 
                        ? FontWeight.bold 
                        : FontWeight.normal,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

   Widget _buildSegmentedControl(BuildContext context) {
     return Container(
      margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [ BoxShadow( color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 3, offset: const Offset(0, 1),),],
      ),
      child: Row(
        children: [
          Expanded(child: _buildSegmentTab(Icons.list, 'Liste', true)),
          Expanded(child: _buildSegmentTab(Icons.map, 'Harita', false)),
        ],
      ),
    );
   }

   Widget _buildSegmentTab(IconData icon, String text, bool isListTab) {
     bool isActive = (isListTab && _showListView) || (!isListTab && !_showListView);
     Color activeColor = Colors.red; 
     Color inactiveColor = Colors.grey;
     Color activeTextIconColor = Colors.white;

     return GestureDetector(
            onTap: () {
              if (isActive) return;
              setState(() { _showListView = isListTab; });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: isActive ? activeColor : Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: isActive ? activeTextIconColor : inactiveColor),
                  const SizedBox(width: 8),
                  Text(text, style: TextStyle( color: isActive ? activeTextIconColor : inactiveColor, fontWeight: FontWeight.w500, fontSize: 16)),
                ],
              ),
            ),
          );
   }


  Widget _buildListView() {
    return _filteredPharmacies.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.location_off, size: 48, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  '${_selectedDistance.toInt()} km mesafede eczane bulunamadı',
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedDistance = 30.0; 
                      _filterPharmaciesByDistance();
                    });
                  },
                  child: const Text('Daha geniş alanda ara'),
                ),
              ],
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            itemCount: _filteredPharmacies.length,
            itemBuilder: (context, index) {
              final pharmacy = _filteredPharmacies[index];
              // Mesafe hesaplama
              double distance = _calculateDistance(pharmacy);
              return _buildPharmacyItem(context, pharmacy, distance);
            },
          );
  }


  // --- Harita Görünümü ---
  Widget _buildMapView() {
    final markers = <Marker>[];

    // 1. Kullanıcı Konum Markeri
    markers.add(
      Marker(
        width: 80.0,
        height: 80.0,
        point: widget.userLocation,
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
             Tooltip( // Üzerine gelince veya uzun basınca yazı çıkarır
               message: 'Konumunuz',
               child: Icon(Icons.person_pin_circle, color: Colors.blueAccent, size: 40,
                  shadows: [Shadow(color: Colors.black54, blurRadius: 5)]), // Gölge
             ),
             Text('Siz', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, backgroundColor: Colors.white70)),
          ],
        ),
      ),
    );

    // 2. Filtrelenmiş Eczane Markerları
    for (var pharmacy in _filteredPharmacies) {
      if (pharmacy.loc != null && pharmacy.loc!.isNotEmpty) {
        try {
           final coordinates = pharmacy.loc!.split(',');
           if (coordinates.length == 2) {
             final latStr = coordinates[0].trim(); final lngStr = coordinates[1].trim();
             if (latStr.isNotEmpty && lngStr.isNotEmpty) {
               final lat = double.tryParse(latStr); final lng = double.tryParse(lngStr);
                if (lat != null && lng != null && lat >= -90 && lat <= 90 && lng >= -180 && lng <= 180) {
                     markers.add(
                       Marker(
                         width: 80.0, height: 80.0, point: LatLng(lat, lng),
                         child: GestureDetector(
                           onTap: () { _showPharmacyDetails(pharmacy); },
                           child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Tooltip(
                                     message: pharmacy.name ?? 'Eczane',
                                     child: Container(
                                        decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black38, blurRadius: 4, offset: Offset(0, 2))]),
                                        padding: const EdgeInsets.all(8),
                                        child: const Icon(Icons.local_pharmacy, color: Colors.white, size: 20)),
                                  ),
                                  const SizedBox(height: 4),
                                  Container( padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2), decoration: BoxDecoration(color: Colors.white.withOpacity(0.8), borderRadius: BorderRadius.circular(4)),
                                      child: Text(pharmacy.name ?? 'Eczane', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black87),
                                          overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, maxLines: 1)),
                                ],
                           ),
                         ),
                       ),
                     );
                 }
             }
           }
        } catch (e) {
          print('Harita marker hatası (${pharmacy.name}): $e');
        }
      }
    }

    final LatLng initialCenter = widget.userLocation;
    double initialZoom = 14.0; 
    
    if (_selectedDistance <= 5) {
      initialZoom = 15.0;
    } else if (_selectedDistance <= 10) {
      initialZoom = 14.0;
    } else if (_selectedDistance <= 20) {
      initialZoom = 13.0;
    } else {
      initialZoom = 12.0;
    }

    return _filteredPharmacies.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.location_off, size: 48, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  '${_selectedDistance.toInt()} km mesafede eczane bulunamadı',
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedDistance = 30.0;
                      _filterPharmaciesByDistance();
                    });
                  },
                  child: const Text('Daha geniş alanda ara'),
                ),
              ],
            ),
          )
        : Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: initialCenter,
                  initialZoom: initialZoom,
                  minZoom: 5.0,
                  maxZoom: 18.0,
                ),
                children: [
                   TileLayer(
                     urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                     subdomains: const ['a', 'b', 'c'],
                     userAgentPackageName: 'com.example.gaziantep_nobetci_eczane', 
                   ),
                   MarkerLayer(markers: markers),
                   CircleLayer(
                     circles: [
                       CircleMarker(
                         point: widget.userLocation,
                         radius: _selectedDistance * 1000, 
                         color: Colors.red.withOpacity(0.1),
                         borderColor: Colors.red.withOpacity(0.5),
                         borderStrokeWidth: 2,
                       ),
                     ],
                   ),
                ],
              ),
               Positioned(
                 right: 16, bottom: 16,
                 child: Column(
                   mainAxisSize: MainAxisSize.min,
                   children: [
                     FloatingActionButton(
                       heroTag: null, 
                       mini: true, backgroundColor: Colors.white, foregroundColor: Colors.black,
                       child: const Icon(Icons.add),
                       onPressed: () {
                          try {
                            final currentZoom = _mapController.camera.zoom;
                            if (currentZoom < 18.0) { _mapController.move(_mapController.camera.center, currentZoom + 1); }
                          } catch (e) { print('Zoom in error: $e'); }
                       },
                     ),
                      const SizedBox(height: 8),
                      FloatingActionButton(
                        heroTag: null, 
                        mini: true, backgroundColor: Colors.white, foregroundColor: Colors.black,
                        child: const Icon(Icons.remove),
                        onPressed: () {
                          try {
                             final currentZoom = _mapController.camera.zoom;
                             if (currentZoom > 5.0) { _mapController.move(_mapController.camera.center, currentZoom - 1); }
                           } catch (e) { print('Zoom out error: $e'); }
                        },
                     ),
                   ],
                 ),
               ),
               Positioned(
                  right: 16, top: 16,
                  child: FloatingActionButton(
                    heroTag: null, 
                    mini: true, backgroundColor: Colors.white, foregroundColor: Colors.blue,
                    tooltip: 'Konumuma Odaklan',
                    child: const Icon(Icons.my_location),
                    onPressed: () {
                      try { 
                        _mapController.move(initialCenter, initialZoom);
                      } catch (e) { print('Harita reset hatası: $e'); }
                    },
                  ),
               ),
            ],
          );
  }

  void _showPharmacyDetails(Result pharmacy) {
     showModalBottomSheet(
      context: context,
      isScrollControlled: true, 
      shape: const RoundedRectangleBorder( borderRadius: BorderRadius.vertical(top: Radius.circular(20)), ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.4, minChildSize: 0.3, maxChildSize: 0.6, 
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: _buildPharmacyDetailCard(pharmacy), 
        ),
      ),
    );
  }

  Widget _buildPharmacyDetailCard(Result pharmacy) {
     double distance = _calculateDistance(pharmacy);
     String formattedDistance = distance > 0 ? _formatDistance(distance) : "";

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
               Expanded(
                 child: Text(pharmacy.name?.toUpperCase() ?? 'İSİM YOK',
                   style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
               ),
               if (formattedDistance.isNotEmpty)
                  Text(formattedDistance, style: const TextStyle(fontSize: 14, color: Colors.blue, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 15),
          Row( crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Icon(Icons.location_on, size: 22, color: Colors.grey),
              const SizedBox(width: 10),
              Expanded(child: Text(pharmacy.address ?? 'Adres belirtilmemiş', style: const TextStyle(fontSize: 16, color: Colors.grey))),
          ]),
          const SizedBox(height: 10),
          if (pharmacy.phone != null && pharmacy.phone!.trim().isNotEmpty)
            Padding( padding: const EdgeInsets.only(top: 10), child: Row(children: [
                const Icon(Icons.phone, size: 22, color: Colors.grey),
                const SizedBox(width: 10),
                Text(pharmacy.phone!, style: const TextStyle(fontSize: 16, color: Colors.grey)),
            ])),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: ElevatedButton.icon(
                  onPressed: () {
                     Navigator.pop(context);
                     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Arama (${pharmacy.phone ?? 'Numara Yok'}) yakında!'), backgroundColor: Colors.green));
                  },
                  icon: const Icon(Icons.phone), label: const Text('Ara'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              )),
              const SizedBox(width: 10),
              Expanded(child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context); 
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Yön Tarifi (${pharmacy.loc ?? 'Konum Yok'}) yakında!'), backgroundColor: Colors.blue));
                  },
                  icon: const Icon(Icons.directions), label: const Text('Yön Tarifi'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              )),
            ],
          ),
        ],
      ),
    );
  }


  Widget _buildPharmacyItem(BuildContext context, Result pharmacy, double distance) {
    String formattedDistance = distance > 0 ? _formatDistance(distance) : "";
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [ BoxShadow( color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 3, offset: const Offset(0, 1),),],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                   child: Text(pharmacy.name?.toUpperCase() ?? 'İSİM YOK',
                     style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                 ),
                 if (formattedDistance.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(formattedDistance, style: const TextStyle(fontSize: 14, color: Colors.blueAccent, fontWeight: FontWeight.bold)),
                    ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            child: Row( crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Icon(Icons.location_on_outlined, size: 20, color: Colors.grey), 
                const SizedBox(width: 10),
                Expanded(child: Text(pharmacy.address ?? 'Adres belirtilmemiş', style: const TextStyle(fontSize: 15, color: Colors.grey))), // Biraz daha küçük font
            ]),
          ),

          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _buildActionButton(context, Icons.phone, 'Ara', Colors.green, Color(0xFFE8F5E9), BorderRadius.only(bottomLeft: Radius.circular(15)), () {
                 ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Arama (${pharmacy.phone ?? 'Numara Yok'}) yakında!'), backgroundColor: Colors.green));
              })),
              Expanded(child: _buildActionButton(context, Icons.directions, 'Yön Tarifi', Colors.blue, Color(0xFFE3F2FD), BorderRadius.only(bottomRight: Radius.circular(15)), () {
                 ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Yön Tarifi (${pharmacy.loc ?? 'Konum Yok'}) yakında!'), backgroundColor: Colors.blue));
              })),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, IconData icon, String label, Color color, Color backgroundColor, BorderRadius borderRadius, VoidCallback onPressed) {
     return InkWell(
       onTap: onPressed,
       borderRadius: borderRadius,
       child: Container(
         padding: const EdgeInsets.symmetric(vertical: 16),
         decoration: BoxDecoration( color: backgroundColor, borderRadius: borderRadius,),
         child: Row(
           mainAxisAlignment: MainAxisAlignment.center,
           children: [
             Icon(icon, color: color, size: 20),
             const SizedBox(width: 8),
             Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w500, fontSize: 16)),
           ],
         ),
       ),
     );
  }
}