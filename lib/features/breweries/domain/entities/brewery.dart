import 'package:equatable/equatable.dart';

enum BreweryType {
  micro,
  nano,
  regional,
  brewpub,
  large,
  planning,
  bar,
  contract,
  proprietor,
  taproom,
  beergarden,
  cidery,
  closed,
  unknown,
}

class Brewery extends Equatable {
  const Brewery({
    required this.id,
    required this.name,
    required this.type,
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

  final String id;
  final String name;
  final BreweryType type;
  final String? street;
  final String? city;
  final String? stateProvince;
  final String? postalCode;
  final String? country;
  final String? phone;
  final String? websiteUrl;
  final double? latitude;
  final double? longitude;

  @override
  List<Object?> get props => [
    id,
    name,
    type,
    street,
    city,
    stateProvince,
    postalCode,
    country,
    phone,
    websiteUrl,
    latitude,
    longitude,
  ];
}
