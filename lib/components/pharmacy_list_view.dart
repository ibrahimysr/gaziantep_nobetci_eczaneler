import 'package:flutter/material.dart';
import 'package:gaziantep_nobetci_eczane/model/pharmacy_model.dart';
import 'package:gaziantep_nobetci_eczane/components/pharmacy_item.dart';

class PharmacyListView extends StatelessWidget {
  final List<Result> pharmacies;
  final Function(Result) onPharmacyTap;

  const PharmacyListView({
    super.key,
    required this.pharmacies,
    required this.onPharmacyTap,
  });

  @override
  Widget build(BuildContext context) {
    return pharmacies.isEmpty
        ? const Center(child: Text('Bu ilçede nöbetçi eczane bulunamadı.'))
        : ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            itemCount: pharmacies.length,
            itemBuilder: (context, index) {
              final pharmacy = pharmacies[index];
              return PharmacyItem(
                pharmacy: pharmacy,
                onTap: () => onPharmacyTap(pharmacy),
              );
            },
          );
  }
}