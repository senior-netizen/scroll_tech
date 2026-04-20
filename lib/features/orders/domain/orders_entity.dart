import 'package:equatable/equatable.dart';

class OrdersEntity extends Equatable {
  const OrdersEntity({required this.id, required this.title});

  final String id;
  final String title;

  @override
  List<Object?> get props => [id, title];
}
