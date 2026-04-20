import 'products_entity.dart';
import 'products_repository.dart';

class GetProductsUseCase {
  const GetProductsUseCase(this._repository);

  final ProductsRepository _repository;

  Future<List<ProductsEntity>> call() {
    return _repository.fetchAll();
  }
}
