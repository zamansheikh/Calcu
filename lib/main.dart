import 'package:calcu/presentation/pages/home_page.dart';
import 'package:calcu/presentation/providers/home_provider.dart';
import 'package:calcu/theme/app_theme.dart';
import 'package:calcu/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  di.init();

  // Initialize HomeProvider and call onInit
  final homeProvider = di.sl<HomeProvider>();
  homeProvider.onInit();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
        designSize: const Size(412, 732),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (_, child) {
          return MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) => di.sl<HomeProvider>()),
              ChangeNotifierProvider(create: (_) => di.sl<ThemeProvider>()),
            ],
            child: Consumer<ThemeProvider>(builder: (context, value, _) {
              return MaterialApp(
                title: 'Calcu App',
                theme: AppTheme.defalultTheme,
                home: const HomePage(),
                themeMode: value.themeMode,
                darkTheme: AppTheme.darkTheme,
                debugShowCheckedModeBanner: false,
              );
            }),
          );
        });
  }
}
