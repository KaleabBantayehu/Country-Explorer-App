import 'package:flutter/material.dart';

import '../models/country.dart';
import '../services/api_exception.dart';
import '../services/country_api_service.dart';

class DetailScreen extends StatefulWidget {
  final String code;

  const DetailScreen({super.key, required this.code});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final CountryApiService _apiService = CountryApiService();
  late Future<Country> _futureCountry;

  @override
  void initState() {
    super.initState();
    _futureCountry = _apiService.fetchCountryByCode(widget.code);
  }

  void _retryFetch() {
    setState(() {
      _futureCountry = _apiService.fetchCountryByCode(widget.code);
    });
  }

  String _extractErrorMessage(Object error) {
    if (error is ApiException) {
      final String message = error.message;
      if (message.toLowerCase().contains('no internet')) {
        return 'No internet connection. Please check your network and try again.';
      }
      if (message.toLowerCase().contains('timed out')) {
        return 'The request timed out. Please try again later.';
      }
      return message;
    }
    return 'Something went wrong. Please try again.';
  }

  String _formatCurrencies(Map<String, dynamic>? currencies) {
    if (currencies == null || currencies.isEmpty) {
      return 'No currencies available';
    }
    return currencies.entries
        .map((entry) {
          final code = entry.key;
          final details = entry.value as Map<String, dynamic>?;
          final name = details?['name'] as String? ?? 'Unknown';
          final symbol = details?['symbol'] as String? ?? '';
          return '$code: $name${symbol.isNotEmpty ? ' ($symbol)' : ''}';
        })
        .join('\n');
  }

  String _formatLanguages(Map<String, String>? languages) {
    if (languages == null || languages.isEmpty) {
      return 'No languages available';
    }
    return languages.values.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Country Details')),
      body: FutureBuilder<Country>(
        future: _futureCountry,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            final String message = _extractErrorMessage(snapshot.error!);
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16.0),
                    ),
                    const SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: _retryFetch,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          final Country? country = snapshot.data;
          if (country == null) {
            return const Center(
              child: Text(
                'Country not found.',
                style: TextStyle(fontSize: 16.0),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Flag
                Center(
                  child: country.flagUrl.isNotEmpty
                      ? Image.network(
                          country.flagUrl,
                          width: 200.0,
                          height: 150.0,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                                Icons.flag,
                                size: 100.0,
                                color: Colors.grey,
                              ),
                        )
                      : const Icon(Icons.flag, size: 100.0, color: Colors.grey),
                ),
                const SizedBox(height: 24.0),

                // Name
                Text(
                  country.name,
                  style: const TextStyle(
                    fontSize: 28.0,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16.0),

                // Capital
                _buildInfoRow('Capital', country.capital ?? 'N/A'),
                const SizedBox(height: 8.0),

                // Region
                _buildInfoRow('Region', country.region),
                const SizedBox(height: 8.0),

                // Population
                _buildInfoRow('Population', country.population.toString()),
                const SizedBox(height: 8.0),

                // Area
                _buildInfoRow('Area', '${country.area.toStringAsFixed(0)} km²'),
                const SizedBox(height: 16.0),

                // Currencies
                const Text(
                  'Currencies',
                  style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8.0),
                Text(_formatCurrencies(country.currencies)),
                const SizedBox(height: 16.0),

                // Languages
                const Text(
                  'Languages',
                  style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8.0),
                Text(_formatLanguages(country.languages)),
                const SizedBox(height: 16.0),

                // Timezones
                const Text(
                  'Timezones',
                  style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8.0),
                Text(country.timezones.join(', ')),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16.0),
        ),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 16.0))),
      ],
    );
  }
}
