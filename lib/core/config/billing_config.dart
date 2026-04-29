/// Configuration for in-app purchases via RevenueCat.
///
/// SETUP CHECKLIST
/// ---------------
/// 1. Create a RevenueCat project (https://app.revenuecat.com).
/// 2. Connect Google Play (and App Store, if shipping iOS).
/// 3. In Google Play Console, create a non-consumable, managed product for
///    each premium theme. Use the IDs from `productIdFor` below as the
///    Play product IDs.
/// 4. In RevenueCat:
///       - Add each Play product as a Product
///       - Create one Entitlement per theme (id matches the pack id, e.g.
///         `midnight`, `sunset`, …) — attach the matching product
///       - Create an Offering (e.g. `default`) with one Package per theme,
///         using the package identifiers from `packageIdFor` below
/// 5. Copy your **public** Android SDK key into [androidApiKey] (and the iOS
///    key into [iosApiKey] if applicable). NEVER commit a secret key — these
///    are public, client-side keys, but still treat them as config.
/// 6. Leave [androidApiKey] empty during local development; the app falls
///    back to a SharedPreferences-backed mock so the store flows still work.
class BillingConfig {
  BillingConfig._();

  /// Public RevenueCat key for Android. Empty means "use local mock".
  static const String androidApiKey = '';

  /// Public RevenueCat key for iOS.
  static const String iosApiKey = '';

  /// Whether RevenueCat is configured for the current platform.
  static bool isConfigured(bool isIos) =>
      (isIos ? iosApiKey : androidApiKey).isNotEmpty;

  /// RevenueCat package identifier for a given theme pack id. Override here
  /// if your dashboard uses different names.
  static String packageIdFor(String packId) => packId;

  /// RevenueCat entitlement id for a given theme pack id.
  static String entitlementIdFor(String packId) => packId;

  /// Play / App Store product id for a given theme pack id.
  static String productIdFor(String packId) => 'theme_$packId';
}
