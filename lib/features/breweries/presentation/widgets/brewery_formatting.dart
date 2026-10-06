import '../../domain/entities/brewery.dart';

extension BreweryTypeLabel on BreweryType {
  String get label => switch (this) {
    BreweryType.micro => 'Micro',
    BreweryType.nano => 'Nano',
    BreweryType.regional => 'Regional',
    BreweryType.brewpub => 'Brewpub',
    BreweryType.large => 'Large',
    BreweryType.planning => 'Planning',
    BreweryType.bar => 'Bar',
    BreweryType.contract => 'Contract',
    BreweryType.proprietor => 'Proprietor',
    BreweryType.taproom => 'Taproom',
    BreweryType.beergarden => 'Beer garden',
    BreweryType.cidery => 'Cidery',
    BreweryType.closed => 'Closed',
    BreweryType.unknown => 'Unknown type',
  };
}

extension BreweryFormatting on Brewery {
  /// "City, State" or whichever part exists.
  String? get location {
    final parts = [city, stateProvince].whereType<String>();
    return parts.isEmpty ? null : parts.join(', ');
  }

  /// Multi-line postal address, or null if the API has none.
  String? get fullAddress {
    final cityLine = [
      city,
      [stateProvince, postalCode].whereType<String>().join(' '),
    ].whereType<String>().where((part) => part.isNotEmpty).join(', ');
    final lines = [
      street,
      cityLine,
      country,
    ].whereType<String>().where((line) => line.isNotEmpty);
    return lines.isEmpty ? null : lines.join('\n');
  }
}
