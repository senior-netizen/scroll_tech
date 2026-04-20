import '../entities/order.dart';

abstract class OrderRepository {
  Future<Order> submitOrder(Order order);
}
