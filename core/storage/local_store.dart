import '../models.dart';

abstract interface class LocalStore {
  Future<void> upsertProducts(List<Product> products);
  Future<List<Product>> getProducts({DateTime? newerThan});

  Future<void> upsertVariants(List<Variant> variants);
  Future<List<Variant>> getVariantsByProduct(String productId);

  Future<void> saveOrder(Order order);
  Future<Order?> getOrderById(String orderId);
  Future<void> markOrderSynced({
    required String orderId,
    required String serverId,
  });

  Future<void> enqueue(PendingSyncOperation operation);
  Future<List<PendingSyncOperation>> dueOperations({
    required DateTime now,
    int limit = 50,
  });
  Future<void> updateOperation(PendingSyncOperation operation);
  Future<void> deleteOperation(String operationId);
}
