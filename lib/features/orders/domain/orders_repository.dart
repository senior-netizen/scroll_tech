import 'orders_entity.dart';

abstract class OrdersRepository {
  Future<List<OrdersEntity>> fetchAll();
}
