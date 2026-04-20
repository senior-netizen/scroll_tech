import '../../domain/entities/stock_update.dart';
import '../../domain/repositories/stock_repository.dart';
import '../datasources/local/product_local_data_source.dart';
import '../datasources/remote/product_remote_data_source.dart';
import '../mappers/entity_dto_mappers.dart';

class StockRepositoryImpl implements StockRepository {
  StockRepositoryImpl({
    required ProductRemoteDataSource remoteDataSource,
    required ProductLocalDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  final ProductRemoteDataSource _remoteDataSource;
  final ProductLocalDataSource _localDataSource;

  @override
  Future<List<StockUpdate>> fetchStockUpdates({DateTime? since}) async {
    try {
      final remote = await _remoteDataSource.fetchStockUpdates(since: since);
      await _localDataSource.cacheStockUpdates(remote);
      return remote.map((dto) => dto.toEntity()).toList();
    } catch (_) {
      final cached = await _localDataSource.getCachedStockUpdates();
      return cached.map((dto) => dto.toEntity()).toList();
    }
  }
}
