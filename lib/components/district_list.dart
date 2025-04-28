import 'package:flutter/material.dart';
import 'package:gaziantep_nobetci_eczane/model/pharmacy_model.dart';
import 'district_item.dart';

class DistrictList extends StatelessWidget {
  final List<String> districts;
  final Map<String, List<Result>> districtPharmacies;
  final String city;

  const DistrictList({
    super.key,
    required this.districts,
    required this.districtPharmacies,
    required this.city,
  });

  @override
  Widget build(BuildContext context) {
    Map<String, List<String>> alphabetGroups = {};

    for (var district in districts) {
      String firstLetter = district.substring(0, 1).toUpperCase();
      if (!alphabetGroups.containsKey(firstLetter)) {
        alphabetGroups[firstLetter] = [];
      }
      alphabetGroups[firstLetter]!.add(district);
    }

    final sortedLetters = alphabetGroups.keys.toList()..sort();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedLetters.length,
      itemBuilder: (context, index) {
        final letter = sortedLetters[index];
        final districts = alphabetGroups[letter]!..sort();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 16, bottom: 8),
              child: Text(
                letter,
                style:  TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color:  Colors.redAccent.shade700
                ),
              ),
            ),
            ...districts.map(
              (district) => DistrictItem(
                district: district,
                pharmacies: districtPharmacies[district] ?? [],
                city: city,
              ),
            ),
          ],
        );
      },
    );
  }
}