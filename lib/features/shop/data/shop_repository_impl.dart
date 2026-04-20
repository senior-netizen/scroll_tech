import '../domain/shop_entity.dart';
import '../domain/shop_repository.dart';

class ShopRepositoryImpl implements ShopRepository {
  @override
  Future<List<ShopEntity>> fetchAll() async {
    return const [
      ShopEntity(id: 'shop-1', title: 'Shop item'),
    ];
  }
}
