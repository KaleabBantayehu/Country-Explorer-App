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
  final Duration _cacheTtl = const Duration(minutes: 5);

  List<Country>? _cachedCountries;
  DateTime? _cacheTime;
  bool _lastCallUsedCache = false;

  bool get lastCallUsedCache => _lastCallUsedCache;

  Future<List<Country>> fetchAllCountries() async {
    if (_isCacheValid()) {
      _lastCallUsedCache = true;
      // Optionally refresh in background
      unawaited(_refreshCache());
      return _cachedCountries!;
    } else {
      _lastCallUsedCache = false;
      return await _fetchAndCache();
    }
  }

  bool _isCacheValid() {
    return _cachedCountries != null &&
        _cacheTime != null &&
        DateTime.now().difference(_cacheTime!) < _cacheTtl;
  }

  Future<void> _refreshCache() async {
    try {
      final countries = await _fetchWithRetry(
        Uri.https(_baseUrl, '/v3.1/all', {
          'fields': 'name,flags,region,population,cca3',
        }),
      );
      _cachedCountries = countries;
      _cacheTime = DateTime.now();
    } catch (_) {
      // Ignore errors in background refresh
    }
  }

  Future<List<Country>> _fetchAndCache() async {
    final countries = await _fetchWithRetry(
      Uri.https(_baseUrl, '/v3.1/all', {
        'fields': 'name,flags,region,population,cca3',
      }),
    );
    _cachedCountries = countries;
    _cacheTime = DateTime.now();
    return countries;
  }

  Future<List<Country>> _fetchWithRetry(Uri uri) async {
    int attempts = 0;
    const maxAttempts = 2;

    while (attempts < maxAttempts) {
      attempts++;
      try {
        final response = await http
            .get(uri, headers: _headers)
            .timeout(_timeout);
        _checkResponse(response);

        final dynamic decodedData = jsonDecode(response.body);
        if (decodedData is! List) {
          throw ApiException('Unexpected response format: expected list');
        }

        final List<dynamic> decoded = decodedData;
        return decoded
            .map((item) => Country.fromJson(item as Map<String, dynamic>))
            .toList();
      } on TimeoutException catch (error) {
        if (attempts >= maxAttempts) {
          throw ApiException(
            'Request timed out after $maxAttempts attempts: ${error.message}',
          );
        }
        // Wait a bit before retrying
        await Future.delayed(const Duration(seconds: 1));
        continue;
      } on SocketException catch (error) {
        throw ApiException('No internet connection: ${error.message}');
      } on FormatException catch (error) {
        throw ApiException('Invalid response format: ${error.message}');
      } on ApiException {
        rethrow;
      } catch (error) {
        throw ApiException('Unknown error: $error');
      }
    }
    throw ApiException('Request failed after $maxAttempts attempts');
  }

  Future<List<Country>> searchCountries(String name) async {
    final uri = Uri.https(_baseUrl, '/v3.1/name/$name');

    return _fetchWithRetry(uri);
  }

  Future<Country> fetchCountryByCode(String code) async {
    if (code.isEmpty || code.length != 3) {
      throw ApiException(
        'Invalid country code: $code. Must be a 3-letter code.',
      );
    }

    final uri = Uri.https(_baseUrl, '/v3.1/alpha/$code');

    return _fetchSingleWithRetry(uri);
  }

  Future<Country> _fetchSingleWithRetry(Uri uri) async {
    int attempts = 0;
    const maxAttempts = 2;

    while (attempts < maxAttempts) {
      attempts++;
      try {
        final response = await http
            .get(uri, headers: _headers)
            .timeout(_timeout);
        _checkResponse(response);

        final dynamic decodedData = jsonDecode(response.body);
        if (decodedData is! List || decodedData.isEmpty) {
          throw ApiException(
            'Country not found for code: ${uri.pathSegments.last}',
            404,
          );
        }

        final List<dynamic> decoded = decodedData;
        return Country.fromJson(decoded.first as Map<String, dynamic>);
      } on TimeoutException catch (error) {
        if (attempts >= maxAttempts) {
          throw ApiException(
            'Request timed out after $maxAttempts attempts: ${error.message}',
          );
        }
        await Future.delayed(const Duration(seconds: 1));
        continue;
      } on SocketException catch (error) {
        throw ApiException('No internet connection: ${error.message}');
      } on FormatException catch (error) {
        throw ApiException('Invalid response format: ${error.message}');
      } on ApiException {
        rethrow;
      } catch (error) {
        throw ApiException('Unknown error: $error');
      }
    }
    throw ApiException('Request failed after $maxAttempts attempts');
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
