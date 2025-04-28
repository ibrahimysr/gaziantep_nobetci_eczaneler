import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:gaziantep_nobetci_eczane/components/app_bar.dart';
import 'package:gaziantep_nobetci_eczane/components/nearby_distance_slider.dart';
import 'package:gaziantep_nobetci_eczane/components/nearby_segmented_control.dart';
import 'package:gaziantep_nobetci_eczane/components/nearby_pharmacy_list_view.dart';
import 'package:gaziantep_nobetci_eczane/components/nearby_pharmacy_map_view.dart';
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
  final List<double> _distanceOptions = [5, 10, 15, 20, 25, 30, 35, 40, 50];
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
        if (lat == null ||
            lng == null ||
            lat < -90 ||
            lat > 90 ||
            lng < -180 ||
            lng > 180) {
          return false;
        }
        double distanceInMeters = Geolocator.distanceBetween(
          widget.userLocation.latitude,
          widget.userLocation.longitude,
          lat,
          lng,
        );
        return distanceInMeters / 1000 <= _selectedDistance;
      } catch (e) {
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
      if (lat == null ||
          lng == null ||
          lat < -90 ||
          lat > 90 ||
          lng < -180 ||
          lng > 180) {
        return double.infinity;
      }
      return Geolocator.distanceBetween(
        widget.userLocation.latitude,
        widget.userLocation.longitude,
        lat,
        lng,
      );
    } catch (e) {
      return double.infinity;
    }
  }

  String _formatDistance(double distanceInMeters) {
    if (distanceInMeters < 10) {
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
          NearbyDistanceSlider(
            selectedDistance: _selectedDistance,
            distanceOptions: _distanceOptions,
            filteredPharmaciesCount: _filteredPharmacies.length,
            onDistanceChanged: (value) {
              setState(() {
                _selectedDistance = value;
                _filterPharmaciesByDistance();
              });
            },
          ),
          NearbySegmentedControl(
            showListView: _showListView,
            onListViewTap: () {
              if (!_showListView) {
                setState(() {
                  _showListView = true;
                });
              }
            },
            onMapViewTap: () {
              if (_showListView) {
                setState(() {
                  _showListView = false;
                });
              }
            },
          ),
          Expanded(
            child: _showListView
                ? NearbyPharmacyListView(
                    filteredPharmacies: _filteredPharmacies,
                    selectedDistance: _selectedDistance,
                    onPharmacyTap: _showPharmacyDetails,
                    calculateDistance: _calculateDistance,
                    formatDistance: _formatDistance,
                    onWiderSearch: () {
                      setState(() {
                        _selectedDistance = 30.0;
                        _filterPharmaciesByDistance();
                      });
                    },
                  )
                : NearbyPharmacyMapView(
                    filteredPharmacies: _filteredPharmacies,
                    userLocation: widget.userLocation,
                    selectedDistance: _selectedDistance,
                    mapController: _mapController,
                    onPharmacyTap: _showPharmacyDetails,
                  ),
          ),
        ],
      ),
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
                child: Text(
                  pharmacy.name?.toUpperCase() ?? 'İSİM YOK',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              if (formattedDistance.isNotEmpty)
                Text(
                  formattedDistance,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on, size: 22, color: Colors.grey),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  pharmacy.address ?? 'Adres belirtilmemiş',
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (pharmacy.phone != null && pharmacy.phone!.trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Row(
                children: [
                  const Icon(Icons.phone, size: 22, color: Colors.grey),
                  const SizedBox(width: 10),
                  Text(
                    pharmacy.phone!,
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
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
                      SnackBar(
                        content:
                            Text('Arama (${pharmacy.phone ?? 'Numara Yok'}) yakında!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  icon: const Icon(Icons.phone),
                  label: const Text('Ara'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Yön Tarifi (${pharmacy.loc ?? 'Konum Yok'}) yakında!'),
                        backgroundColor: Colors.blue,
                      ),
                    );
                  },
                  icon: const Icon(Icons.directions),
                  label: const Text('Yön Tarifi'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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