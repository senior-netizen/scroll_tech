class StockUpdate {
  const StockUpdate({
    required this.variantId,
    required this.stockStatus,
    required this.updatedAt,
  });

  final String variantId;
  final String stockStatus;
  final DateTime updatedAt;
}
