import '../../core/constants/app_constants.dart';
import '../../core/services/storage_service.dart';
import '../models/saved_entry.dart';

/// Persists the saved calculator results across app launches.
class SavedValuesRepository {
  SavedValuesRepository(this._storage);

  final StorageService _storage;

  List<SavedEntry> read() {
    final stored = _storage.readStringList(StorageKeys.savedEntries);
    if (stored != null) {
      return [for (final raw in stored) SavedEntry.decode(raw)];
    }
    // Earlier versions kept only the values, under their own key. That list
    // is read but never rewritten, so it survives a downgrade.
    final values = _storage.readStringList(StorageKeys.savedValues);
    return [
      for (final value in values ?? const <String>[]) SavedEntry(value: value),
    ];
  }

  Future<void> write(List<SavedEntry> entries) => _storage.writeStringList(
    StorageKeys.savedEntries,
    [for (final entry in entries) entry.encode()],
  );
}
