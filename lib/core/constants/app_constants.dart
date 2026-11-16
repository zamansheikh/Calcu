class AppConstants {
  AppConstants._();

  static const String appName = 'Calcu';
  static const String tagline = 'A featuristic calculator for everyone';
  static const String developerName = 'Zaman Sheikh';
  static const String githubUrl = 'https://github.com/zamansheikh';
  static const String repoUrl = 'https://github.com/zamansheikh/Calcu';
  static const String telegramUrl = 'https://t.me/programmernexus';
  static const String donateUrl = 'https://www.buymeacoffee.com/zamansheikh';
}

class StorageKeys {
  StorageKeys._();

  /// Saved results as bare values. Superseded by [savedEntries]; still read
  /// once, to carry over what an earlier version saved.
  static const String savedValues = 'calculator.saved_values';
  static const String savedEntries = 'calculator.saved_entries';
  static const String themeMode = 'theme.mode';
  static const String activeThemePackId = 'theme.active_pack_id';
  static const String ownedThemePackIds = 'theme.owned_pack_ids';
}
