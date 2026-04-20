import 'inquiries_entity.dart';

abstract class InquiriesRepository {
  Future<List<InquiriesEntity>> fetchAll();
}
