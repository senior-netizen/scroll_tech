import '../domain/notifications_entity.dart';
import '../domain/notifications_repository.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  @override
  Future<List<NotificationsEntity>> fetchAll() async {
    return const [
      NotificationsEntity(id: 'notifications-1', title: 'Notifications item'),
    ];
  }
}
