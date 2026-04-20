import 'package:dio/dio.dart';

import '../dtos/inquiry_dto.dart';
import '../dtos/order_dto.dart';
import '../dtos/paginated_variants_dto.dart';
import '../dtos/stock_update_dto.dart';

class ProductApiClient {
  ProductApiClient(this._dio);

  final Dio _dio;

  Future<PaginatedVariantsDto> fetchProducts({
    required int page,
    required int pageSize,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/products',
      queryParameters: <String, dynamic>{
        'page': page,
        'page_size': pageSize,
      },
    );

    final data = response.data;
    if (data == null) {
      throw const FormatException('Empty product response payload');
    }

    return PaginatedVariantsDto.fromJson(data);
  }

  Future<OrderDto> submitOrder(OrderDto order) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/orders',
      data: order.toJson(),
    );

    final data = response.data;
    if (data == null) {
      throw const FormatException('Empty order response payload');
    }

    return OrderDto.fromJson(data);
  }

  Future<InquiryDto> submitInquiry(InquiryDto inquiry) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/inquiries',
      data: inquiry.toJson(),
    );

    final data = response.data;
    if (data == null) {
      throw const FormatException('Empty inquiry response payload');
    }

    return InquiryDto.fromJson(data);
  }

  Future<List<StockUpdateDto>> fetchStockUpdates({DateTime? since}) async {
    final response = await _dio.get<List<dynamic>>(
      '/stock-updates',
      queryParameters: <String, dynamic>{
        if (since != null) 'since': since.toIso8601String(),
      },
    );

    final data = response.data;
    if (data == null) {
      return <StockUpdateDto>[];
    }

    return data
        .map((entry) => StockUpdateDto.fromJson(entry as Map<String, dynamic>))
        .toList();
  }
}
