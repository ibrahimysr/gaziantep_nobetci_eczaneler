import 'package:flutter/material.dart';

class NearbyDistanceSlider extends StatelessWidget {
  final double selectedDistance;
  final List<double> distanceOptions;
  final int filteredPharmaciesCount;
  final Function(double) onDistanceChanged;

  const NearbyDistanceSlider({
    super.key,
    required this.selectedDistance,
    required this.distanceOptions,
    required this.filteredPharmaciesCount,
    required this.onDistanceChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(30, 20, 30, 0),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha:0.1),
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
                "Mesafe: ${selectedDistance.toInt()} km",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                "$filteredPharmaciesCount eczane bulundu",
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
              inactiveTrackColor: Colors.red.withValues(alpha:0.2),
              thumbColor: Colors.red,
              overlayColor: Colors.red.withValues(alpha:0.2),
              tickMarkShape: const RoundSliderTickMarkShape(tickMarkRadius: 3),
              activeTickMarkColor: Colors.white,
              inactiveTickMarkColor: Colors.red.withValues(alpha:0.5),
            ),
            child: Slider(
              value: selectedDistance,
              min: distanceOptions.first,
              max: distanceOptions.last,
              divisions: distanceOptions.length - 1,
              label: "${selectedDistance.toInt()} km",
              onChanged: onDistanceChanged,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: distanceOptions.map((option) {
                return Text(
                  option.toInt().toString(),
                  style: TextStyle(
                    fontSize: 12,
                    color: selectedDistance == option ? Colors.red : Colors.grey,
                    fontWeight: selectedDistance == option
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
}