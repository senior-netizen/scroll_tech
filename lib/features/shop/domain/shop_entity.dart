import 'package:equatable/equatable.dart';

class ShopEntity extends Equatable {
  const ShopEntity({required this.id, required this.title});

  final String id;
  final String title;

  @override
  List<Object?> get props => [id, title];
}
