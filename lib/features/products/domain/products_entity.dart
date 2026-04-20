import 'package:equatable/equatable.dart';

class ProductsEntity extends Equatable {
  const ProductsEntity({required this.id, required this.title});

  final String id;
  final String title;

  @override
  List<Object?> get props => [id, title];
}
