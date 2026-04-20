import 'auth_entity.dart';
import 'auth_repository.dart';

class GetAuthUseCase {
  const GetAuthUseCase(this._repository);

  final AuthRepository _repository;

  Future<List<AuthEntity>> call() {
    return _repository.fetchAll();
  }
}
