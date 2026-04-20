import 'shop_entity.dart';
import 'shop_repository.dart';

class GetShopUseCase {
  const GetShopUseCase(this._repository);

  final ShopRepository _repository;

  Future<List<ShopEntity>> call() {
    return _repository.fetchAll();
  }
}
