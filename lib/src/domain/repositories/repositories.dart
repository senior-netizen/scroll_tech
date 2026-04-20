import '../models/models.dart';

abstract class CatalogRepository {
  Future<List<String>> getBrands();
  Future<List<Product>> getFeatured();
  Future<Product> getDealOfTheDay();
  Future<List<Product>> getProducts({
    required int page,
    required int pageSize,
    String? search,
    String? brand,
  });
  Future<Product> getProduct(String id);
}

abstract class CheckoutRepository {
  Future<String> submitOrder({
    required String name,
    required String phone,
    required String paymentMethod,
    String? paymentProofPath,
  });
}

abstract class InquiryRepository {
  Future<String> createWhatsappDeepLink({required String context, required String phone});
}

abstract class ShopRepository {
  Future<ShopInfo> getShopInfo();
}

abstract class TrackingRepository {
  Future<String> track(String orderId);
}
