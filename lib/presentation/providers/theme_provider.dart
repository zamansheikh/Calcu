import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../data/repositories/theme_repository.dart';
import '../../theme/theme_catalog.dart';

/// Owns the user's theme selections and exposes ownership/purchase state for
/// the in-app theme store.
class ThemeProvider extends ChangeNotifier {
  ThemeProvider(this._repository) {
    _mode = _repository.readMode();
    _activePackId = _repository.readActivePackId();
    _ownedIds = {..._repository.readOwnedPackIds()};
    if (!_ownedIds.contains(_activePackId)) {
      // Defensive: if the persisted pack isn't owned (e.g. data corruption)
      // fall back to the default to avoid a broken UI.
      _activePackId = ThemeCatalog.defaultId;
    }
  }

  final ThemeRepository _repository;

  late ThemeMode _mode;
  late String _activePackId;
  late Set<String> _ownedIds;

  ThemeMode get themeMode => _mode;
  String get activePackId => _activePackId;
  ThemePack get activePack => ThemeCatalog.byId(_activePackId);
  List<ThemePack> get packs => ThemeCatalog.packs;

  bool get isDarkMode {
    switch (_mode) {
      case ThemeMode.dark:
        return true;
      case ThemeMode.light:
        return false;
      case ThemeMode.system:
        return SchedulerBinding
                .instance.platformDispatcher.platformBrightness ==
            Brightness.dark;
    }
  }

  bool isOwned(String packId) => _ownedIds.contains(packId);

  void cycleMode() {
    final next = switch (_mode) {
      ThemeMode.system => ThemeMode.light,
      ThemeMode.light => ThemeMode.dark,
      ThemeMode.dark => ThemeMode.system,
    };
    setMode(next);
  }

  void toggleLightDark() {
    setMode(isDarkMode ? ThemeMode.light : ThemeMode.dark);
  }

  void setMode(ThemeMode mode) {
    if (_mode == mode) return;
    _mode = mode;
    _repository.writeMode(mode);
    notifyListeners();
  }

  bool selectPack(String id) {
    if (!_ownedIds.contains(id)) return false;
    if (_activePackId == id) return true;
    _activePackId = id;
    _repository.writeActivePackId(id);
    notifyListeners();
    return true;
  }

  /// Mock purchase flow. Real billing integration would replace this with the
  /// platform purchase API; the rest of the app already relies on
  /// `isOwned`/`selectPack` so the swap is local to this method.
  Future<bool> purchasePack(String id) async {
    if (_ownedIds.contains(id)) return true;
    _ownedIds = {..._ownedIds, id};
    await _repository.writeOwnedPackIds(_ownedIds);
    notifyListeners();
    return true;
  }
}
