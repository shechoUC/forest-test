import 'package:flutter_test/flutter_test.dart';
import 'package:forest_test/features/breweries/data/models/brewery_dto.dart';
import 'package:forest_test/features/breweries/domain/entities/brewery.dart';

import '../../../helpers/fixtures.dart';

void main() {
  test('parses a full payload into an entity', () {
    final brewery = BreweryDto.fromJson(breweryJson()).toEntity();

    expect(brewery.id, 'abc');
    expect(brewery.type, BreweryType.brewpub);
    expect(brewery.street, '260 4th St');
    expect(brewery.phone, '3603777788');
    expect(brewery.latitude, 47.565);
  });

  test('accepts coordinates sent as strings', () {
    final dto = BreweryDto.fromJson(breweryJson(latitude: '47.5'));

    expect(dto.latitude, 47.5);
  });

  test('falls back to unknown for unrecognised brewery types', () {
    final json = breweryJson()..['brewery_type'] = 'speakeasy';

    expect(BreweryDto.fromJson(json).toEntity().type, BreweryType.unknown);
  });

  test('throws FormatException when a field has the wrong type', () {
    expect(
      () => BreweryDto.fromJson(breweryJson(name: 42)),
      throwsFormatException,
    );
  });

  test('throws FormatException when required fields are missing', () {
    expect(
      () => BreweryDto.fromJson(breweryJson(name: null)),
      throwsFormatException,
    );
  });
}
