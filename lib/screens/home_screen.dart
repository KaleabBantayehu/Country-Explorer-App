import 'package:flutter/material.dart';

import '../models/country.dart';
import '../screens/detail_screen.dart';
import '../screens/search_screen.dart';
import '../services/api_exception.dart';
import '../services/country_api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CountryApiService _apiService = CountryApiService();
  late Future<List<Country>> _futureCountries;
  List<Country>? _allCountries;
  int _visibleCount = 20;
  bool _isUsingCache = false;

  @override
  void initState() {
    super.initState();
    _futureCountries = _apiService.fetchAllCountries();
  }

  void _retryFetch() {
    setState(() {
      _allCountries = null;
      _visibleCount = 20;
      _isUsingCache = false;
      _futureCountries = _apiService.fetchAllCountries();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Country Explorer${_isUsingCache ? ' (Cached)' : ''}'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchScreen()),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Country>>(
        future: _futureCountries,
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

          final List<Country>? countries = snapshot.data;
          if (countries == null || countries.isEmpty) {
            return const Center(
              child: Text(
                'No countries found.',
                style: TextStyle(fontSize: 16.0),
              ),
            );
          }

          _allCountries ??= countries;
          _isUsingCache = _apiService.lastCallUsedCache;

          return ListView.builder(
            padding: const EdgeInsets.symmetric(
              vertical: 8.0,
              horizontal: 12.0,
            ),
            itemCount: _visibleCount < _allCountries!.length
                ? _visibleCount + 1
                : _visibleCount,
            itemBuilder: (context, index) {
              if (index == _visibleCount &&
                  _visibleCount < _allCountries!.length) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _visibleCount = (_visibleCount + 20).clamp(
                            0,
                            _allCountries!.length,
                          );
                        });
                      },
                      child: const Text('Load More'),
                    ),
                  ),
                );
              }

              final Country country = _allCountries![index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6.0),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12.0),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            DetailScreen(code: country.alpha3Code),
                      ),
                    );
                  },
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: country.flagUrl.isNotEmpty
                        ? Image.network(
                            country.flagUrl,
                            width: 64.0,
                            height: 48.0,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(
                                  Icons.flag,
                                  size: 40.0,
                                  color: Colors.grey,
                                ),
                          )
                        : const Icon(
                            Icons.flag,
                            size: 40.0,
                            color: Colors.grey,
                          ),
                  ),
                  title: Text(
                    country.name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    country.region.isNotEmpty
                        ? country.region
                        : 'Unknown region',
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
