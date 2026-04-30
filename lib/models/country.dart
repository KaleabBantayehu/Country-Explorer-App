class Country {
  final String name;
  final String flagUrl;
  final String region;
  final String? capital;
  final int population;
  final Map<String, dynamic>? currencies;
  final Map<String, String>? languages;
  final double area;
  final List<String> timezones;
  final String alpha3Code;

  Country({
    required this.name,
    required this.flagUrl,
    required this.region,
    this.capital,
    required this.population,
    this.currencies,
    this.languages,
    required this.area,
    required this.timezones,
    required this.alpha3Code,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? nameObject =
        json['name'] as Map<String, dynamic>?;
    final String name = nameObject?['common'] as String? ?? '';

    final Map<String, dynamic>? flagsObject =
        json['flags'] as Map<String, dynamic>?;
    final String flagUrl =
        flagsObject?['png'] as String? ?? flagsObject?['svg'] as String? ?? '';

    final String region = json['region'] as String? ?? '';

    final List<String> timezones =
        (json['timezones'] as List<dynamic>?)
            ?.map((value) => value as String)
            .toList() ??
        <String>[];

    final List<dynamic>? capitalList = json['capital'] as List<dynamic>?;
    final String? capital = capitalList != null && capitalList.isNotEmpty
        ? capitalList.first as String?
        : null;

    final int population = (json['population'] as num?)?.toInt() ?? 0;
    final double area = (json['area'] as num?)?.toDouble() ?? 0.0;

    final Map<String, dynamic>? currencies =
        json['currencies'] as Map<String, dynamic>?;
    final Map<String, String>? languages =
        (json['languages'] as Map<String, dynamic>?)?.map(
          (key, value) => MapEntry(key, value as String),
        );

    final String alpha3Code =
        (json['cca3'] as String?) ?? (json['alpha3Code'] as String?) ?? '';

    return Country(
      name: name,
      flagUrl: flagUrl,
      region: region,
      capital: capital,
      population: population,
      currencies: currencies,
      languages: languages,
      area: area,
      timezones: timezones,
      alpha3Code: alpha3Code,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': {'common': name},
      'flags': {'png': flagUrl},
      'region': region,
      'capital': capital == null ? null : <String>[capital!],
      'population': population,
      'currencies': currencies,
      'languages': languages,
      'area': area,
      'timezones': timezones,
      'cca3': alpha3Code,
    };
  }

  Country copyWith({
    String? name,
    String? flagUrl,
    String? region,
    String? capital,
    int? population,
    Map<String, dynamic>? currencies,
    Map<String, String>? languages,
    double? area,
    List<String>? timezones,
    String? alpha3Code,
  }) {
    return Country(
      name: name ?? this.name,
      flagUrl: flagUrl ?? this.flagUrl,
      region: region ?? this.region,
      capital: capital ?? this.capital,
      population: population ?? this.population,
      currencies: currencies ?? this.currencies,
      languages: languages ?? this.languages,
      area: area ?? this.area,
      timezones: timezones ?? this.timezones,
      alpha3Code: alpha3Code ?? this.alpha3Code,
    );
  }
}
