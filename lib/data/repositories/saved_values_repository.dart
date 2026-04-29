import '../../core/constants/app_constants.dart';
import '../../core/services/storage_service.dart';

/// Persists the list of saved calculator results across app launches.
class SavedValuesRepository {
  SavedValuesRepository(this._storage);

  final StorageService _storage;

  List<String> read() =>
      _storage.readStringList(StorageKeys.savedValues) ?? const <String>[];

  Future<void> write(List<String> values) =>
      _storage.writeStringList(StorageKeys.savedValues, values);
}
