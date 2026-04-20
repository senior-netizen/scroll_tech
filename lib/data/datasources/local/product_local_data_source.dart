import '../../dtos/inquiry_dto.dart';
import '../../dtos/order_dto.dart';
import '../../dtos/paginated_variants_dto.dart';
import '../../dtos/stock_update_dto.dart';
import 'local_store.dart';

abstract class ProductLocalDataSource {
  Future<void> cacheProductPage(PaginatedVariantsDto pageDto);
  Future<PaginatedVariantsDto?> getCachedProductPage();

  Future<void> cacheSubmittedOrder(OrderDto orderDto);
  Future<OrderDto?> getLastSubmittedOrder();

  Future<void> cacheSubmittedInquiry(InquiryDto inquiryDto);
  Future<InquiryDto?> getLastSubmittedInquiry();

  Future<void> cacheStockUpdates(List<StockUpdateDto> updates);
  Future<List<StockUpdateDto>> getCachedStockUpdates();
}

class ProductLocalDataSourceImpl implements ProductLocalDataSource {
  ProductLocalDataSourceImpl(this._store);

  final LocalStore _store;

  static const String _productPageKey = 'product_page';
  static const String _orderKey = 'last_order';
  static const String _inquiryKey = 'last_inquiry';
  static const String _stockUpdatesKey = 'stock_updates';

  @override
  Future<void> cacheProductPage(PaginatedVariantsDto pageDto) {
    return _store.writeJson(_productPageKey, pageDto.toJson());
  }

  @override
  Future<PaginatedVariantsDto?> getCachedProductPage() async {
    final payload = await _store.readJson(_productPageKey);
    if (payload == null) {
      return null;
    }

    return PaginatedVariantsDto.fromJson(payload);
  }

  @override
  Future<void> cacheSubmittedOrder(OrderDto orderDto) {
    return _store.writeJson(_orderKey, orderDto.toJson());
  }

  @override
  Future<OrderDto?> getLastSubmittedOrder() async {
    final payload = await _store.readJson(_orderKey);
    if (payload == null) {
      return null;
    }

    return OrderDto.fromJson(payload);
  }

  @override
  Future<void> cacheSubmittedInquiry(InquiryDto inquiryDto) {
    return _store.writeJson(_inquiryKey, inquiryDto.toJson());
  }

  @override
  Future<InquiryDto?> getLastSubmittedInquiry() async {
    final payload = await _store.readJson(_inquiryKey);
    if (payload == null) {
      return null;
    }

    return InquiryDto.fromJson(payload);
  }

  @override
  Future<void> cacheStockUpdates(List<StockUpdateDto> updates) {
    return _store.writeJsonList(
      _stockUpdatesKey,
      updates.map((update) => update.toJson()).toList(),
    );
  }

  @override
  Future<List<StockUpdateDto>> getCachedStockUpdates() async {
    final payload = await _store.readJsonList(_stockUpdatesKey);
    if (payload == null) {
      return <StockUpdateDto>[];
    }

    return payload.map(StockUpdateDto.fromJson).toList();
  }
}
