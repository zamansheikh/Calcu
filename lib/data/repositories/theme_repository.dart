import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/services/storage_service.dart';
import '../../theme/theme_catalog.dart';

/// Persists the user's theme selections: pack id, mode, and which premium
/// packs they own. The free/Classic pack is always considered owned.
class ThemeRepository {
  ThemeRepository(this._storage);

  final StorageService _storage;

  ThemeMode readMode() {
    switch (_storage.readString(StorageKeys.themeMode)) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  Future<void> writeMode(ThemeMode mode) {
    final value = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
    return _storage.writeString(StorageKeys.themeMode, value);
  }

  String readActivePackId() =>
      _storage.readString(StorageKeys.activeThemePackId) ??
      ThemeCatalog.defaultId;

  Future<void> writeActivePackId(String id) =>
      _storage.writeString(StorageKeys.activeThemePackId, id);

  Set<String> readOwnedPackIds() {
    final stored = _storage.readStringList(StorageKeys.ownedThemePackIds) ??
        const <String>[];
    return {ThemePackId.classic, ...stored};
  }

  Future<void> writeOwnedPackIds(Set<String> ids) =>
      _storage.writeStringList(
        StorageKeys.ownedThemePackIds,
        ids.where((id) => id != ThemePackId.classic).toList(),
      );
}
