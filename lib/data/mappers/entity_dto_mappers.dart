import '../../domain/entities/brand.dart';
import '../../domain/entities/inquiry.dart';
import '../../domain/entities/model.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/paginated_result.dart';
import '../../domain/entities/stock_update.dart';
import '../../domain/entities/variant.dart';
import '../dtos/brand_dto.dart';
import '../dtos/inquiry_dto.dart';
import '../dtos/model_dto.dart';
import '../dtos/order_dto.dart';
import '../dtos/paginated_variants_dto.dart';
import '../dtos/stock_update_dto.dart';
import '../dtos/variant_dto.dart';

extension BrandDtoMapper on BrandDto {
  Brand toEntity() => Brand(id: id, name: name, logo: logo);
}

extension BrandMapper on Brand {
  BrandDto toDto() => BrandDto(id: id, name: name, logo: logo);
}

extension ModelDtoMapper on ModelDto {
  Model toEntity() => Model(id: id, brandId: brandId, name: name);
}

extension ModelMapper on Model {
  ModelDto toDto() => ModelDto(id: id, brandId: brandId, name: name);
}

extension VariantDtoMapper on VariantDto {
  Variant toEntity() => Variant(
        id: id,
        modelId: modelId,
        ram: ram,
        storage: storage,
        condition: condition,
        price: price,
        stockStatus: stockStatus,
      );
}

extension VariantMapper on Variant {
  VariantDto toDto() => VariantDto(
        id: id,
        modelId: modelId,
        ram: ram,
        storage: storage,
        condition: condition,
        price: price,
        stockStatus: stockStatus,
      );
}

extension OrderDtoMapper on OrderDto {
  Order toEntity() => Order(
        id: id,
        userId: userId,
        variantId: variantId,
        depositAmount: depositAmount,
        status: status,
      );
}

extension OrderMapper on Order {
  OrderDto toDto() => OrderDto(
        id: id,
        userId: userId,
        variantId: variantId,
        depositAmount: depositAmount,
        status: status,
      );
}

extension InquiryDtoMapper on InquiryDto {
  Inquiry toEntity() => Inquiry(
        id: id,
        productContext: productContext,
        message: message,
        status: status,
      );
}

extension InquiryMapper on Inquiry {
  InquiryDto toDto() => InquiryDto(
        id: id,
        productContext: productContext,
        message: message,
        status: status,
      );
}

extension StockUpdateDtoMapper on StockUpdateDto {
  StockUpdate toEntity() => StockUpdate(
        variantId: variantId,
        stockStatus: stockStatus,
        updatedAt: updatedAt,
      );
}

extension StockUpdateMapper on StockUpdate {
  StockUpdateDto toDto() => StockUpdateDto(
        variantId: variantId,
        stockStatus: stockStatus,
        updatedAt: updatedAt,
      );
}

extension PaginatedVariantsDtoMapper on PaginatedVariantsDto {
  PaginatedResult<Variant> toEntity() => PaginatedResult<Variant>(
        items: items.map((item) => item.toEntity()).toList(),
        currentPage: currentPage,
        pageSize: pageSize,
        totalCount: totalCount,
        hasNextPage: hasNextPage,
      );
}
