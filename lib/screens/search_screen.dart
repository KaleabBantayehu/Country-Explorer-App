import 'dart:async';

import 'package:flutter/material.dart';

import '../models/country.dart';
import '../screens/detail_screen.dart';
import '../services/api_exception.dart';
import '../services/country_api_service.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final CountryApiService _apiService = CountryApiService();
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;
  bool _isLoading = false;
  String? _errorMessage;
  List<Country>? _countries;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    final String query = value.trim();

    if (query.isEmpty) {
      setState(() {
        _isLoading = false;
        _errorMessage = null;
        _countries = null;
      });
      return;
    }

    setState(() => _isLoading = true);
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      _performSearch(query);
    });
  }

  Future<void> _performSearch(String query) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _countries = null;
    });

    try {
      final results = await _apiService.searchCountries(query);
      setState(() {
        _countries = results;
      });
    } catch (error) {
      setState(() {
        _errorMessage = _extractErrorMessage(error);
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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

  void _retrySearch() {
    final String query = _controller.text.trim();
    if (query.isEmpty) {
      return;
    }
    _performSearch(query);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search Countries')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Search countries',
                hintText: 'Enter country name',
                border: OutlineInputBorder(),
              ),
              onChanged: _onSearchChanged,
            ),
            const SizedBox(height: 16.0),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_controller.text.trim().isEmpty) {
      return const Center(
        child: Text(
          'Start typing to search countries',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16.0),
        ),
      );
    }

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16.0),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _retrySearch,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_countries == null) {
      return const SizedBox.shrink();
    }

    if (_countries!.isEmpty) {
      return const Center(
        child: Text(
          'No results found.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16.0),
        ),
      );
    }

    return ListView.builder(
      itemCount: _countries!.length,
      itemBuilder: (context, index) {
        final Country country = _countries![index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12.0),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12.0),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailScreen(code: country.alpha3Code),
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
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.flag,
                        size: 40.0,
                        color: Colors.grey,
                      ),
                    )
                  : const Icon(Icons.flag, size: 40.0, color: Colors.grey),
            ),
            title: Text(
              country.name,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              country.region.isNotEmpty ? country.region : 'Unknown region',
            ),
          ),
        );
      },
    );
  }
}
