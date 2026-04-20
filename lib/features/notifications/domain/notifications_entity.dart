import 'package:equatable/equatable.dart';

class NotificationsEntity extends Equatable {
  const NotificationsEntity({required this.id, required this.title});

  final String id;
  final String title;

  @override
  List<Object?> get props => [id, title];
}
