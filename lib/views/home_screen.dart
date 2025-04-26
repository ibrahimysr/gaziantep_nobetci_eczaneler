
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
        title: Text('$districtName Nöbetçi Eczaneler'),
        centerTitle: true,
        backgroundColor: Colors.red,
        elevation: 0,
      ),
      body: pharmacies.isEmpty
          ? const Center(child: Text('Bu ilçede nöbetçi eczane bulunamadı.'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: pharmacies.length,
              itemBuilder: (context, index) {
                final pharmacy = pharmacies[index];
                return PharmacyCard(pharmacy: pharmacy);
              },
            ),
    );
  }
}

class PharmacyCard extends StatelessWidget {
  final Result pharmacy;

  const PharmacyCard({super.key, required this.pharmacy});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.local_pharmacy,
                      color: Colors.red,
                      size: 30,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    pharmacy.name ?? 'İsim Yok',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow(Icons.location_on, 'Adres:', pharmacy.address ?? 'Belirtilmemiş'),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.phone, 'Telefon:', pharmacy.phone ?? 'Belirtilmemiş'),
            if (pharmacy.loc != null && pharmacy.loc!.isNotEmpty)
              Column(
                children: [
                  const SizedBox(height: 8),
                  _buildInfoRow(Icons.map, 'Konum:', pharmacy.loc!),
                ],
              ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    // Harita özelliği
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Harita özelliği yakında eklenecek'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  },
                  icon: const Icon(Icons.map_outlined),
                  label: const Text('Haritada Göster'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Arama özelliği yakında eklenecek'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  },
                  icon: const Icon(Icons.phone),
                  label: const Text('Ara'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(color: Colors.black, fontSize: 14),
              children: [
                TextSpan(
                  text: label + ' ',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: value),
              ],
            ),
          ),
        ),
      ],
    );
  }
}