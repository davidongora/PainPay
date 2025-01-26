import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  // API base URL (stored in .env for flexibility)
  final String baseUrl = dotenv.env['BASE_URL'] ?? 'https://api.example.com';

  // Default headers for all requests
  Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Constructor to load dotenv environment variables
  ApiService() {
    dotenv.load();
  }

  // Handle GET requests
  Future<dynamic> get(String endpoint) async {
    final Uri url = Uri.parse('$baseUrl$endpoint');
    try {
      final response = await http.get(url, headers: headers);
      return _handleResponse(response);
    } catch (error) {
      throw Exception('Failed to load data: $error');
    }
  }

  // Handle POST requests
  Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    final Uri url = Uri.parse('$baseUrl$endpoint');
    try {
      final response = await http.post(
        url,
        headers: headers,
        body: json.encode(data),
      );
      return _handleResponse(response);
    } catch (error) {
      throw Exception('Failed to post data: $error');
    }
  }

  // Handle PUT requests
  Future<dynamic> put(String endpoint, Map<String, dynamic> data) async {
    final Uri url = Uri.parse('$baseUrl$endpoint');
    try {
      final response = await http.put(
        url,
        headers: headers,
        body: json.encode(data),
      );
      return _handleResponse(response);
    } catch (error) {
      throw Exception('Failed to update data: $error');
    }
  }

  // Handle DELETE requests
  Future<dynamic> delete(String endpoint) async {
    final Uri url = Uri.parse('$baseUrl$endpoint');
    try {
      final response = await http.delete(url, headers: headers);
      return _handleResponse(response);
    } catch (error) {
      throw Exception('Failed to delete data: $error');
    }
  }

  // Handle the response from the API
  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      // Successfully received response
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
