import 'dart:convert';

/// Shared helpers for deterministic JSON serialization.
String canonicalJson(Map<String, dynamic> json) {
  final sorted = Map<String, dynamic>.fromEntries(
    json.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
  );
  return jsonEncode(sorted);
}

class Product {
  const Product({
    required this.id,
    required this.name,
    required this.updatedAt,
    required this.version,
  });

  final String id;
  final String name;
  final DateTime updatedAt;
  final int version;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'updated_at': updatedAt.toIso8601String(),
        'version': version,
      };

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json['id'] as String,
        name: json['name'] as String,
        updatedAt: DateTime.parse(json['updated_at'] as String),
        version: json['version'] as int,
      );
}

class Variant {
  const Variant({
    required this.id,
    required this.productId,
    required this.sku,
    required this.priceCents,
    required this.updatedAt,
    required this.version,
  });

  final String id;
  final String productId;
  final String sku;
  final int priceCents;
  final DateTime updatedAt;
  final int version;

  Map<String, dynamic> toJson() => {
        'id': id,
        'product_id': productId,
        'sku': sku,
        'price_cents': priceCents,
        'updated_at': updatedAt.toIso8601String(),
        'version': version,
      };

  factory Variant.fromJson(Map<String, dynamic> json) => Variant(
        id: json['id'] as String,
        productId: json['product_id'] as String,
        sku: json['sku'] as String,
        priceCents: json['price_cents'] as int,
        updatedAt: DateTime.parse(json['updated_at'] as String),
        version: json['version'] as int,
      );
}

class Order {
  const Order({
    required this.id,
    required this.clientToken,
    required this.createdAt,
    required this.pendingSync,
    required this.lines,
    this.serverId,
  });

  final String id;
  final String clientToken;
  final DateTime createdAt;
  final bool pendingSync;
  final List<OrderLine> lines;
  final String? serverId;

  Map<String, dynamic> toJson() => {
        'id': id,
        'client_token': clientToken,
        'created_at': createdAt.toIso8601String(),
        'pending_sync': pendingSync,
        'server_id': serverId,
        'lines': lines.map((line) => line.toJson()).toList(),
      };

  factory Order.fromJson(Map<String, dynamic> json) => Order(
        id: json['id'] as String,
        clientToken: json['client_token'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
        pendingSync: json['pending_sync'] as bool,
        serverId: json['server_id'] as String?,
        lines: (json['lines'] as List<dynamic>)
            .map((line) => OrderLine.fromJson(line as Map<String, dynamic>))
            .toList(),
      );
}

class OrderLine {
  const OrderLine({
    required this.variantId,
    required this.quantity,
  });

  final String variantId;
  final int quantity;

  Map<String, dynamic> toJson() => {
        'variant_id': variantId,
        'quantity': quantity,
      };

  factory OrderLine.fromJson(Map<String, dynamic> json) => OrderLine(
        variantId: json['variant_id'] as String,
        quantity: json['quantity'] as int,
      );
}

enum SyncOperationType {
  submitOrder,
}

class PendingSyncOperation {
  const PendingSyncOperation({
    required this.id,
    required this.type,
    required this.entityId,
    required this.payload,
    required this.attemptCount,
    required this.nextAttemptAt,
    required this.createdAt,
    this.lastError,
  });

  final String id;
  final SyncOperationType type;
  final String entityId;
  final Map<String, dynamic> payload;
  final int attemptCount;
  final DateTime nextAttemptAt;
  final DateTime createdAt;
  final String? lastError;

  PendingSyncOperation copyWith({
    int? attemptCount,
    DateTime? nextAttemptAt,
    String? lastError,
  }) =>
      PendingSyncOperation(
        id: id,
        type: type,
        entityId: entityId,
        payload: payload,
        attemptCount: attemptCount ?? this.attemptCount,
        nextAttemptAt: nextAttemptAt ?? this.nextAttemptAt,
        createdAt: createdAt,
        lastError: lastError,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'entity_id': entityId,
        'payload': payload,
        'attempt_count': attemptCount,
        'next_attempt_at': nextAttemptAt.toIso8601String(),
        'created_at': createdAt.toIso8601String(),
        'last_error': lastError,
      };

  factory PendingSyncOperation.fromJson(Map<String, dynamic> json) =>
      PendingSyncOperation(
        id: json['id'] as String,
        type: SyncOperationType.values.byName(json['type'] as String),
        entityId: json['entity_id'] as String,
        payload: Map<String, dynamic>.from(json['payload'] as Map),
        attemptCount: json['attempt_count'] as int,
        nextAttemptAt: DateTime.parse(json['next_attempt_at'] as String),
        createdAt: DateTime.parse(json['created_at'] as String),
        lastError: json['last_error'] as String?,
      );
}
