import 'package:equatable/equatable.dart';

class InquiriesEntity extends Equatable {
  const InquiriesEntity({required this.id, required this.title});

  final String id;
  final String title;

  @override
  List<Object?> get props => [id, title];
}
