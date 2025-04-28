import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:gaziantep_nobetci_eczane/components/app_bar.dart';
import 'package:gaziantep_nobetci_eczane/components/district_list.dart';
import 'package:gaziantep_nobetci_eczane/components/error_view.dart';
import 'package:gaziantep_nobetci_eczane/components/loading_indicator.dart';
import 'package:gaziantep_nobetci_eczane/components/search_bar.dart';
import 'package:gaziantep_nobetci_eczane/core/theme/color.dart';
import 'package:gaziantep_nobetci_eczane/env.dart';
import 'package:gaziantep_nobetci_eczane/model/pharmacy_model.dart';
import 'package:gaziantep_nobetci_eczane/service/pharmacy/pharmacy_service.dart';

class PharmacyListPage extends StatefulWidget {
  const PharmacyListPage({super.key});

  @override
  State<PharmacyListPage> createState() => _PharmacyListPageState();
}

class _PharmacyListPageState extends State<PharmacyListPage> {
  final PharmacyService _pharmacyService = PharmacyService();
  final String _city = "gaziantep";
  final String _apikey = AppSecrets.collectApiKey;

  Map<String, List<Result>> _districtPharmacies = {};
  List<String> _allDistricts = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _searchQuery = "";
  final TextEditingController _searchController = TextEditingController();

  final List<String> gaziantepDistricts = [
    "Araban",
    "İslahiye",
    "Karkamış",
    "Nizip",
    "Nurdağı",
    "Oğuzeli",
    "Şahinbey",
    "Şehitkamil",
    "Yavuzeli",
  ];

  @override
  void initState() {
    super.initState();
    _allDistricts = [...gaziantepDistricts];
    _loadPharmacies();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPharmacies() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response =
          await _pharmacyService.getPharmacies(city: _city, apikey: _apikey);

      if (response.success == true &&
          response.result != null &&
          response.result!.isNotEmpty) {
        _districtPharmacies = {};
        for (var pharmacy in response.result!) {
          String district = pharmacy.dist?.trim() ?? "Diğer";
          if (!_districtPharmacies.containsKey(district)) {
            _districtPharmacies[district] = [];
          }
          _districtPharmacies[district]!.add(pharmacy);
        }
      } else {
        _errorMessage = '$_city için nöbetçi eczane bulunamadı.';
      }
    } catch (e) {
      _errorMessage = 'Eczaneler yüklenirken bir hata oluştu: $e';
      log("Hata Detayı: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  List<String> _filteredDistricts() {
    if (_searchQuery.isEmpty) {
      return _allDistricts..sort();
    }

    return _allDistricts
        .where((district) =>
            district.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList()
      ..sort();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Gaziantep Nöbetçi Eczaneler",
      ),
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: _loadPharmacies,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const LoadingIndicator();
    }

    if (_errorMessage != null) {
      return ErrorView(
        errorMessage: _errorMessage!,
        onRetry: _loadPharmacies,
      );
    }

    return Column(
      children: [
        CustomSearchBar(
          controller: _searchController,
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
        ),
        Expanded(
          child: DistrictList(
            districts: _filteredDistricts(),
            districtPharmacies: _districtPharmacies,
            city: _city,
          ),
        ),
      ],
    );
  }
}
