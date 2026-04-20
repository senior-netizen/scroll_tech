import '../../api/product_api_client.dart';
import '../../dtos/inquiry_dto.dart';
import '../../dtos/order_dto.dart';
import '../../dtos/paginated_variants_dto.dart';
import '../../dtos/stock_update_dto.dart';

abstract class ProductRemoteDataSource {
  Future<PaginatedVariantsDto> fetchProducts({
    required int page,
    required int pageSize,
  });

  Future<OrderDto> submitOrder(OrderDto order);

  Future<InquiryDto> submitInquiry(InquiryDto inquiry);

  Future<List<StockUpdateDto>> fetchStockUpdates({DateTime? since});
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  ProductRemoteDataSourceImpl(this._apiClient);

  final ProductApiClient _apiClient;

  @override
  Future<PaginatedVariantsDto> fetchProducts({
    required int page,
    required int pageSize,
  }) {
    return _apiClient.fetchProducts(page: page, pageSize: pageSize);
  }

  @override
  Future<OrderDto> submitOrder(OrderDto order) {
    return _apiClient.submitOrder(order);
  }

  @override
  Future<InquiryDto> submitInquiry(InquiryDto inquiry) {
    return _apiClient.submitInquiry(inquiry);
  }

  @override
  Future<List<StockUpdateDto>> fetchStockUpdates({DateTime? since}) {
    return _apiClient.fetchStockUpdates(since: since);
  }
}
