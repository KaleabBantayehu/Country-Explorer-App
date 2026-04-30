import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/country.dart';
import 'api_exception.dart';

class CountryApiService {
  final String _baseUrl = 'restcountries.com';
  final Duration _timeout = const Duration(seconds: 10);
  final Map<String, String> _headers = {'Accept': 'application/json'};

  Future<List<Country>> fetchAllCountries() async {
    final uri = Uri.https(_baseUrl, '/v3.1/all', {
      'fields': 'name,flags,region,population',
    });

    try {
      final response = await http.get(uri, headers: _headers).timeout(_timeout);
      _checkResponse(response);

      final List<dynamic> decoded = jsonDecode(response.body) as List<dynamic>;
      return decoded
          .map((item) => Country.fromJson(item as Map<String, dynamic>))
          .toList();
    } on SocketException catch (error) {
      throw ApiException('No internet connection: ${error.message}');
    } on TimeoutException catch (error) {
      throw ApiException('Request timed out: ${error.message}');
    } on FormatException catch (error) {
      throw ApiException('Invalid response format: ${error.message}');
    } on ApiException {
      rethrow;
    } catch (error) {
      throw ApiException('Unknown error: $error');
    }
  }

  Future<List<Country>> searchCountries(String name) async {
    final uri = Uri.https(_baseUrl, '/v3.1/name/$name');

    try {
      final response = await http.get(uri, headers: _headers).timeout(_timeout);
      _checkResponse(response);

      final List<dynamic> decoded = jsonDecode(response.body) as List<dynamic>;
      return decoded
          .map((item) => Country.fromJson(item as Map<String, dynamic>))
          .toList();
    } on SocketException catch (error) {
      throw ApiException('No internet connection: ${error.message}');
    } on TimeoutException catch (error) {
      throw ApiException('Request timed out: ${error.message}');
    } on FormatException catch (error) {
      throw ApiException('Invalid response format: ${error.message}');
    } on ApiException {
      rethrow;
    } catch (error) {
      throw ApiException('Unknown error: $error');
    }
  }

  Future<Country> fetchCountryByCode(String code) async {
    final uri = Uri.https(_baseUrl, '/v3.1/alpha/$code');

    try {
      final response = await http.get(uri, headers: _headers).timeout(_timeout);
      _checkResponse(response);

      final List<dynamic> decoded = jsonDecode(response.body) as List<dynamic>;
      if (decoded.isEmpty) {
        throw ApiException('Country not found for code: $code', 404);
      }
      return Country.fromJson(decoded.first as Map<String, dynamic>);
    } on SocketException catch (error) {
      throw ApiException('No internet connection: ${error.message}');
    } on TimeoutException catch (error) {
      throw ApiException('Request timed out: ${error.message}');
    } on FormatException catch (error) {
      throw ApiException('Invalid response format: ${error.message}');
    } on ApiException {
      rethrow;
    } catch (error) {
      throw ApiException('Unknown error: $error');
    }
  }

  void _checkResponse(http.Response response) {
    if (response.statusCode != 200) {
      throw ApiException(
        'Request failed with status: ${response.statusCode}',
        response.statusCode,
      );
    }
  }
}
