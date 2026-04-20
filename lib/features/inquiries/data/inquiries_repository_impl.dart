import '../domain/inquiries_entity.dart';
import '../domain/inquiries_repository.dart';

class InquiriesRepositoryImpl implements InquiriesRepository {
  @override
  Future<List<InquiriesEntity>> fetchAll() async {
    return const [
      InquiriesEntity(id: 'inquiries-1', title: 'Inquiries item'),
    ];
  }
}
