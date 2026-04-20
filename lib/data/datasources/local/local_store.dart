abstract class LocalStore {
  Future<void> writeJson(String key, Map<String, dynamic> value);
  Future<void> writeJsonList(String key, List<Map<String, dynamic>> value);
  Future<Map<String, dynamic>?> readJson(String key);
  Future<List<Map<String, dynamic>>?> readJsonList(String key);
}

/// Minimal in-memory store useful for tests or bootstrapping.
class InMemoryLocalStore implements LocalStore {
  final Map<String, Object> _cache = <String, Object>{};

  @override
  Future<Map<String, dynamic>?> readJson(String key) async {
    final value = _cache[key];
    if (value is Map<String, dynamic>) {
      return value;
    }

    return null;
  }

  @override
  Future<List<Map<String, dynamic>>?> readJsonList(String key) async {
    final value = _cache[key];
    if (value is List<Map<String, dynamic>>) {
      return value;
    }

    return null;
  }

  @override
  Future<void> writeJson(String key, Map<String, dynamic> value) async {
    _cache[key] = value;
  }

  @override
  Future<void> writeJsonList(
    String key,
    List<Map<String, dynamic>> value,
  ) async {
    _cache[key] = value;
  }
}
