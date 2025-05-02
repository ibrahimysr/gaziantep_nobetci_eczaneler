import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:gaziantep_nobetci_eczane/model/pharmacy_model.dart';

class NearbyPharmacyMapView extends StatelessWidget {
  final List<Result> filteredPharmacies;
  final LatLng userLocation;
  final double selectedDistance;
  final MapController mapController;
  final Function(Result) onPharmacyTap;

  const NearbyPharmacyMapView({
    super.key,
    required this.filteredPharmacies,
    required this.userLocation,
    required this.selectedDistance,
    required this.mapController,
    required this.onPharmacyTap,
  });

  @override
  Widget build(BuildContext context) {
    final markers = <Marker>[];

    markers.add(
      Marker(
        width: 80.0,
        height: 80.0,
        point: userLocation,
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Tooltip(
              message: 'Konumunuz',
              child: Icon(
                Icons.person_pin_circle,
                color: Colors.blueAccent,
                size: 40,
                shadows: [Shadow(color: Colors.black54, blurRadius: 5)],
              ),
            ),
            Text(
              'Siz',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                backgroundColor: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );

    for (var pharmacy in filteredPharmacies) {
      if (pharmacy.loc != null && pharmacy.loc!.isNotEmpty) {
        try {
          final coordinates = pharmacy.loc!.split(',');
          if (coordinates.length == 2) {
            final latStr = coordinates[0].trim();
            final lngStr = coordinates[1].trim();
            if (latStr.isNotEmpty && lngStr.isNotEmpty) {
              final lat = double.tryParse(latStr);
              final lng = double.tryParse(lngStr);
              if (lat != null &&
                  lng != null &&
                  lat >= -90 &&
                  lat <= 90 &&
                  lng >= -180 &&
                  lng <= 180) {
                markers.add(
                  Marker(
                    width: 80.0,
                    height: 80.0,
                    point: LatLng(lat, lng),
                    child: GestureDetector(
                      onTap: () => onPharmacyTap(pharmacy),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Tooltip(
                            message: pharmacy.name ?? 'Eczane',
                            child: Container(
                              decoration: const BoxDecoration(
                              
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black38,
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  )
                                ],
                              ),
                              padding: const EdgeInsets.all(8),
                              child: const Icon(
                                Icons.local_pharmacy,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha:0.8),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              pharmacy.name ?? 'Eczane',
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
              }
            }
          }
        } catch (e) { 
          log("error: $e");
        }
      }
    }

    final LatLng initialCenter = userLocation;
    double initialZoom = 14.0;
    if (selectedDistance <= 5) {
      initialZoom = 15.0;
    } else if (selectedDistance <= 10) {
      initialZoom = 14.0;
    } else if (selectedDistance <= 20) {
      initialZoom = 13.0;
    } else {
      initialZoom = 12.0;
    }

    return filteredPharmacies.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.location_off, size: 48, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  '${selectedDistance.toInt()} km mesafede eczane bulunamadı',
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    // Handled in parent widget
                  },
                  child: const Text('Daha geniş alanda ara'),
                ),
              ],
            ),
          )
        : Stack(
            children: [
              FlutterMap(
                mapController: mapController,
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
                        point: userLocation,
                        radius: selectedDistance * 1000,
                        color: Colors.red,
                        borderColor: Colors.red.withValues(alpha:0.5),
                        borderStrokeWidth: 2,
                      ),
                    ],
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
                      heroTag: null,
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
                        } catch (e) { 
                          log("error: $e");
                        }
                      },
                    ),
                    const SizedBox(height: 8),
                    FloatingActionButton(
                      heroTag: null,
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
                        } catch (e) { 
                          log("error: $e");
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
                  heroTag: null,
                  mini: true,
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.blue,
                  tooltip: 'Konumuma Odaklan',
                  child: const Icon(Icons.my_location),
                  onPressed: () {
                    try {
                      mapController.move(initialCenter, initialZoom);
                    } catch (e) { 
                      log("error: $e");
                    }
                  },
                ),
              ),
            ],
          );
  }
}