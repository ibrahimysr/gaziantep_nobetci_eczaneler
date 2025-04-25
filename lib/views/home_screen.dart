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
  late Future<PharmacyResponse> _pharmacyFuture;

  final String _city = "gaziantep";
  final String _apikey = AppSecrets.collectApiKey;
  @override
  void initState() {
    super.initState();
    _loadPharmacies();
  }

  void _loadPharmacies() {
    _pharmacyFuture = _pharmacyService.getDietPlan(city: _city, apikey: _apikey);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$_city Nöbetçi Eczaneler'),
        centerTitle: true,
        backgroundColor: Colors.redAccent,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _loadPharmacies();
          });
        },
        child: FutureBuilder<PharmacyResponse>(
          future: _pharmacyFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            // 2. Hata Durumu
            else if (snapshot.hasError) {
              print("Hata Detayı: ${snapshot.error}");
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Eczaneler yüklenirken bir hata oluştu.\nLütfen internet bağlantınızı kontrol edin veya daha sonra tekrar deneyin.\nHata: ${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              );
            }
            else if (snapshot.hasData) {
              final pharmacyResponse = snapshot.data!;
              if (pharmacyResponse.success != true ||
                  pharmacyResponse.result == null ||
                  pharmacyResponse.result!.isEmpty) {
                return  Center(
                  child: Text('$_city için nöbetçi eczane bulunamadı.'),
                );
              }
              final pharmacies = pharmacyResponse.result!;
              return ListView.builder(
                itemCount: pharmacies.length,
                itemBuilder: (context, index) {
                  final pharmacy = pharmacies[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    elevation: 3,
                    child: ListTile(
                      leading: const Icon(Icons.local_pharmacy, color: Colors.redAccent),
                      title: Text(
                        pharmacy.name ?? 'İsim Yok',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('İlçe: ${pharmacy.dist ?? 'Belirtilmemiş'}'),
                          Text('Adres: ${pharmacy.address ?? 'Adres Yok'}'),
                          Text('Telefon: ${pharmacy.phone ?? 'Telefon Yok'}'),
                          Text('Konum: ${pharmacy.loc ?? 'Konum Yok'}'),
                        ],
                      ),
                      isThreeLine: true, 
                      onTap: () {
                        print('${pharmacy.name} tıklandı');
                      },
                    ),
                  );
                },
              );
            }
            else {
              return const Center(child: Text('Nöbetçi eczane bilgisi alınamadı.'));
            }
          },
        ),
      ),
    );
  }
}