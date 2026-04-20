import 'dart:math';

import '../models.dart';
import '../storage/local_store.dart';

abstract interface class UuidGenerator {
  String v4();
}

class DefaultUuidGenerator implements UuidGenerator {
  @override
  String v4() {
    final random = Random.secure();
    final values = List<int>.generate(16, (_) => random.nextInt(256));
    values[6] = (values[6] & 0x0f) | 0x40;
    values[8] = (values[8] & 0x3f) | 0x80;
    return _hex(values);
  }

  String _hex(List<int> bytes) {
    final segments = <String>[
      bytes.sublist(0, 4),
      bytes.sublist(4, 6),
      bytes.sublist(6, 8),
      bytes.sublist(8, 10),
      bytes.sublist(10, 16),
    ].map((segment) =>
        segment.map((b) => b.toRadixString(16).padLeft(2, '0')).join());
    return segments.join('-');
  }
}

class OrderRepository {
  OrderRepository({
    required LocalStore localStore,
    UuidGenerator? uuid,
    DateTime Function()? now,
  })  : _localStore = localStore,
        _uuid = uuid ?? DefaultUuidGenerator(),
        _now = now ?? DateTime.now;

  final LocalStore _localStore;
  final UuidGenerator _uuid;
  final DateTime Function() _now;

  /// Local-first order persistence + sync queue enqueue.
  Future<Order> createOrder(List<OrderLine> lines) async {
    final orderId = _uuid.v4();
    final token = _uuid.v4();
    final createdAt = _now().toUtc();

    final order = Order(
      id: orderId,
      clientToken: token,
      createdAt: createdAt,
      pendingSync: true,
      lines: lines,
    );

    final operation = PendingSyncOperation(
      id: _uuid.v4(),
      type: SyncOperationType.submitOrder,
      entityId: order.id,
      payload: order.toJson(),
      attemptCount: 0,
      nextAttemptAt: createdAt,
      createdAt: createdAt,
    );

    await _localStore.saveOrder(order);
    await _localStore.enqueue(operation);

    return order;
  }
}
