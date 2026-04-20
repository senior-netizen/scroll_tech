enum ConnectivityStatus {
  online,
  offline,
}

abstract interface class ConnectivityMonitor {
  Stream<ConnectivityStatus> get status;
  Future<ConnectivityStatus> currentStatus();
}
