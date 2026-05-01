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
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Country Details')),
      body: FutureBuilder<Country>(
        future: _futureCountry,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: colorScheme.primary),
            );
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
                      style: TextStyle(
                        fontSize: 16.0,
                        color: colorScheme.onSurface,
                      ),
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
            return Center(
              child: Text(
                'Country not found.',
                style: TextStyle(fontSize: 16.0, color: colorScheme.onSurface),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20.0),
                    child: country.flagUrl.isNotEmpty
                        ? Image.network(
                            country.flagUrl,
                            width: 240.0,
                            height: 150.0,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  width: 240.0,
                                  height: 150.0,
                                  color: colorScheme.surfaceContainerHighest,
                                  alignment: Alignment.center,
                                  child: const Icon(
                                    Icons.flag,
                                    size: 80.0,
                                    color: Colors.grey,
                                  ),
                                ),
                          )
                        : Container(
                            width: 240.0,
                            height: 150.0,
                            color: colorScheme.surfaceContainerHighest,
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.flag,
                              size: 80.0,
                              color: Colors.grey,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 20.0),
                Center(
                  child: Text(
                    country.name,
                    style: TextStyle(
                      fontSize: 28.0,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 24.0),
                _buildSectionHeader('Overview'),
                _buildInfoCard(
                  children: [
                    _buildInfoRow('Capital', country.capital ?? 'N/A'),
                    _buildInfoRow(
                      'Region',
                      country.region.isNotEmpty ? country.region : 'N/A',
                    ),
                    _buildInfoRow('Population', country.population.toString()),
                    _buildInfoRow(
                      'Area',
                      '${country.area.toStringAsFixed(0)} km²',
                    ),
                  ],
                ),
                const SizedBox(height: 20.0),
                _buildSectionHeader('Currencies'),
                _buildInfoCard(
                  children: [
                    Text(
                      _formatCurrencies(country.currencies),
                      style: const TextStyle(fontSize: 16.0, height: 1.5),
                    ),
                  ],
                ),
                const SizedBox(height: 20.0),
                _buildSectionHeader('Languages'),
                _buildInfoCard(
                  children: [
                    Text(
                      _formatLanguages(country.languages),
                      style: const TextStyle(fontSize: 16.0, height: 1.5),
                    ),
                  ],
                ),
                const SizedBox(height: 20.0),
                _buildSectionHeader('Timezones'),
                _buildInfoCard(
                  children: [
                    Text(
                      country.timezones.join(', '),
                      style: const TextStyle(fontSize: 16.0, height: 1.5),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20.0,
          fontWeight: FontWeight.w700,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildInfoCard({required List<Widget> children}) {
    return Card(
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16.0,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16.0,
                height: 1.5,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
