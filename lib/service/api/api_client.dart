import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import '../base/base_service.dart';

class ApiClient {
  final http.Client _client;
  static const String baseUrl = BaseService.baseUrl;

  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  Map<String, String> get _defaultHeaders => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  Map<String, String> _getBearerAuthHeaders(String token) => {
        ..._defaultHeaders,
        'Authorization': 'Bearer $token',
      };

  Map<String, String> _getCustomAuthHeaders(String authorizationValue) => {
        ..._defaultHeaders,
        'Authorization': authorizationValue,
      };

  Uri _buildUrl(String path) {
    final cleanPath = path.startsWith('/') ? path.substring(1) : path;
    return Uri.parse('$baseUrl/$cleanPath');
  }

  Uri _buildUrlWithQuery(String path, Map<String, dynamic>? queryParameters) {
    var uri = _buildUrl(path);
    if (queryParameters != null && queryParameters.isNotEmpty) {
      final stringQueryParameters =
          queryParameters.map((key, value) => MapEntry(key, value.toString()));
      uri = uri.replace(queryParameters: stringQueryParameters);
    }
    return uri;
  }

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    String? bearerToken,
    String? customAuthorization,
  }) async {
    Map<String, String> headers;
    if (customAuthorization != null) {
      headers = _getCustomAuthHeaders(customAuthorization);
    } else if (bearerToken != null) {
      headers = _getBearerAuthHeaders(bearerToken);
    } else {
      headers = _defaultHeaders;
    }

    final url = _buildUrlWithQuery(path, queryParameters);
    log('GET isteği: $url');
    log('Headers: $headers');

    try {
      final response = await _client.get(
        url,
        headers: headers,
      );
      return _handleResponse(response);
    } catch (e) {
      log('GET isteği sırasında hata ($url): $e');
      if (e is http.ClientException) {
        throw Exception('Ağ hatası: ${e.message}');
      }
      throw Exception('İstek sırasında bilinmeyen bir hata oluştu: $e');
    }
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
    String? bearerToken,
    String? customAuthorization,
  }) async {
    Map<String, String> headers;
    if (customAuthorization != null) {
      headers = _getCustomAuthHeaders(customAuthorization);
    } else if (bearerToken != null) {
      headers = _getBearerAuthHeaders(bearerToken);
    } else {
      headers = _defaultHeaders;
    }

    final url = _buildUrlWithQuery(path, queryParameters);
    log('POST isteği: $url');
    log('Headers: $headers');
    log('Body: ${jsonEncode(body)}');

    try {
      final response = await _client.post(
        url,
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      );
      return _handleResponse(response);
    } catch (e) {
      log('POST isteği sırasında hata ($url): $e');
      if (e is http.ClientException) {
        throw Exception('Ağ hatası: ${e.message}');
      }
      throw Exception('İstek sırasında bilinmeyen bir hata oluştu: $e');
    }
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    log('Yanıt Kodu: ${response.statusCode}');
    log('Yanıt Body: ${response.body}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return {};
      }
      try {
        return json.decode(response.body) as Map<String, dynamic>;
      } catch (e) {
        log('JSON Decode Hatası: $e');
        throw Exception('API yanıtı geçerli JSON formatında değil.');
      }
    } else {
      String errorMessage =
          'API isteği başarısız oldu. Durum Kodu: ${response.statusCode}';
      try {
        final errorData = json.decode(response.body);
        if (errorData is Map<String, dynamic>) {
          errorMessage = errorData['message'] ??
              errorData['error'] ??
              errorData.toString();
        } else {
          errorMessage = errorData.toString();
        }
      } catch (e) {
        if (response.body.isNotEmpty) {
          errorMessage = response.body;
        }
        log('API Hatası (JSON parse edilemedi): ${response.statusCode} - $errorMessage');
      }
      throw ApiException(
          statusCode: response.statusCode,
          message: errorMessage,
          errors: response.body);
    }
  }

  void dispose() {
    _client.close();
  }
}

class ApiException implements Exception {
  final int? statusCode;
  final String message;
  final dynamic errors;
  ApiException({this.statusCode, required this.message, this.errors});

  @override
  String toString() {
    return message;
  }
}
