import 'package:forest_test/features/breweries/domain/entities/brewery.dart';

Brewery brewery(int index) => Brewery(
  id: 'id-$index',
  name: 'Brewery $index',
  type: BreweryType.micro,
  city: 'Portland',
  stateProvince: 'Oregon',
);

List<Brewery> breweries(int count, {int from = 0}) =>
    List.generate(count, (i) => brewery(from + i));

Map<String, dynamic> breweryJson({
  String id = 'abc',
  Object? name = 'Dog Days Brewing',
  Object? latitude = 47.565,
}) => {
  'id': id,
  'name': name,
  'brewery_type': 'brewpub',
  'address_1': '260 4th St',
  'address_2': null,
  'city': 'Bremerton',
  'state_province': 'Washington',
  'postal_code': '98337-1813',
  'country': 'United States',
  'longitude': -122.6259002,
  'latitude': latitude,
  'phone': '3603777788',
  'website_url': 'http://www.dogdaysbrewing.com',
  'state': 'Washington',
  'street': '260 4th St',
};
