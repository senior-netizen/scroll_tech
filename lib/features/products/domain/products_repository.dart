import 'products_entity.dart';

abstract class ProductsRepository {
  Future<List<ProductsEntity>> fetchAll();
}
