import 'package:http/http.dart' as http;

abstract class BaseService {
  static const String baseUrl ='https://api.collectapi.com/';
  
  http.Client get httpClient;
  
  Uri buildUrl(String path) {
    return Uri.parse('$baseUrl/$path');
  }
  
  Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  Map<String, String> getAuthHeaders(String token) => {
    ...headers,
    'Authorization': 'Bearer $token',
  };
} 