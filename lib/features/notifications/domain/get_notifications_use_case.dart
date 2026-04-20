import 'notifications_entity.dart';
import 'notifications_repository.dart';

class GetNotificationsUseCase {
  const GetNotificationsUseCase(this._repository);

  final NotificationsRepository _repository;

  Future<List<NotificationsEntity>> call() {
    return _repository.fetchAll();
  }
}
