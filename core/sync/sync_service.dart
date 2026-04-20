import 'dart:async';
import 'dart:math';

import '../models.dart';
import '../storage/local_store.dart';
import 'connectivity.dart';

abstract interface class RemoteOrderApi {
  /// Must be idempotent on [clientToken].
  Future<RemoteOrderResult> submitOrder({
    required String clientToken,
    required Map<String, dynamic> payload,
  });
}

class RemoteOrderResult {
  const RemoteOrderResult({
    required this.serverOrderId,
    this.conflict = false,
  });

  final String serverOrderId;
  final bool conflict;
}

abstract interface class SyncLogger {
  void info(String message, [Map<String, Object?> fields = const {}]);
  void warn(String message, [Map<String, Object?> fields = const {}]);
  void error(String message, [Map<String, Object?> fields = const {}]);
}

class NoopSyncLogger implements SyncLogger {
  @override
  void error(String message, [Map<String, Object?> fields = const {}]) {}

  @override
  void info(String message, [Map<String, Object?> fields = const {}]) {}

  @override
  void warn(String message, [Map<String, Object?> fields = const {}]) {}
}

class SyncService {
  SyncService({
    required LocalStore localStore,
    required ConnectivityMonitor connectivity,
    required RemoteOrderApi remoteOrderApi,
    SyncLogger? logger,
    DateTime Function()? now,
    Duration maxBackoff = const Duration(minutes: 5),
    int batchSize = 20,
  })  : _localStore = localStore,
        _connectivity = connectivity,
        _remoteOrderApi = remoteOrderApi,
        _logger = logger ?? NoopSyncLogger(),
        _now = now ?? DateTime.now,
        _maxBackoff = maxBackoff,
        _batchSize = batchSize;

  final LocalStore _localStore;
  final ConnectivityMonitor _connectivity;
  final RemoteOrderApi _remoteOrderApi;
  final SyncLogger _logger;
  final DateTime Function() _now;
  final Duration _maxBackoff;
  final int _batchSize;

  StreamSubscription<ConnectivityStatus>? _subscription;
  bool _isFlushing = false;

  Future<void> start() async {
    _subscription = _connectivity.status.listen((status) {
      if (status == ConnectivityStatus.online) {
        unawaited(flush());
      }
    });

    if (await _connectivity.currentStatus() == ConnectivityStatus.online) {
      await flush();
    }
  }

  Future<void> stop() async {
    await _subscription?.cancel();
    _subscription = null;
  }

  Future<void> flush() async {
    if (_isFlushing) {
      return;
    }

    _isFlushing = true;
    try {
      while (true) {
        final operations = await _localStore.dueOperations(
          now: _now().toUtc(),
          limit: _batchSize,
        );

        if (operations.isEmpty) {
          return;
        }

        for (final operation in operations) {
          await _apply(operation);
        }
      }
    } finally {
      _isFlushing = false;
    }
  }

  Future<void> _apply(PendingSyncOperation operation) async {
    switch (operation.type) {
      case SyncOperationType.submitOrder:
        await _submitOrder(operation);
        return;
    }
  }

  Future<void> _submitOrder(PendingSyncOperation operation) async {
    final payload = operation.payload;
    final clientToken = payload['client_token'] as String;

    try {
      final result = await _remoteOrderApi.submitOrder(
        clientToken: clientToken,
        payload: payload,
      );

      await _localStore.markOrderSynced(
        orderId: operation.entityId,
        serverId: result.serverOrderId,
      );
      await _localStore.deleteOperation(operation.id);

      _logger.info('order synced', {
        'operation_id': operation.id,
        'order_id': operation.entityId,
        'server_order_id': result.serverOrderId,
        'conflict': result.conflict,
      });
    } on ConflictException catch (error) {
      // Order is already known by server. Resolve locally as synced.
      await _localStore.markOrderSynced(
        orderId: operation.entityId,
        serverId: error.serverOrderId,
      );
      await _localStore.deleteOperation(operation.id);

      _logger.warn('order conflict resolved as idempotent success', {
        'operation_id': operation.id,
        'order_id': operation.entityId,
        'server_order_id': error.serverOrderId,
      });
    } on RetryableSyncException catch (error) {
      await _rescheduleWithBackoff(operation, error.message);
    } catch (error) {
      await _rescheduleWithBackoff(operation, error.toString());
    }
  }

  Future<void> _rescheduleWithBackoff(
    PendingSyncOperation operation,
    String error,
  ) async {
    final nextAttempt = operation.attemptCount + 1;
    final backoffSeconds = min(pow(2, nextAttempt).toInt(), _maxBackoff.inSeconds);

    final jitter = Random.secure().nextInt(1000);
    final nextAttemptAt = _now().toUtc().add(
      Duration(seconds: backoffSeconds, milliseconds: jitter),
    );

    await _localStore.updateOperation(
      operation.copyWith(
        attemptCount: nextAttempt,
        nextAttemptAt: nextAttemptAt,
        lastError: error,
      ),
    );

    _logger.warn('sync operation deferred', {
      'operation_id': operation.id,
      'entity_id': operation.entityId,
      'attempt_count': nextAttempt,
      'next_attempt_at': nextAttemptAt.toIso8601String(),
      'error': error,
    });
  }
}

class RetryableSyncException implements Exception {
  RetryableSyncException(this.message);

  final String message;
}

class ConflictException implements Exception {
  ConflictException({required this.serverOrderId});

  final String serverOrderId;
}
