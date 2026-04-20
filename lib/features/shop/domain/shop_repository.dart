import 'shop_entity.dart';

abstract class ShopRepository {
  Future<List<ShopEntity>> fetchAll();
}
