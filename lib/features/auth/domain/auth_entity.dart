import 'package:equatable/equatable.dart';

class AuthEntity extends Equatable {
  const AuthEntity({required this.id, required this.title});

  final String id;
  final String title;

  @override
  List<Object?> get props => [id, title];
}
