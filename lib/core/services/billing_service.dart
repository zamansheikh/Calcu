import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../data/repositories/theme_repository.dart';
import '../config/billing_config.dart';

/// Result of a purchase / restore attempt. `entitlements` is the full set of
/// active entitlements after the operation (always authoritative — callers
/// should replace their local state with this).
class BillingResult {
  const BillingResult({required this.entitlements, this.userCancelled = false});

  final Set<String> entitlements;
  final bool userCancelled;
}

class BillingException implements Exception {
  BillingException(this.message);
  final String message;

  @override
  String toString() => 'BillingException: $message';
}

/// Wraps RevenueCat. When [BillingConfig] has no API key configured, falls
/// back to persisting "purchases" through [ThemeRepository] so dev builds and
/// CI tests still exercise the full UI flow.
///
/// Public API is intentionally narrow: [activeEntitlements], [purchase],
/// [restore], [priceLabels], plus an [entitlementUpdates] stream so providers
/// can react to changes pushed by the SDK (e.g. cross-device purchases).
class BillingService {
  BillingService(this._localFallback);

  final ThemeRepository _localFallback;

  final StreamController<Set<String>> _entitlementsController =
      StreamController<Set<String>>.broadcast();

  bool _initialized = false;
  bool _useRealStore = false;

  /// Stream of authoritative entitlement sets. Emits whenever the SDK
  /// receives an updated `CustomerInfo` (e.g. after a refund, restore, or
  /// purchase made on another device).
  Stream<Set<String>> get entitlementUpdates =>
      _entitlementsController.stream;

  /// Whether the live store is wired up. UI can hide the "Restore purchases"
  /// button when this is false to avoid confusing users.
  bool get isStoreConfigured => _useRealStore;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    final isIos = Platform.isIOS;
    if (!BillingConfig.isConfigured(isIos)) {
      _useRealStore = false;
      return;
    }

    final key = isIos ? BillingConfig.iosApiKey : BillingConfig.androidApiKey;
    try {
      await Purchases.setLogLevel(LogLevel.warn);
      await Purchases.configure(PurchasesConfiguration(key));
      _useRealStore = true;
      Purchases.addCustomerInfoUpdateListener((info) {
        _entitlementsController.add(_extractEntitlements(info));
      });
    } catch (e) {
      // Fail open: if RevenueCat refuses to configure (network, key typo,
      // etc.) we keep the local mock alive so the UI doesn't break.
      _useRealStore = false;
    }
  }

  /// Set of entitlement ids the user currently owns. Always returns at least
  /// the locally-known set; falls through to RevenueCat when configured.
  Future<Set<String>> activeEntitlements() async {
    if (!_useRealStore) {
      return {..._localFallback.readOwnedPackIds()};
    }
    try {
      final info = await Purchases.getCustomerInfo();
      return _extractEntitlements(info);
    } catch (_) {
      return {..._localFallback.readOwnedPackIds()};
    }
  }

  /// Localized price strings keyed by pack id. Empty when offerings can't be
  /// loaded (offline, dashboard not configured, mock mode).
  Future<Map<String, String>> priceLabels() async {
    if (!_useRealStore) return const <String, String>{};
    try {
      final offerings = await Purchases.getOfferings();
      final current = offerings.current;
      if (current == null) return const <String, String>{};
      final result = <String, String>{};
      for (final pkg in current.availablePackages) {
        // The package identifier is the canonical key (matches packageIdFor).
        result[pkg.identifier] = pkg.storeProduct.priceString;
      }
      return result;
    } catch (_) {
      return const <String, String>{};
    }
  }

  /// Buy the package mapped to [packId]. Returns the new authoritative
  /// entitlement set, or `userCancelled = true` when the user dismissed the
  /// store sheet.
  Future<BillingResult> purchase(String packId) async {
    if (!_useRealStore) {
      // Mock: locally mark as owned and persist via the fallback repo.
      final updated = {..._localFallback.readOwnedPackIds(), packId};
      await _localFallback.writeOwnedPackIds(updated);
      _entitlementsController.add(updated);
      return BillingResult(entitlements: updated);
    }

    final packageId = BillingConfig.packageIdFor(packId);
    try {
      final offerings = await Purchases.getOfferings();
      final current = offerings.current;
      if (current == null) {
        throw BillingException('No offerings configured in RevenueCat');
      }
      Package? pkg;
      for (final p in current.availablePackages) {
        if (p.identifier == packageId) {
          pkg = p;
          break;
        }
      }
      if (pkg == null) {
        throw BillingException('Package "$packageId" missing from offering');
      }
      final result = await Purchases.purchase(PurchaseParams.package(pkg));
      return BillingResult(
        entitlements: _extractEntitlements(result.customerInfo),
      );
    } on PlatformException catch (e) {
      final code = PurchasesErrorHelper.getErrorCode(e);
      if (code == PurchasesErrorCode.purchaseCancelledError) {
        final current = await activeEntitlements();
        return BillingResult(entitlements: current, userCancelled: true);
      }
      throw BillingException(e.message ?? 'Purchase failed');
    }
  }

  /// Re-syncs entitlements from the store. Use this when the user reinstalls
  /// or signs in on a new device.
  Future<BillingResult> restore() async {
    if (!_useRealStore) {
      final current = {..._localFallback.readOwnedPackIds()};
      _entitlementsController.add(current);
      return BillingResult(entitlements: current);
    }
    try {
      final info = await Purchases.restorePurchases();
      return BillingResult(entitlements: _extractEntitlements(info));
    } on PlatformException catch (e) {
      throw BillingException(e.message ?? 'Restore failed');
    }
  }

  Set<String> _extractEntitlements(CustomerInfo info) {
    return info.entitlements.active.keys.toSet();
  }

  void dispose() {
    _entitlementsController.close();
  }
}
