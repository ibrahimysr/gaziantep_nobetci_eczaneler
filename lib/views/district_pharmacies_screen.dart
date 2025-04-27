
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:gaziantep_nobetci_eczane/components/app_bar.dart';
import 'package:gaziantep_nobetci_eczane/model/pharmacy_model.dart';

class DistrictPharmaciesPage extends StatefulWidget {
  final String districtName;
  final List<Result> pharmacies;
  final String cityName;

  const DistrictPharmaciesPage({
    super.key,
    required this.districtName,
    required this.pharmacies,
    required this.cityName,
  });

  @override
  State<DistrictPharmaciesPage> createState() => _DistrictPharmaciesPageState();
}

class _DistrictPharmaciesPageState extends State<DistrictPharmaciesPage> {
  bool _showListView = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: widget.districtName),
      backgroundColor: const Color(0xFFF6F6F6),
      body: Column(
        children: [
          _buildSegmentedControl(context),
          Expanded(
            child: _showListView ? _buildListView() : _buildMapView()
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
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _showListView = true;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: _showListView ? Colors.red : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.list, color: _showListView ? Colors.white : Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      'Liste',
                      style: TextStyle(
                        color: _showListView ? Colors.white : Colors.grey,
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _showListView = false;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: !_showListView ? Colors.red : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.map, color: !_showListView ? Colors.white : Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      'Harita',
                      style: TextStyle(
                        color: !_showListView ? Colors.white : Colors.grey,
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListView() {
    return widget.pharmacies.isEmpty
      ? const Center(child: Text('Bu ilçede nöbetçi eczane bulunamadı.'))
      : ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          itemCount: widget.pharmacies.length,
          itemBuilder: (context, index) {
            final pharmacy = widget.pharmacies[index];
            return _buildPharmacyItem(context, pharmacy);
          },
        );
  }

 Widget _buildMapView() {
  // Default coordinates for Gaziantep city center
  final defaultLatLng = LatLng(37.0662, 37.3833);
  
  // Create markers for each pharmacy with coordinates
  final markers = <Marker>[];
  
  // Controller for map zoom functionality
  final mapController = MapController();
  
  // Parse pharmacy locations and create markers
  for (var pharmacy in widget.pharmacies) {
    // Parse location from loc field (expecting format like "37.1234,37.5678")
    if (pharmacy.loc != null && pharmacy.loc!.isNotEmpty) {
      try {
        final coordinates = pharmacy.loc!.split(',');
        if (coordinates.length == 2) {
          final latStr = coordinates[0].trim();
          final lngStr = coordinates[1].trim();
          
          // Additional validation to ensure we have valid coordinates
          if (latStr.isNotEmpty && lngStr.isNotEmpty) {
            final lat = double.tryParse(latStr);
            final lng = double.tryParse(lngStr);
            
            if (lat != null && lng != null && 
                lat >= -90 && lat <= 90 && lng >= -180 && lng <= 180) {
              markers.add(
                Marker(
                  width: 80.0,
                  height: 80.0,
                  point: LatLng(lat, lng),
                  child: GestureDetector(
                    onTap: () {
                      _showPharmacyDetails(pharmacy);
                    },
                    child: Column(
                      children: [
                        Container(
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(8),
                          child: const Icon(Icons.local_pharmacy, color: Colors.white, size: 20),
                        ),
                        Container(
                          width: 70,
                          child: Text(
                            pharmacy.name ?? 'Eczane',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              backgroundColor: Colors.white70,
                            ),
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
          }
        }
      } catch (e) {
        // Log error and continue with next pharmacy
        print('Error parsing coordinates for pharmacy: ${pharmacy.name}, loc: ${pharmacy.loc}, error: $e');
      }
    }
  }

  // Find center of map from available markers - with error handling
  LatLng center = defaultLatLng;
  if (markers.isNotEmpty) {
    try {
      double sumLat = 0;
      double sumLng = 0;
      int validCount = 0;
      
      for (var marker in markers) {
        // Additional validation
        if (marker.point.latitude.isFinite && marker.point.longitude.isFinite) {
          sumLat += marker.point.latitude;
          sumLng += marker.point.longitude;
          validCount++;
        }
      }
      
      if (validCount > 0) {
        center = LatLng(sumLat / validCount, sumLng / validCount);
      }
    } catch (e) {
      print('Error calculating map center: $e');
      // Fallback to default if calculation fails
      center = defaultLatLng;
    }
  }
  
  return widget.pharmacies.isEmpty
    ? const Center(child: Text('Bu ilçede nöbetçi eczane bulunamadı.'))
    : markers.isEmpty
        ? const Center(child: Text('Konum bilgisi olan eczane bulunamadı.'))
        : Stack(
            children: [
              FlutterMap(
                mapController: mapController,
                options: MapOptions(
                  initialCenter: center,
                  initialZoom: 12.0,
                  minZoom: 3.0,
                  maxZoom: 18.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                    subdomains: const ['a', 'b', 'c'],
                  ),
                  MarkerLayer(markers: markers),
                ],
              ),
              // Zoom control buttons
              Positioned(
                right: 16,
                bottom: 16,
                child: Column(
                  children: [
                    FloatingActionButton(
                      heroTag: "btn1",
                      mini: true,
                      backgroundColor: Colors.white,
                      child: const Icon(Icons.add, color: Colors.black),
                      onPressed: () {
                        try {
                          final currentZoom = mapController.camera.zoom;
                          if (currentZoom < 18.0) {
                            mapController.move(mapController.camera.center, currentZoom + 1);
                          }
                        } catch (e) {
                          print('Error during zoom in: $e');
                        }
                      },
                    ),
                    const SizedBox(height: 8),
                    FloatingActionButton(
                      heroTag: "btn2",
                      mini: true,
                      backgroundColor: Colors.white,
                      child: const Icon(Icons.remove, color: Colors.black),
                      onPressed: () {
                        try {
                          final currentZoom = mapController.camera.zoom;
                          if (currentZoom > 3.0) {
                            mapController.move(mapController.camera.center, currentZoom - 1);
                          }
                        } catch (e) {
                          print('Error during zoom out: $e');
                        }
                      },
                    ),
                  ],
                ),
              ),
              Positioned(
                right: 16,
                top: 16,
                child: FloatingActionButton(
                  heroTag: "btnReset",
                  mini: true,
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.my_location, color: Colors.blue),
                  onPressed: () {
                    try {
                      mapController.move(center, 12.0);
                    } catch (e) {
                      print('Error resetting map view: $e');
                    }
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.4,
        minChildSize: 0.3,
        maxChildSize: 0.6,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: _buildPharmacyDetailCard(pharmacy),
        ),
      ),
    );
  }

  Widget _buildPharmacyDetailCard(Result pharmacy) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            pharmacy.name?.toUpperCase() ?? 'İSİM YOK',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.location_on,
                size: 22,
                color: Colors.grey,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  pharmacy.address ?? 'Adres belirtilmemiş',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                Icons.access_time,
                size: 22,
                color: Colors.grey,
              ),
              const SizedBox(width: 10),
              Text(
                '26/04/2025 19:00-09:00',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          if (pharmacy.phone != null && pharmacy.phone!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Row(
                children: [
                  const Icon(
                    Icons.phone,
                    size: 22,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    pharmacy.phone!,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Arama özelliği yakında eklenecek'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  icon: const Icon(Icons.phone, color: Colors.white),
                  label: const Text('Ara'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Yön tarifi özelliği yakında eklenecek'),
                        backgroundColor: Colors.blue,
                      ),
                    );
                  },
                  icon: const Icon(Icons.directions, color: Colors.white),
                  label: const Text('Yön Tarifi'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  } 

  

  Widget _buildPharmacyItem(BuildContext context, Result pharmacy) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
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
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Text(
              pharmacy.name?.toUpperCase() ?? 'İSİM YOK',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.location_on,
                  size: 22,
                  color: Colors.grey,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    pharmacy.address ?? 'Adres belirtilmemiş',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            child: Row(
              children: [
                const Icon(
                  Icons.access_time,
                  size: 22,
                  color: Colors.grey,
                ),
                const SizedBox(width: 10),
                Text(
                  '26/04/2025 19:00-09:00',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Arama özelliği yakında eklenecek'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: const BoxDecoration(
                      color: Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(15),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.phone,
                          color: Colors.green,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Ara',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Yön tarifi özelliği yakında eklenecek'),
                        backgroundColor: Colors.blue,
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: const BoxDecoration(
                      color: Color(0xFFE3F2FD),
                      borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(15),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.directions,
                          color: Colors.blue,
                          size: 22,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Yön Tarifi',
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  } 

  
} 