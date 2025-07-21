import 'package:calcu/presentation/providers/calculator_provider.dart';
import 'package:calcu/theme/theme_provider.dart';
import 'package:get_it/get_it.dart';

final sl = GetIt.instance;

void init() {
  sl.registerFactory(() => CalculatorProvider());
  sl.registerFactory(() => ThemeProvider());
}
