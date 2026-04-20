import '../data/fake_repositories.dart';
import '../domain/repositories/repositories.dart';
import '../domain/usecases/usecases.dart';

class AppDependencies {
  AppDependencies._();

  static final CatalogRepository catalogRepository = FakeCatalogRepository();
  static final CheckoutRepository checkoutRepository = FakeCheckoutRepository();
  static final InquiryRepository inquiryRepository = FakeInquiryRepository();
  static final ShopRepository shopRepository = FakeShopRepository();
  static final TrackingRepository trackingRepository = FakeTrackingRepository();

  static GetBrandsUseCase getBrandsUseCase = GetBrandsUseCase(catalogRepository);
  static GetFeaturedUseCase getFeaturedUseCase = GetFeaturedUseCase(catalogRepository);
  static GetDealUseCase getDealUseCase = GetDealUseCase(catalogRepository);
  static GetProductsUseCase getProductsUseCase = GetProductsUseCase(catalogRepository);
  static GetProductDetailsUseCase getProductDetailsUseCase = GetProductDetailsUseCase(catalogRepository);
  static SubmitOrderUseCase submitOrderUseCase = SubmitOrderUseCase(checkoutRepository);
  static BuildInquiryLinkUseCase buildInquiryLinkUseCase = BuildInquiryLinkUseCase(inquiryRepository);
  static GetShopInfoUseCase getShopInfoUseCase = GetShopInfoUseCase(shopRepository);
  static TrackOrderUseCase trackOrderUseCase = TrackOrderUseCase(trackingRepository);
}
