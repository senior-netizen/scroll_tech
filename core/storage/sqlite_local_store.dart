import 'dart:convert';

import '../models.dart';
import 'local_store.dart';

/// Minimal DB protocol to keep this adapter testable and package-agnostic.
abstract interface class SqlExecutor {
  Future<void> execute(String sql, [List<Object?> params = const []]);
  Future<List<Map<String, Object?>>> query(
    String sql, [
    List<Object?> params = const [],
  ]);
}

class SqliteSchema {
  static const List<String> statements = [
    '''
CREATE TABLE IF NOT EXISTS products (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  version INTEGER NOT NULL
)
''',
    '''
CREATE TABLE IF NOT EXISTS variants (
  id TEXT PRIMARY KEY,
  product_id TEXT NOT NULL,
  sku TEXT NOT NULL,
  price_cents INTEGER NOT NULL,
  updated_at TEXT NOT NULL,
  version INTEGER NOT NULL,
  FOREIGN KEY(product_id) REFERENCES products(id)
)
''',
    '''
CREATE INDEX IF NOT EXISTS idx_variants_product_id ON variants(product_id)
''',
    '''
CREATE TABLE IF NOT EXISTS orders (
  id TEXT PRIMARY KEY,
  client_token TEXT UNIQUE NOT NULL,
  server_id TEXT,
  created_at TEXT NOT NULL,
  pending_sync INTEGER NOT NULL,
  payload TEXT NOT NULL
)
''',
    '''
CREATE TABLE IF NOT EXISTS pending_sync_queue (
  id TEXT PRIMARY KEY,
  type TEXT NOT NULL,
  entity_id TEXT NOT NULL,
  payload TEXT NOT NULL,
  attempt_count INTEGER NOT NULL,
  next_attempt_at TEXT NOT NULL,
  created_at TEXT NOT NULL,
  last_error TEXT
)
''',
    '''
CREATE INDEX IF NOT EXISTS idx_pending_sync_next_attempt
ON pending_sync_queue(next_attempt_at)
''',
  ];
}

class SqliteLocalStore implements LocalStore {
  SqliteLocalStore(this._db);

  final SqlExecutor _db;

  Future<void> initialize() async {
    for (final statement in SqliteSchema.statements) {
      await _db.execute(statement);
    }
  }

  @override
  Future<List<Product>> getProducts({DateTime? newerThan}) async {
    final rows = await _db.query(
      newerThan == null
          ? 'SELECT id, name, updated_at, version FROM products ORDER BY name'
          : 'SELECT id, name, updated_at, version FROM products WHERE updated_at > ? ORDER BY name',
      newerThan == null ? const [] : [newerThan.toIso8601String()],
    );

    return rows
        .map((row) => Product.fromJson(_asStringMap(row)))
        .toList(growable: false);
  }

  @override
  Future<void> upsertProducts(List<Product> products) async {
    for (final product in products) {
      await _db.execute(
        '''
INSERT INTO products(id, name, updated_at, version)
VALUES (?, ?, ?, ?)
ON CONFLICT(id) DO UPDATE SET
  name = excluded.name,
  updated_at = excluded.updated_at,
  version = excluded.version
''',
        [
          product.id,
          product.name,
          product.updatedAt.toIso8601String(),
          product.version,
        ],
      );
    }
  }

  @override
  Future<void> upsertVariants(List<Variant> variants) async {
    for (final variant in variants) {
      await _db.execute(
        '''
INSERT INTO variants(id, product_id, sku, price_cents, updated_at, version)
VALUES (?, ?, ?, ?, ?, ?)
ON CONFLICT(id) DO UPDATE SET
  product_id = excluded.product_id,
  sku = excluded.sku,
  price_cents = excluded.price_cents,
  updated_at = excluded.updated_at,
  version = excluded.version
''',
        [
          variant.id,
          variant.productId,
          variant.sku,
          variant.priceCents,
          variant.updatedAt.toIso8601String(),
          variant.version,
        ],
      );
    }
  }

  @override
  Future<List<Variant>> getVariantsByProduct(String productId) async {
    final rows = await _db.query(
      '''
SELECT id, product_id, sku, price_cents, updated_at, version
FROM variants
WHERE product_id = ?
ORDER BY sku
''',
      [productId],
    );
    return rows
        .map((row) => Variant.fromJson(_asStringMap(row)))
        .toList(growable: false);
  }

  @override
  Future<void> saveOrder(Order order) async {
    await _db.execute(
      '''
INSERT INTO orders(id, client_token, server_id, created_at, pending_sync, payload)
VALUES (?, ?, ?, ?, ?, ?)
ON CONFLICT(id) DO UPDATE SET
  client_token = excluded.client_token,
  server_id = excluded.server_id,
  created_at = excluded.created_at,
  pending_sync = excluded.pending_sync,
  payload = excluded.payload
''',
      [
        order.id,
        order.clientToken,
        order.serverId,
        order.createdAt.toIso8601String(),
        order.pendingSync ? 1 : 0,
        canonicalJson(order.toJson()),
      ],
    );
  }

  @override
  Future<Order?> getOrderById(String orderId) async {
    final rows = await _db.query(
      'SELECT payload FROM orders WHERE id = ? LIMIT 1',
      [orderId],
    );

    if (rows.isEmpty) {
      return null;
    }

    final payload = rows.first['payload'] as String;
    return Order.fromJson(Map<String, dynamic>.from(jsonDecode(payload) as Map));
  }

  @override
  Future<void> markOrderSynced({
    required String orderId,
    required String serverId,
  }) async {
    final order = await getOrderById(orderId);
    if (order == null) {
      return;
    }

    await saveOrder(
      Order(
        id: order.id,
        clientToken: order.clientToken,
        createdAt: order.createdAt,
        pendingSync: false,
        lines: order.lines,
        serverId: serverId,
      ),
    );
  }

  @override
  Future<void> enqueue(PendingSyncOperation operation) async {
    await _db.execute(
      '''
INSERT INTO pending_sync_queue(
  id, type, entity_id, payload, attempt_count, next_attempt_at, created_at, last_error
)
VALUES (?, ?, ?, ?, ?, ?, ?, ?)
ON CONFLICT(id) DO UPDATE SET
  type = excluded.type,
  entity_id = excluded.entity_id,
  payload = excluded.payload,
  attempt_count = excluded.attempt_count,
  next_attempt_at = excluded.next_attempt_at,
  created_at = excluded.created_at,
  last_error = excluded.last_error
''',
      [
        operation.id,
        operation.type.name,
        operation.entityId,
        canonicalJson(operation.payload),
        operation.attemptCount,
        operation.nextAttemptAt.toIso8601String(),
        operation.createdAt.toIso8601String(),
        operation.lastError,
      ],
    );
  }

  @override
  Future<List<PendingSyncOperation>> dueOperations({
    required DateTime now,
    int limit = 50,
  }) async {
    final rows = await _db.query(
      '''
SELECT id, type, entity_id, payload, attempt_count, next_attempt_at, created_at, last_error
FROM pending_sync_queue
WHERE next_attempt_at <= ?
ORDER BY created_at
LIMIT ?
''',
      [now.toIso8601String(), limit],
    );

    return rows.map((row) {
      final data = _asStringMap(row);
      data['payload'] =
          Map<String, dynamic>.from(jsonDecode(data['payload'] as String) as Map);
      return PendingSyncOperation.fromJson(data);
    }).toList(growable: false);
  }

  @override
  Future<void> updateOperation(PendingSyncOperation operation) => enqueue(operation);

  @override
  Future<void> deleteOperation(String operationId) async {
    await _db.execute('DELETE FROM pending_sync_queue WHERE id = ?', [operationId]);
  }

  Map<String, dynamic> _asStringMap(Map<String, Object?> row) {
    return row.map((key, value) => MapEntry(key, value));
  }
}
