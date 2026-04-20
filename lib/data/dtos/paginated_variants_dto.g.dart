// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'paginated_variants_dto.dart';

PaginatedVariantsDto _$PaginatedVariantsDtoFromJson(Map<String, dynamic> json) =>
    PaginatedVariantsDto(
      items: (json['items'] as List<dynamic>)
          .map((e) => VariantDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      currentPage: (json['current_page'] as num).toInt(),
      pageSize: (json['page_size'] as num).toInt(),
      totalCount: (json['total_count'] as num).toInt(),
      hasNextPage: json['has_next_page'] as bool,
    );

Map<String, dynamic> _$PaginatedVariantsDtoToJson(
        PaginatedVariantsDto instance) =>
    <String, dynamic>{
      'items': instance.items.map((e) => e.toJson()).toList(),
      'current_page': instance.currentPage,
      'page_size': instance.pageSize,
      'total_count': instance.totalCount,
      'has_next_page': instance.hasNextPage,
    };
