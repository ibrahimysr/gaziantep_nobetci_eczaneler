
import 'package:flutter/material.dart';
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
  TextEditingController _searchController = TextEditingController();
  
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
      final response = await _pharmacyService.getDietPlan(city: _city, apikey: _apikey);
      
      if (response.success == true && response.result != null && response.result!.isNotEmpty) {
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
      print("Hata Detayı: $e");
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
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '$_city ilçesine göre',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF6F6F6),
      body: RefreshIndicator(
        onRefresh: _loadPharmacies,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.red),
      );
    }
    
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadPharmacies,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text('Tekrar Dene'),
              ),
            ],
          ),
        ),
      );
    }
    
    return Column(
      children: [
        // Arama alanı
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'İlçe Ara',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 16),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
        ),
        
        // İlçe listesi
        Expanded(
          child: _buildDistrictList(),
        ),
      ],
    );
  }

  Widget _buildDistrictList() {
    final filteredDistricts = _filteredDistricts();
    
    Map<String, List<String>> alphabetGroups = {};
    
    for (var district in filteredDistricts) {
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
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ),
            ...districts.map((district) => _buildDistrictItem(district)),
          ],
        );
      },
    );
  }

  Widget _buildDistrictItem(String district) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
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
        trailing: const Icon(Icons.chevron_right),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        onTap: () {
          if (_districtPharmacies.containsKey(district) && 
              _districtPharmacies[district]!.isNotEmpty) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DistrictPharmaciesPage(
                  districtName: district,
                  pharmacies: _districtPharmacies[district]!,
                  cityName: _city,
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

class DistrictPharmaciesPage extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          districtName,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF6F6F6),
      body: _buildSegmentedControl(context),
    );
  }

  Widget _buildSegmentedControl(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.list, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'Liste',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.map, color: Colors.grey),
                      SizedBox(width: 8),
                      Text(
                        'Harita',
                        style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: pharmacies.isEmpty
              ? const Center(child: Text('Bu ilçede nöbetçi eczane bulunamadı.'))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  itemCount: pharmacies.length,
                  itemBuilder: (context, index) {
                    final pharmacy = pharmacies[index];
                    return _buildPharmacyItem(context, pharmacy);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildPharmacyItem(BuildContext context, Result pharmacy) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Text(
              pharmacy.name?.toUpperCase() ?? 'İSİM YOK',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            child: Row(
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
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            child: Row(
              children: [
                const Icon(
                  Icons.access_time,
                  size: 22,
                  color: Colors.grey,
                ),
                const SizedBox(width: 10),
                Text(
                  '26/04/2025 19:00-09:00',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Arama özelliği yakında eklenecek'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: const BoxDecoration(
                      color: Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(15),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.phone,
                          color: Colors.green,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Ara',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Yön tarifi özelliği yakında eklenecek'),
                        backgroundColor: Colors.blue,
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: const BoxDecoration(
                      color: Color(0xFFE3F2FD),
                      borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(15),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chevron_right,
                          color: Colors.blue,
                          size: 22,
                        ),
                      ],
                    ),
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