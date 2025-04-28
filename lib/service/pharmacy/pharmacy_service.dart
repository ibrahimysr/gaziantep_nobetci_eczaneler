import 'dart:developer';

import 'package:gaziantep_nobetci_eczane/model/pharmacy_model.dart';
import 'package:gaziantep_nobetci_eczane/service/api/api_client.dart';

class PharmacyService {
  final ApiClient _apiClient;

  PharmacyService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Future<PharmacyResponse> getPharmacies({required String city,required apikey}) async {
    try {

      final response = await _apiClient.get(
        'health/dutyPharmacy', 
        queryParameters: {'il': city}, 
        customAuthorization: apikey, 
      );
      return PharmacyResponse.fromJson(response);
    } catch (e) {
      log("PharmacyService Hatası: $e"); 
      
      rethrow;
    }
  }
}