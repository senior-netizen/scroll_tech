import '../entities/paginated_result.dart';
import '../entities/variant.dart';

abstract class ProductRepository {
  Future<PaginatedResult<Variant>> fetchVariants({
    required int page,
    required int pageSize,
  });
}
