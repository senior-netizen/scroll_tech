import 'package:equatable/equatable.dart';

class ShopInfo extends Equatable {
  const ShopInfo({
    required this.name,
    required this.address,
    required this.hours,
    required this.mapUrl,
    required this.directionsUrl,
  });

  final String name;
  final String address;
  final String hours;
  final String mapUrl;
  final String directionsUrl;

  @override
  List<Object?> get props => [name, address, hours, mapUrl, directionsUrl];
}
