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
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Search Countries')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              style: TextStyle(color: colorScheme.onSurface),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                labelText: 'Search countries',
                hintText: 'Enter country name',
                hintStyle: const TextStyle(color: Colors.white54),
                labelStyle: const TextStyle(color: Colors.white70),
                prefixIconColor: Colors.white70,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: colorScheme.surface,
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
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    if (_controller.text.trim().isEmpty) {
      return Center(
        child: Text(
          'Enter a country name to begin searching.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16.0, color: colorScheme.onSurface),
        ),
      );
    }

    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(color: colorScheme.primary),
      );
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
                style: TextStyle(fontSize: 16.0, color: colorScheme.onSurface),
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
      return Center(
        child: Text(
          'No countries match your search term.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16.0, color: colorScheme.onSurface),
        ),
      );
    }

    return ListView.builder(
      itemCount: _countries!.length,
      itemBuilder: (context, index) {
        final Country country = _countries![index];
        return Card(
          color: colorScheme.surface,
          margin: const EdgeInsets.only(bottom: 12.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.0),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(14.0),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailScreen(code: country.alpha3Code),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12.0),
                    child: country.flagUrl.isNotEmpty
                        ? Image.network(
                            country.flagUrl,
                            width: 72.0,
                            height: 48.0,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  width: 72.0,
                                  height: 48.0,
                                  color: colorScheme.surfaceContainerHighest,
                                  alignment: Alignment.center,
                                  child: const Icon(
                                    Icons.flag,
                                    size: 28.0,
                                    color: Colors.grey,
                                  ),
                                ),
                          )
                        : Container(
                            width: 72.0,
                            height: 48.0,
                            color: colorScheme.surfaceContainerHighest,
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.flag,
                              size: 28.0,
                              color: Colors.grey,
                            ),
                          ),
                  ),
                  const SizedBox(width: 14.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          country.name,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16.0,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 6.0),
                        Text(
                          country.region.isNotEmpty
                              ? country.region
                              : 'Unknown region',
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 14.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
