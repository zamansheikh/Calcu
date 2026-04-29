import 'package:get_it/get_it.dart';

import '../../data/repositories/saved_values_repository.dart';
import '../../data/repositories/theme_repository.dart';
import '../../presentation/providers/calculator_provider.dart';
import '../../presentation/providers/theme_provider.dart';
import '../services/billing_service.dart';
import '../services/calculator_engine.dart';
import '../services/storage_service.dart';

final GetIt sl = GetIt.instance;

/// Resolves the dependency graph. Order matters: each line below depends only
/// on what was registered above it.
Future<void> configureDependencies() async {
  if (sl.isRegistered<StorageService>()) return;

  final storage = await StorageService.create();
  sl.registerSingleton<StorageService>(storage);

  sl.registerLazySingleton<CalculatorEngine>(() => const CalculatorEngine());
  sl.registerLazySingleton<SavedValuesRepository>(
    () => SavedValuesRepository(sl<StorageService>()),
  );
  sl.registerLazySingleton<ThemeRepository>(
    () => ThemeRepository(sl<StorageService>()),
  );
  sl.registerLazySingleton<BillingService>(
    () => BillingService(sl<ThemeRepository>()),
  );

  sl.registerFactory<CalculatorProvider>(
    () => CalculatorProvider(
      engine: sl<CalculatorEngine>(),
      savedValuesRepository: sl<SavedValuesRepository>(),
    ),
  );
  sl.registerFactory<ThemeProvider>(
    () => ThemeProvider(
      repository: sl<ThemeRepository>(),
      billing: sl<BillingService>(),
    ),
  );
}
