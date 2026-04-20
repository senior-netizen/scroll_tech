class Variant {
  const Variant({
    required this.id,
    required this.modelId,
    required this.ram,
    required this.storage,
    required this.condition,
    required this.price,
    required this.stockStatus,
  });

  final String id;
  final String modelId;
  final String ram;
  final String storage;
  final String condition;
  final double price;
  final String stockStatus;
}
