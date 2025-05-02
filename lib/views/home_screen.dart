import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:gaziantep_nobetci_eczane/components/home_container.dart';
import 'package:gaziantep_nobetci_eczane/core/theme/color.dart';
import 'package:gaziantep_nobetci_eczane/views/nearby_pharmacies_screen.dart';
import 'package:gaziantep_nobetci_eczane/views/pharmacy_list_page.dart';
import 'package:gaziantep_nobetci_eczane/model/pharmacy_model.dart';
import 'package:gaziantep_nobetci_eczane/service/pharmacy/pharmacy_service.dart';
import 'package:gaziantep_nobetci_eczane/env.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PharmacyService _pharmacyService = PharmacyService();
  final String _city = "gaziantep";
  final String _apikey = AppSecrets.collectApiKey;

  bool _isGettingLocationAndPharmacies = false;

  Future<void> _findNearbyPharmacies() async {
    if (_isGettingLocationAndPharmacies) return;

    setState(() {
      _isGettingLocationAndPharmacies = true;
    });

    LocationPermission permission;
    Position? currentPosition;
    List<Result> allPharmacies = [];

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Konum servisleri kapalı. Lütfen açıp tekrar deneyin.');
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception(
              'Yakındaki eczaneleri bulmak için konum izni vermelisiniz.');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception(
            'Konum izni kalıcı olarak reddedildi. Lütfen uygulama ayarlarından izin verin.');
      }

      log("Getting current location...");
      currentPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium);
      log(
          "Location obtained: ${currentPosition.latitude}, ${currentPosition.longitude}");

      log("Fetching pharmacies from API for city: $_city");
      try {
        final response =
            await _pharmacyService.getPharmacies(city: _city, apikey: _apikey);

        if (response.success == true &&
            response.result != null &&
            response.result!.isNotEmpty) {
          allPharmacies = response.result!; 
        } else {
          throw Exception('$_city için nöbetçi eczane bulunamadı. ' '}');
        }
      } catch (e) {
        throw Exception('Eczaneler yüklenirken bir hata oluştu: $e');
      }

      List<PharmacyWithDistance> pharmaciesWithDistance = [];
      final userLatLng =
          // LatLng(currentPosition.latitude, currentPosition.longitude); 
          LatLng(37.0662, 37.3833); // Gaziantep coordinates for testing

      for (var pharmacy in allPharmacies) {
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
                  double distanceInMeters = Geolocator.distanceBetween(
                      userLatLng.latitude, userLatLng.longitude, lat, lng);
                  pharmaciesWithDistance
                      .add(PharmacyWithDistance(pharmacy, distanceInMeters));
                } else {
                  log(" Invalid range for ${pharmacy.name}");
                }
              } else {
                log(" Empty coord strings for ${pharmacy.name}");
              }
            } else {
              log(" Invalid format for ${pharmacy.name}");
            }
          } catch (e) {
            log(" Distance calc error for ${pharmacy.name}: $e");
          }
        } else {
          log(" Skipping ${pharmacy.name}, no loc.");
        }
      }

      if (pharmaciesWithDistance.isEmpty) {
        throw Exception('Konumu hesaplanabilen eczane bulunamadı.');
      }

      pharmaciesWithDistance
          .sort((a, b) => a.distanceInMeters.compareTo(b.distanceInMeters));
      List<Result> sortedPharmacies =
          pharmaciesWithDistance.map((pwd) => pwd.pharmacy).toList();

      setState(() {
        _isGettingLocationAndPharmacies = false;
      });

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NearbyPharmaciesPage(
              pharmacies: sortedPharmacies,
              userLocation: userLatLng,
            ),
          ),
        );
      }
    } catch (e) {
      log(e.toString());
      _showErrorSnackbar(e.toString().replaceFirst("Exception: ", ""));
      setState(() {
        _isGettingLocationAndPharmacies = false;
      });
    }
  }

  void _showErrorSnackbar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message, style: const TextStyle(color: Colors.white)),
          backgroundColor: Colors.redAccent,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.background,
        title: Text(
          'Eczaneler',
          style: TextStyle(
            color: AppColors.text,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.question_answer_rounded,
                color: AppColors.primary),
            onPressed: () {},
          ),
          IconButton(
            onPressed: () {},
            icon: Badge(
              label: const Text('2'),
              child: Icon(Icons.notifications_outlined, color: AppColors.text),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha:0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha:0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.medical_services_rounded,
                        color: AppColors.primary,
                        size: 36,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Gaziantep Nöbetçi',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.text,
                            ),
                          ),
                          Text(
                            'Eczaneler',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha:0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: AppColors.accent.withValues(alpha:0.3), width: 1),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.accent),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Size en yakın nöbetçi eczaneyi bulmak için konum izinlerini açınız.',
                        style: TextStyle(color: AppColors.text),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              HomeContainer(
                icon: Icons.map_outlined,
                title: "İLÇELERE GÖRE",
                iconBackground: AppColors.primary,
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withValues(alpha:0.8)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                onTap: () {
                  if (_isGettingLocationAndPharmacies) return;
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const PharmacyListPage()));
                },
              ),
              const SizedBox(height: 16),
              HomeContainer(
                icon: Icons.location_on_outlined,
                title: "YAKINIMDAKİLER",
                iconBackground: AppColors.secondary,
                gradient: LinearGradient(
                  colors: [
                    AppColors.secondary,
                    AppColors.secondary.withValues(alpha:0.8)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                onTap: _isGettingLocationAndPharmacies
                    ? null
                    : _findNearbyPharmacies,
              ),
              const SizedBox(height: 16),
              if (_isGettingLocationAndPharmacies)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(width: 16),
                      Text("Eczaneler ve konum yükleniyor...",
                          style: TextStyle(color: AppColors.text))
                    ],
                  ),
                ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
