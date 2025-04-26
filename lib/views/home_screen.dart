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
  
  // Eczanelerin ilçelere göre gruplandığı harita
  Map<String, List<Result>> _districtPharmacies = {};
  bool _isLoading = true;
  String? _errorMessage;
  
  @override
  void initState() {
    super.initState();
    _loadPharmacies();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$_city Nöbetçi Eczaneler'),
        centerTitle: true,
        backgroundColor: Colors.redAccent,
        elevation: 2,
      ),
      body: RefreshIndicator(
        onRefresh: _loadPharmacies,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Colors.redAccent),
            SizedBox(height: 16),
            Text('Nöbetçi eczaneler yükleniyor...'),
          ],
        ),
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
                  backgroundColor: Colors.redAccent,
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
    
    if (_districtPharmacies.isEmpty) {
      return const Center(
        child: Text('Gösterilecek ilçe bulunamadı.'),
      );
    }
    
    final districtNames = _districtPharmacies.keys.toList()..sort();
    
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: districtNames.length,
      itemBuilder: (context, index) {
        final districtName = districtNames[index];
        final pharmacyCount = _districtPharmacies[districtName]!.length;
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DistrictPharmaciesPage(
                    districtName: districtName,
                    pharmacies: _districtPharmacies[districtName]!,
                    cityName: _city,
                  ),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.location_city,
                        color: Colors.redAccent,
                        size: 32,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          districtName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$pharmacyCount nöbetçi eczane',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.grey,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        );
      },
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
        backgroundColor: Colors.redAccent,
        elevation: 2,
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
                    color: Colors.redAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.local_pharmacy,
                      color: Colors.redAccent,
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
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Harita özelliği yakında eklenecek'),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                  },
                  icon: const Icon(Icons.map_outlined),
                  label: const Text('Haritada Göster'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Arama özelliği yakında eklenecek'),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                  },
                  icon: const Icon(Icons.phone),
                  label: const Text('Ara'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
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