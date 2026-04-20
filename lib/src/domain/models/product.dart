import 'package:equatable/equatable.dart';

class Product extends Equatable {
  const Product({
    required this.id,
    required this.name,
    required this.brand,
    required this.price,
    required this.stock,
    required this.imageUrl,
    required this.variants,
  });

  final String id;
  final String name;
  final String brand;
  final double price;
  final int stock;
  final String imageUrl;
  final List<String> variants;

  bool get lowStock => stock <= 5;

  @override
  List<Object?> get props => [id, name, brand, price, stock, imageUrl, variants];
}
