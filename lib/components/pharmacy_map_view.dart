import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:gaziantep_nobetci_eczane/model/pharmacy_model.dart';

class PharmacyMapView extends StatelessWidget {
  final List<Result> pharmacies;
  final MapController mapController;
  final Function(Result) onPharmacyTap;

  const PharmacyMapView({
    super.key,
    required this.pharmacies,
    required this.mapController,
    required this.onPharmacyTap,
  });

  @override
  Widget build(BuildContext context) {
    final defaultLatLng = LatLng(37.0662, 37.3833);
    final markers = <Marker>[];
    LatLng center = defaultLatLng;
    bool firstValidCenterFound = false;
    double initialZoom = 11.0;

    for (var pharmacy in pharmacies) {
      final pharmacyName = pharmacy.name ?? "İsimsiz Eczane";
      final locString = pharmacy.loc;

      if (locString != null && locString.isNotEmpty) {
        try {
          final coordinates = locString.split(',');
          if (coordinates.length == 2) {
            final latStr = coordinates[0].trim();
            final lngStr = coordinates[1].trim();

            if (latStr.isNotEmpty && lngStr.isNotEmpty) {
              final lat = double.tryParse(latStr);
              final lng = double.tryParse(lngStr);

              if (lat != null && lng != null && lat >= -90 && lat <= 90 && lng >= -180 && lng <= 180) {
                final currentPoint = LatLng(lat, lng);

                markers.add(
                  Marker(
                    width: 80.0,
                    height: 80.0,
                    point: currentPoint,
                    child: GestureDetector(
                      onTap: () => onPharmacyTap(pharmacy),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))
                              ],
                            ),
                            padding: const EdgeInsets.all(8),
                            child: const Icon(Icons.local_pharmacy, color: Colors.white, size: 20),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              pharmacyName,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
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

                if (!firstValidCenterFound) {
                  center = currentPoint;
                  firstValidCenterFound = true;
                  initialZoom = 14.0;
                }
              }
            }
          }
        } catch (e) {}
      }
    }

    if (pharmacies.isEmpty) {
      return const Center(child: Text('Bu ilçede nöbetçi eczane bulunamadı.'));
    }

    return Stack(
      children: [
        FlutterMap(
          mapController: mapController,
          options: MapOptions(
            initialCenter: center,
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
            if (markers.isNotEmpty)
              MarkerLayer(
                markers: markers,
                rotate: false,
              ),
          ],
        ),
        Positioned(
          right: 16,
          bottom: 16,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FloatingActionButton(
                heroTag: "map_zoom_in",
                mini: true,
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                child: const Icon(Icons.add),
                onPressed: () {
                  try {
                    final currentZoom = mapController.camera.zoom;
                    if (currentZoom < 18.0) {
                      mapController.move(mapController.camera.center, currentZoom + 1);
                    }
                  } catch (e) {}
                },
              ),
              const SizedBox(height: 8),
              FloatingActionButton(
                heroTag: "map_zoom_out",
                mini: true,
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                child: const Icon(Icons.remove),
                onPressed: () {
                  try {
                    final currentZoom = mapController.camera.zoom;
                    if (currentZoom > 5.0) {
                      mapController.move(mapController.camera.center, currentZoom - 1);
                    }
                  } catch (e) {}
                },
              ),
            ],
          ),
        ),
        Positioned(
          right: 16,
          top: 16,
          child: FloatingActionButton(
            heroTag: "map_reset_center",
            mini: true,
            backgroundColor: Colors.white,
            foregroundColor: Colors.blue,
            child: const Icon(Icons.my_location),
            onPressed: () {
              try {
                mapController.move(center, initialZoom);
              } catch (e) {}
            },
          ),
        ),
      ],
    );
  }
}