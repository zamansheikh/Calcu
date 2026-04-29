import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../core/services/billing_service.dart';
import '../../data/repositories/theme_repository.dart';
import '../../theme/theme_catalog.dart';

/// Owns the user's theme selections and exposes ownership/purchase state for
/// the in-app theme store.
///
/// Ownership is sourced from [BillingService] (RevenueCat in production, or a
/// local SharedPreferences mock in dev). The repository continues to hold the
/// **active** pack id and theme mode — UI state that lives outside the store.
class ThemeProvider extends ChangeNotifier {
  ThemeProvider({
    required ThemeRepository repository,
    required BillingService billing,
  })  : _repository = repository,
        _billing = billing {
    _mode = _repository.readMode();
    _activePackId = _repository.readActivePackId();
    _ownedIds = {ThemePackId.classic, ..._repository.readOwnedPackIds()};
    if (!_ownedIds.contains(_activePackId)) {
      _activePackId = ThemeCatalog.defaultId;
    }
    _entitlementsSubscription = _billing.entitlementUpdates.listen(
      _applyEntitlements,
    );
    _bootstrap();
  }

  final ThemeRepository _repository;
  final BillingService _billing;
  StreamSubscription<Set<String>>? _entitlementsSubscription;

  late ThemeMode _mode;
  late String _activePackId;
  late Set<String> _ownedIds;

  Map<String, String> _livePrices = const <String, String>{};
  bool _busy = false;
  String? _statusMessage;

  ThemeMode get themeMode => _mode;
  String get activePackId => _activePackId;
  ThemePack get activePack => ThemeCatalog.byId(_activePackId);
  List<ThemePack> get packs => ThemeCatalog.packs;

  /// True while a purchase or restore is in flight; UI can show progress.
  bool get isBusy => _busy;

  /// Latest non-fatal status message (e.g. "Restored 2 themes"). One-shot —
  /// callers consume via [consumeStatusMessage].
  String? consumeStatusMessage() {
    final msg = _statusMessage;
    _statusMessage = null;
    return msg;
  }

  /// Whether real billing is wired up. UI uses this to decide whether to show
  /// the "Restore purchases" button.
  bool get isStoreConfigured => _billing.isStoreConfigured;

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

  bool isOwned(String packId) =>
      packId == ThemePackId.classic || _ownedIds.contains(packId);

  /// Returns the live store price if available, else the catalog default.
  String? priceLabel(ThemePack pack) {
    final live = _livePrices[pack.id];
    if (live != null && live.isNotEmpty) return live;
    return pack.priceLabel;
  }

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
    if (!isOwned(id)) return false;
    if (_activePackId == id) return true;
    _activePackId = id;
    _repository.writeActivePackId(id);
    notifyListeners();
    return true;
  }

  /// Initiates a real purchase via [BillingService]. Returns true on success
  /// (entitlement now active). False covers user-cancellation; callers can
  /// inspect [consumeStatusMessage] for the reason. Throws [BillingException]
  /// on hard failures.
  Future<bool> purchasePack(String id) async {
    if (isOwned(id)) return true;
    _setBusy(true);
    try {
      final result = await _billing.purchase(id);
      _applyEntitlements(result.entitlements);
      if (result.userCancelled) {
        _statusMessage = 'Purchase cancelled';
        return false;
      }
      return isOwned(id);
    } finally {
      _setBusy(false);
    }
  }

  Future<int> restorePurchases() async {
    _setBusy(true);
    try {
      final before = _ownedIds.length;
      final result = await _billing.restore();
      _applyEntitlements(result.entitlements);
      final gained = (_ownedIds.length - before).clamp(0, packs.length);
      _statusMessage = gained == 0
          ? 'Nothing to restore'
          : 'Restored $gained ${gained == 1 ? 'theme' : 'themes'}';
      return gained;
    } finally {
      _setBusy(false);
    }
  }

  Future<void> _bootstrap() async {
    final entitlements = await _billing.activeEntitlements();
    _applyEntitlements(entitlements);
    final prices = await _billing.priceLabels();
    if (prices.isNotEmpty) {
      _livePrices = prices;
      notifyListeners();
    }
  }

  void _applyEntitlements(Set<String> entitlements) {
    final updated = {ThemePackId.classic, ...entitlements};
    if (setEquals(_ownedIds, updated)) return;
    _ownedIds = updated;
    // Persist a local copy so a cold start without network still shows the
    // right "owned" state until RevenueCat catches up.
    _repository.writeOwnedPackIds(_ownedIds);
    if (!_ownedIds.contains(_activePackId)) {
      _activePackId = ThemeCatalog.defaultId;
      _repository.writeActivePackId(_activePackId);
    }
    notifyListeners();
  }

  void _setBusy(bool value) {
    if (_busy == value) return;
    _busy = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _entitlementsSubscription?.cancel();
    super.dispose();
  }
}

bool setEquals<T>(Set<T> a, Set<T> b) {
  if (a.length != b.length) return false;
  for (final e in a) {
    if (!b.contains(e)) return false;
  }
  return true;
}
