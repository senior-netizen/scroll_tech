class PaginatedResult<T> {
  const PaginatedResult({
    required this.items,
    required this.currentPage,
    required this.pageSize,
    required this.totalCount,
    required this.hasNextPage,
  });

  final List<T> items;
  final int currentPage;
  final int pageSize;
  final int totalCount;
  final bool hasNextPage;
}
