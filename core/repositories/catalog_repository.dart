import '../models.dart';
import '../storage/local_store.dart';

abstract interface class CatalogRemoteDataSource {
  Future<List<Product>> fetchProducts({DateTime? newerThan});
  Future<List<Variant>> fetchVariantsByProduct(String productId);
}

/// Read-through cache: local store is source of truth for browsing.
class CatalogRepository {
  CatalogRepository({
    required LocalStore localStore,
    required CatalogRemoteDataSource remote,
  })  : _localStore = localStore,
        _remote = remote;

  final LocalStore _localStore;
  final CatalogRemoteDataSource _remote;

  Future<List<Product>> browseProducts({bool refresh = true}) async {
    final cached = await _localStore.getProducts();
    if (!refresh) {
      return cached;
    }

    final watermark =
        cached.isEmpty ? null : cached.map((p) => p.updatedAt).reduce(_max);

    try {
      final delta = await _remote.fetchProducts(newerThan: watermark);
      if (delta.isNotEmpty) {
        await _localStore.upsertProducts(delta);
        return _localStore.getProducts();
      }
    } catch (_) {
      // Serve stale cache during remote failures.
    }

    return cached;
  }

  Future<List<Variant>> browseVariants(
    String productId, {
    bool refresh = true,
  }) async {
    final cached = await _localStore.getVariantsByProduct(productId);
    if (!refresh) {
      return cached;
    }

    try {
      final fresh = await _remote.fetchVariantsByProduct(productId);
      if (fresh.isNotEmpty) {
        await _localStore.upsertVariants(fresh);
        return _localStore.getVariantsByProduct(productId);
      }
    } catch (_) {
      // Keep cached data on network errors.
    }

    return cached;
  }

  DateTime _max(DateTime a, DateTime b) => a.isAfter(b) ? a : b;
}
