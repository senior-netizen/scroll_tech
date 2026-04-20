import 'auth_entity.dart';

abstract class AuthRepository {
  Future<List<AuthEntity>> fetchAll();
}
