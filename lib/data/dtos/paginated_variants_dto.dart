import 'package:json_annotation/json_annotation.dart';

import 'variant_dto.dart';

part 'paginated_variants_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class PaginatedVariantsDto {
  const PaginatedVariantsDto({
    required this.items,
    @JsonKey(name: 'current_page') required this.currentPage,
    @JsonKey(name: 'page_size') required this.pageSize,
    @JsonKey(name: 'total_count') required this.totalCount,
    @JsonKey(name: 'has_next_page') required this.hasNextPage,
  });

  final List<VariantDto> items;
  final int currentPage;
  final int pageSize;
  final int totalCount;
  final bool hasNextPage;

  factory PaginatedVariantsDto.fromJson(Map<String, dynamic> json) =>
      _$PaginatedVariantsDtoFromJson(json);

  Map<String, dynamic> toJson() => _$PaginatedVariantsDtoToJson(this);
}
