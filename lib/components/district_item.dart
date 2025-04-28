import 'package:flutter/material.dart';
import 'package:gaziantep_nobetci_eczane/core/theme/color.dart';
import 'package:gaziantep_nobetci_eczane/model/pharmacy_model.dart';
import 'package:gaziantep_nobetci_eczane/views/district_pharmacies_screen.dart';

class DistrictItem extends StatelessWidget {
  final String district;
  final List<Result> pharmacies;
  final String city;

  const DistrictItem({
    super.key,
    required this.district,
    required this.pharmacies,
    required this.city,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        title: Text(
          district,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing:  Icon(Icons.chevron_right, color:  Colors.redAccent.shade700,),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        onTap: () {
          if (pharmacies.isNotEmpty) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DistrictPharmaciesPage(
                  districtName: district,
                  pharmacies: pharmacies,
                  cityName: city,
                ),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('$district ilçesinde nöbetçi eczane bulunamadı.'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        },
      ),
    );
  }
}