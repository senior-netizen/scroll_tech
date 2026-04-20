import 'orders_entity.dart';
import 'orders_repository.dart';

class GetOrdersUseCase {
  const GetOrdersUseCase(this._repository);

  final OrdersRepository _repository;

  Future<List<OrdersEntity>> call() {
    return _repository.fetchAll();
  }
}
