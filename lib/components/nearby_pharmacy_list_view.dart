import 'package:flutter/material.dart';
import 'package:gaziantep_nobetci_eczane/model/pharmacy_model.dart';
import 'package:gaziantep_nobetci_eczane/components/nearby_pharmacy_item.dart';

class NearbyPharmacyListView extends StatelessWidget {
  final List<Result> filteredPharmacies;
  final double selectedDistance;
  final Function(Result) onPharmacyTap;
  final double Function(Result) calculateDistance;
  final String Function(double) formatDistance;
  final VoidCallback onWiderSearch;

  const NearbyPharmacyListView({
    super.key,
    required this.filteredPharmacies,
    required this.selectedDistance,
    required this.onPharmacyTap,
    required this.calculateDistance,
    required this.formatDistance,
    required this.onWiderSearch,
  });

  @override
  Widget build(BuildContext context) {
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
                  onPressed: onWiderSearch,
                  child: const Text('Daha geniş alanda ara'),
                ),
              ],
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            itemCount: filteredPharmacies.length,
            itemBuilder: (context, index) {
              final pharmacy = filteredPharmacies[index];
              double distance = calculateDistance(pharmacy);
              return NearbyPharmacyItem(
                pharmacy: pharmacy,
                distance: distance,
                formatDistance: formatDistance,
                onTap: () => onPharmacyTap(pharmacy),
              );
            },
          );
  }
}