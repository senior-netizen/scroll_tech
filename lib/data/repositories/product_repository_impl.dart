import '../../domain/entities/paginated_result.dart';
import '../../domain/entities/variant.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/local/product_local_data_source.dart';
import '../datasources/remote/product_remote_data_source.dart';
import '../mappers/entity_dto_mappers.dart';

class ProductRepositoryImpl implements ProductRepository {
  ProductRepositoryImpl({
    required ProductRemoteDataSource remoteDataSource,
    required ProductLocalDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  final ProductRemoteDataSource _remoteDataSource;
  final ProductLocalDataSource _localDataSource;

  @override
  Future<PaginatedResult<Variant>> fetchVariants({
    required int page,
    required int pageSize,
  }) async {
    try {
      final pageDto = await _remoteDataSource.fetchProducts(
        page: page,
        pageSize: pageSize,
      );
      await _localDataSource.cacheProductPage(pageDto);
      return pageDto.toEntity();
    } catch (_) {
      final cached = await _localDataSource.getCachedProductPage();
      if (cached == null) {
        rethrow;
      }

      return cached.toEntity();
    }
  }
}
