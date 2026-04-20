import '../models/models.dart';
import '../repositories/repositories.dart';

class GetBrandsUseCase {
  GetBrandsUseCase(this.repository);
  final CatalogRepository repository;
  Future<List<String>> call() => repository.getBrands();
}

class GetFeaturedUseCase {
  GetFeaturedUseCase(this.repository);
  final CatalogRepository repository;
  Future<List<Product>> call() => repository.getFeatured();
}

class GetDealUseCase {
  GetDealUseCase(this.repository);
  final CatalogRepository repository;
  Future<Product> call() => repository.getDealOfTheDay();
}

class GetProductsUseCase {
  GetProductsUseCase(this.repository);
  final CatalogRepository repository;
  Future<List<Product>> call({
    required int page,
    required int pageSize,
    String? search,
    String? brand,
  }) => repository.getProducts(page: page, pageSize: pageSize, search: search, brand: brand);
}

class GetProductDetailsUseCase {
  GetProductDetailsUseCase(this.repository);
  final CatalogRepository repository;
  Future<Product> call(String id) => repository.getProduct(id);
}

class SubmitOrderUseCase {
  SubmitOrderUseCase(this.repository);
  final CheckoutRepository repository;
  Future<String> call({
    required String name,
    required String phone,
    required String paymentMethod,
    String? paymentProofPath,
  }) => repository.submitOrder(
    name: name,
    phone: phone,
    paymentMethod: paymentMethod,
    paymentProofPath: paymentProofPath,
  );
}

class BuildInquiryLinkUseCase {
  BuildInquiryLinkUseCase(this.repository);
  final InquiryRepository repository;
  Future<String> call({required String context, required String phone}) =>
      repository.createWhatsappDeepLink(context: context, phone: phone);
}

class GetShopInfoUseCase {
  GetShopInfoUseCase(this.repository);
  final ShopRepository repository;
  Future<ShopInfo> call() => repository.getShopInfo();
}

class TrackOrderUseCase {
  TrackOrderUseCase(this.repository);
  final TrackingRepository repository;
  Future<String> call(String id) => repository.track(id);
}
