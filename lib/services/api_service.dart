import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

enum ApiEndpoint { wallet, transaction, payment, sms }

class ApiService {
  final Map<ApiEndpoint, String> baseUrls;
  final Map<ApiEndpoint, String> secret;
  final Map<String, String> headers;

  ApiService()
      : baseUrls = {
          ApiEndpoint.wallet: dotenv.get('WALLETS_BASE_URL'),
          ApiEndpoint.transaction: dotenv.get('TRANSACTIONS_BASE_URL'),
          ApiEndpoint.payment: dotenv.get('PAYMENT_BASE_URL'),
          ApiEndpoint.sms: dotenv.get('MOBILE_SASA_BASE_URL'),
        },
        secret = {
          ApiEndpoint.sms: dotenv.get('SMS_SECRET'),
          ApiEndpoint.payment: dotenv.get('SECRET_KEY'),
        },
        headers = {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        };

  String _getBaseUrl(ApiEndpoint endpoint) {
    if (!baseUrls.containsKey(endpoint)) {
      throw Exception('Base URL not found for endpoint: $endpoint');
    }
    return baseUrls[endpoint]!;
  }

  String _getSecret(ApiEndpoint endpoint) {
    if (secret.containsKey(endpoint)) {
      return secret[endpoint]!;
    }

    if (secret.containsKey(ApiEndpoint.payment)) {
      return secret[ApiEndpoint.payment]!;
    }
    if (!secret.containsKey(endpoint)) {
      throw Exception('Secret not found for endpoint: $endpoint');
    }
    return secret[endpoint]!;
  }

  Map<String, String> _getHeaders(ApiEndpoint endpoint) {
    final headersWithAuth = Map<String, String>.from(headers);
    headersWithAuth['Authorization'] = 'Bearer ${_getSecret(endpoint)}';
    return headersWithAuth;
  }

  Future<dynamic> get(String endpoint,
      {ApiEndpoint type = ApiEndpoint.wallet}) async {
    final Uri url = Uri.parse('${_getBaseUrl(type)}$endpoint');
    try {
      final response = await http.get(url, headers: _getHeaders(type));
      return _handleResponse(response);
    } catch (error) {
      throw Exception('Failed to load data: $error');
    }
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> data,
      {ApiEndpoint type = ApiEndpoint.wallet}) async {
    final Uri url = Uri.parse('${_getBaseUrl(type)}$endpoint');
    try {
      final response = await http.post(
        url,
        headers: _getHeaders(type),
        body: json.encode(data),
      );
      return _handleResponse(response);
    } catch (error) {
      throw Exception('Failed to post data: $error');
    }
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json.decode(response.body);
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized request');
    } else if (response.statusCode == 404) {
      throw Exception('Resource not found');
    } else {
      throw Exception('Failed to load data: ${response.statusCode}');
    }
  }
}
