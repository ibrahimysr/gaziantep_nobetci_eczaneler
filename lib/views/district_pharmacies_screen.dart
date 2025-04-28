import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:gaziantep_nobetci_eczane/components/app_bar.dart';
import 'package:gaziantep_nobetci_eczane/components/segmented_control.dart';
import 'package:gaziantep_nobetci_eczane/components/pharmacy_list_view.dart';
import 'package:gaziantep_nobetci_eczane/components/pharmacy_map_view.dart';
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
  final MapController _mapController = MapController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: widget.districtName),
      backgroundColor: const Color(0xFFF6F6F6),
      body: Column(
        children: [
          SegmentedControl(
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
                ? PharmacyListView(
                    pharmacies: widget.pharmacies,
                    onPharmacyTap: _showPharmacyDetails,
                  )
                : PharmacyMapView(
                    pharmacies: widget.pharmacies,
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
        minChildSize: 0.25,
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
        mainAxisSize: MainAxisSize.min,
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
                'Nöbet Zamanı Bilgisi Yok',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          if (pharmacy.phone != null && pharmacy.phone!.trim().isNotEmpty)
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
                      SnackBar(
                        content: Text('Arama özelliği (${pharmacy.phone ?? 'Numara Yok'}) yakında!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  icon: const Icon(Icons.phone, color: Colors.white),
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
                        content: Text('Yön tarifi (${pharmacy.loc ?? 'Konum Yok'}) yakında!'),
                        backgroundColor: Colors.blue,
                      ),
                    );
                  },
                  icon: const Icon(Icons.directions, color: Colors.white),
                  label: const Text('Yön Tarifi'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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