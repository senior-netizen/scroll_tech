import 'notifications_entity.dart';

abstract class NotificationsRepository {
  Future<List<NotificationsEntity>> fetchAll();
}
