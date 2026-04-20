import '../../domain/entities/order.dart';
import '../../domain/repositories/order_repository.dart';
import '../datasources/local/product_local_data_source.dart';
import '../datasources/remote/product_remote_data_source.dart';
import '../mappers/entity_dto_mappers.dart';

class OrderRepositoryImpl implements OrderRepository {
  OrderRepositoryImpl({
    required ProductRemoteDataSource remoteDataSource,
    required ProductLocalDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  final ProductRemoteDataSource _remoteDataSource;
  final ProductLocalDataSource _localDataSource;

  @override
  Future<Order> submitOrder(Order order) async {
    final responseDto = await _remoteDataSource.submitOrder(order.toDto());
    await _localDataSource.cacheSubmittedOrder(responseDto);
    return responseDto.toEntity();
  }
}
