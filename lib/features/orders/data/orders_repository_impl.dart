import '../domain/orders_entity.dart';
import '../domain/orders_repository.dart';

class OrdersRepositoryImpl implements OrdersRepository {
  @override
  Future<List<OrdersEntity>> fetchAll() async {
    return const [
      OrdersEntity(id: 'orders-1', title: 'Orders item'),
    ];
  }
}
