import 'package:dio_cache/src/cache_response.dart';
import 'package:dio_cache/src/stores/memory_cache_store.dart';
import 'package:meta/meta.dart';

import 'cache_store.dart';

/// A store that reads from a [primaryStore] first, and then
/// from a [backupStore].
///
/// The resulting futures form all operations are the ones from
/// the [primaryStore]. The [backupStore] operation are launched
/// but not awaited (except for [get]).
///
/// When getting a value with [get], if a cache value exists in
/// [backupStore], but not in [primaryStore], it is saved
/// to the [primaryStore] before returning the loaded value.
class BackupCacheStore extends CacheStore {
  final CacheStore primaryStore;
  final CacheStore backupStore;

  BackupCacheStore({@required this.backupStore, CacheStore activeStore})
      : assert(backupStore != null),
        primaryStore = activeStore ?? MemoryCacheStore();

  @override
  Future<void> clean(CachePriority priorityOrBelow) {
    backupStore.clean(priorityOrBelow);
    return primaryStore.clean(priorityOrBelow);
  }

  @override
  Future<void> delete(String key) {
    backupStore.delete(key);
    return primaryStore.delete(key);
  }

  @override
  Future<CacheResponse> get(String key) async {
    final existing = await primaryStore.get(key);
    if (existing != null) {
      return existing;
    }

    final backup = await backupStore.get(key);
    if (backup != null) {
      await primaryStore.set(backup);
      return backup;
    }
    return null;
  }

  @override
  Future<void> set(CacheResponse response) {
    backupStore.set(response);
    return primaryStore.set(response);
  }

  @override
  Future<void> updateExpiry(String key, DateTime newExpiry) {
    backupStore.updateExpiry(key, newExpiry);
    return primaryStore.updateExpiry(key, newExpiry);
  }
}
