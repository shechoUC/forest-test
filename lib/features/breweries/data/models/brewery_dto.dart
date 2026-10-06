import '../../domain/entities/brewery.dart';

/// Mirrors the Open Brewery DB JSON. Field-level type checks turn a malformed
/// payload into a [FormatException] instead of an untyped `TypeError`.
class BreweryDto {
  const BreweryDto({
    required this.id,
    required this.name,
    this.breweryType,
    this.street,
    this.city,
    this.stateProvince,
    this.postalCode,
    this.country,
    this.phone,
    this.websiteUrl,
    this.latitude,
    this.longitude,
  });

  factory BreweryDto.fromJson(Map<String, dynamic> json) {
    final id = _read<String>(json, 'id');
    final name = _read<String>(json, 'name');
    if (id == null || name == null) {
      throw const FormatException('Brewery without id or name');
    }
    return BreweryDto(
      id: id,
      name: name,
      breweryType: _read<String>(json, 'brewery_type'),
      street: _read<String>(json, 'street') ?? _read<String>(json, 'address_1'),
      city: _read<String>(json, 'city'),
      stateProvince:
          _read<String>(json, 'state_province') ?? _read<String>(json, 'state'),
      postalCode: _read<String>(json, 'postal_code'),
      country: _read<String>(json, 'country'),
      phone: _read<String>(json, 'phone'),
      websiteUrl: _read<String>(json, 'website_url'),
      latitude: _readCoordinate(json, 'latitude'),
      longitude: _readCoordinate(json, 'longitude'),
    );
  }

  final String id;
  final String name;
  final String? breweryType;
  final String? street;
  final String? city;
  final String? stateProvince;
  final String? postalCode;
  final String? country;
  final String? phone;
  final String? websiteUrl;
  final double? latitude;
  final double? longitude;

  Brewery toEntity() => Brewery(
    id: id,
    name: name,
    type: _parseType(breweryType),
    street: _blankToNull(street),
    city: _blankToNull(city),
    stateProvince: _blankToNull(stateProvince),
    postalCode: _blankToNull(postalCode),
    country: _blankToNull(country),
    phone: _blankToNull(phone),
    websiteUrl: _blankToNull(websiteUrl),
    latitude: latitude,
    longitude: longitude,
  );

  static BreweryType _parseType(String? raw) => BreweryType.values.firstWhere(
    (type) => type.name == raw?.toLowerCase(),
    orElse: () => BreweryType.unknown,
  );

  static String? _blankToNull(String? value) =>
      (value == null || value.trim().isEmpty) ? null : value.trim();

  static T? _read<T>(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value == null || value is T) return value as T?;
    throw FormatException(
      'Field "$key": expected $T, got ${value.runtimeType}',
    );
  }

  /// The API has historically sent coordinates both as numbers and strings.
  static double? _readCoordinate(Map<String, dynamic> json, String key) {
    final value = json[key];
    return switch (value) {
      null => null,
      num() => value.toDouble(),
      String() => double.tryParse(value),
      _ => throw FormatException(
        'Field "$key": expected a coordinate, got ${value.runtimeType}',
      ),
    };
  }
}
