import 'inquiries_entity.dart';
import 'inquiries_repository.dart';

class GetInquiriesUseCase {
  const GetInquiriesUseCase(this._repository);

  final InquiriesRepository _repository;

  Future<List<InquiriesEntity>> call() {
    return _repository.fetchAll();
  }
}
