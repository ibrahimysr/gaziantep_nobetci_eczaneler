import 'package:flutter/material.dart';
import 'package:gaziantep_nobetci_eczane/model/pharmacy_model.dart';

class HomeContainer extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color iconBackground;
  final LinearGradient gradient;
  final Function()? onTap;

  const HomeContainer({
    super.key,
    required this.icon,
    required this.title,
    required this.iconBackground,
    required this.gradient,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // ... (Önceki yanıttaki HomeContainer kodu buraya gelecek) ...
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: iconBackground.withOpacity(0.3),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        icon,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PharmacyWithDistance {
  final Result pharmacy;
  final double distanceInMeters;

  PharmacyWithDistance(this.pharmacy, this.distanceInMeters);
}
