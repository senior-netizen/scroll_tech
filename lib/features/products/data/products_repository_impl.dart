import '../domain/products_entity.dart';
import '../domain/products_repository.dart';

class ProductsRepositoryImpl implements ProductsRepository {
  @override
  Future<List<ProductsEntity>> fetchAll() async {
    return const [
      ProductsEntity(id: 'products-1', title: 'Products item'),
    ];
  }
}
