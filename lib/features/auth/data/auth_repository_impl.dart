import '../domain/auth_entity.dart';
import '../domain/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  @override
  Future<List<AuthEntity>> fetchAll() async {
    return const [
      AuthEntity(id: 'auth-1', title: 'Auth item'),
    ];
  }
}
